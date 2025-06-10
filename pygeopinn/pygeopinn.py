# This file is part of pygeopinn
# (c) 2025 - Geodynamo (ISTerre)

# Wrote by Romain Claveau (romain.claveau@univ-grenoble-alpes.fr)

# v0 (draft - ongoing)

import numpy as np
import torch

"""
Solving the geodynamo inverse problem using Physics-Informed Neural Network (PINN)
"""
class pygeopinn:

    # Creating the instance
    def __init__(self, nb_layers = 3, nb_nodes = 64) -> None:
        self.model = Model(nb_layers, nb_nodes)
        self.quantities = dict()

    # Adding a quantity
    def add(self, name, quantity):
        # Checking the quantity's name
        if name not in ["times", "Br", "dBrdt", "dBrdth", "dBrdph"]:
            raise KeyError("Quantity not recognized.")
        
        # Checking the type
        if not isinstance(quantity, np.ndarray):
            raise TypeError("Quantity must be `numpy.ndarray`.")
        
        # Checking the shape for the times (dim = 1)
        if name == "times" and len(quantity.shape) != 1:
            raise ValueError("Bad shape for the quantity.")
        
        # Checking the shape for the fields (dim = 2)
        if name != "times" and len(quantity) != 2:
            raise ValueError("Bad shape for the quantity.")
        
        # Saving the quantity
        self.quantities[name] = quantity

    # Getting a quantity
    def get(self, name):
        # Checking if the quantity exists
        if name not in self.quantities:
            raise KeyError(f"Failed to retrieve the quantity `{name}`")
        
        return self.quantities[name]
    
    # Setting the grid on which we'll invert the core flow
    def set_grid(self, thetas, phis, avoid_poles = True, avoid_equator = True):
        
        if np.max(np.abs(thetas)) > np.pi:
            thetas = np.rad2deg(thetas)

        if np.max(np.abs(phis)) > 2 * np.pi:
            phis = np.rad2deg(phis)

        # Flags for avoiding the equator and the poles
        self.avoid_poles = avoid_poles
        self.avoid_equator = avoid_equator

        # Converting back to radians
        thetas = np.deg2rad(thetas)
        phis = np.deg2rad(phis)

        # Saving
        self.grid = {"thetas": thetas, "phis": phis}

    # Initializing all the tensors
    def init(self):
        # Checking that we have the necessary information
        if not any([quantity in self.quantities for quantity in ["times", "Br", "dBrdt"]]):
            raise Exception("Mandatory informations are missing.")
        
        # Checking the grid
        if "thetas" not in self.grid or "phis" not in self.grid:
            raise Exception("Missing the grid")
        
        # Checking if the grid dimensions match those of the fields
        if self.grid["thetas"].size != self.quantities["Br"].shape[0] or self.grid["phis"].size != self.quantities["Br"].shape[1]:
            raise Exception("The fields do not appear aligned with the grid.")
        
        # If the field derivatives are not computed yet, we are computing them
        if "dBrdth" not in self.quantities:
            self.quantities["dBrdth"] = np.gradient(self.quantities["Br"], self.grid["thetas"], axis=0)

        if "dBrdph" not in self.quantities:
            self.quantities["dBrdph"] = np.gradient(self.quantities["Br"], self.grid["phis"], axis=1)

        # Now, we need to convert all the quantities into tensor

        # Creating the angular grid
        thetas_grid, phis_grid = np.meshgrid(self.grid["thetas"], self.grid["phis"], indexing="ij")

        # Creating the (flatten) grid points
        thetas_flatten = thetas_grid.flatten()
        phis_flatten = phis_grid.flatten()

        # Creating the grid tensors to feed the NN
        thetas_nn = torch.tensor(thetas_flatten[:, None], dtype=torch.float32, requires_grad=True)
        phis_nn = torch.tensor(phis_flatten[:, None], dtype=torch.float32, requires_grad=True)

        # Creating the fields tensor
        Br_nn = torch.tensor(self.quantities["Br"].flatten()[:, None], dtype=torch.float32)
        dBrdt_nn = torch.tensor(self.quantities["dBrdt"].flatten()[:, None], dtype=torch.float32)
        dBrdth_nn = torch.tensor(self.quantities["dBrdth"].flatten()[:, None], dtype=torch.float32)
        dBrdph_nn = torch.tensor(self.quantities["dBrdph"].flatten()[:, None], dtype=torch.float32)

        # Creating the angular inputs
        inputs = torch.cat([thetas_nn, phis_nn], dim=1)

        # Saving
        self.quantities_nn = {
            "inputs": inputs,
            "Br": Br_nn,
            "dBrdt": dBrdt_nn,
            "dBrdth": dBrdth_nn,
            "dBrdph": dBrdph_nn
        }

"""
Creating the neural network model
with `nb_layers` hidden layers and `nb_nodes` nodes
"""
class Model(torch.nn.Module):
    def __init__(self, nb_layers = 3, nb_nodes = 64):
        super(Model, self).__init__()

        # For storing the layers
        layers = []

        # Adding the first layer 
        layers.append(torch.nn.Linear(2, nb_nodes))
        layers.append(torch.nn.Tanh())

        # Adding the hidden layers
        for _ in range(nb_layers):
            layers.append(torch.nn.Linear(nb_nodes, nb_nodes))
            layers.append(torch.nn.Tanh())

        # Adding the last layer
        layers.append(torch.nn.Linear(nb_nodes, 2))

        # Creating the neural network
        self.net = torch.nn.Sequential(*layers)

    def forward(self, x):
        return self.net(x)