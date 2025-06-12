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
    def __init__(self, nb_layers = 3, nb_nodes = 64, nb_inputs = 2, nb_outputs = 2) -> None:
        self.model = Model(nb_layers, nb_nodes, nb_inputs, nb_outputs)
        self.quantities = dict()

        self.nb_layers = nb_layers
        self.nb_nodes = nb_nodes
        self.nb_inputs = nb_inputs
        self.nb_outputs = nb_outputs

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
        if name != "times" and len(quantity.shape) != 2:
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
        if self.grid["thetas"].size != self.quantities["dBrdt"].shape[0] or self.grid["phis"].size != self.quantities["dBrdt"].shape[1]:
            raise Exception("The fields do not appear aligned with the grid.")
        
        # If the field derivatives are not computed yet, we are computing them
        if "Br" in self.quantities and "dBrdth" not in self.quantities:
            self.quantities["dBrdth"] = np.gradient(self.quantities["Br"], self.grid["thetas"], axis=0)

        if "Br" in self.quantities and "dBrdph" not in self.quantities:
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
        if "Br" in self.quantities:
            Br_nn = torch.tensor(self.quantities["Br"].flatten()[:, None], dtype=torch.float32)
            dBrdth_nn = torch.tensor(self.quantities["dBrdth"].flatten()[:, None], dtype=torch.float32)
            dBrdph_nn = torch.tensor(self.quantities["dBrdph"].flatten()[:, None], dtype=torch.float32)

        dBrdt_nn = torch.tensor(self.quantities["dBrdt"].flatten()[:, None], dtype=torch.float32)

        # Creating the angular inputs
        inputs = torch.cat([thetas_nn, phis_nn], dim=1)

        # Saving
        self.quantities_nn = {
            "inputs": inputs,
            "thetas": thetas_nn,
            "phis": phis_nn,
            "dBrdt": dBrdt_nn
        }

        if "Br" in self.quantities:
            self.quantities_nn["Br"] = Br_nn
            self.quantities_nn["dBrdth"] = dBrdth_nn
            self.quantities_nn["dBrdph"] = dBrdph_nn

    # Adding the loss
    def loss(self, inputs):
        # Radius at the CMB (in km)
        r = 3485

        # Retrieving the predicted flow
        u_pred = self.model(inputs)

        # Retrieving the toroidal and poloidal components

        T = u_pred[:, 0:1]
        S = u_pred[:, 1:2]

        # We are predicting also the radial magnetic field
        if "Br" not in self.quantities_nn and self.nb_outputs != 3:
            raise ValueError("Input features too small to predict Br.")

        # First derivatives of T and S
        dT_dth = torch.autograd.grad(T, self.quantities_nn["thetas"], grad_outputs=torch.ones_like(T), create_graph=True, retain_graph=True)[0]
        dT_dph = torch.autograd.grad(T, self.quantities_nn["phis"], grad_outputs=torch.ones_like(T), create_graph=True, retain_graph=True)[0]
        dS_dth = torch.autograd.grad(S, self.quantities_nn["thetas"], grad_outputs=torch.ones_like(S), create_graph=True, retain_graph=True)[0]
        dS_dph = torch.autograd.grad(S, self.quantities_nn["phis"], grad_outputs=torch.ones_like(S), create_graph=True, retain_graph=True)[0]

        # If we are predicting the radial magnetic field
        if self.nb_outputs == 3:
            Br = u_pred[:, 2:3]
            dBrdth = torch.autograd.grad(Br, self.quantities_nn["thetas"], grad_outputs=torch.ones_like(Br), create_graph=True, retain_graph=True)[0]
            dBrdph = torch.autograd.grad(Br, self.quantities_nn["phis"], grad_outputs=torch.ones_like(Br), create_graph=True, retain_graph=True)[0]
        else:
            dBrdth = self.quantities_nn["dBrdth"]
            dBrdph = self.quantities_nn["dBrdph"]
            Br = self.quantities_nn["Br"]

        """
        Computing L1
        """
        # Computing the L1² loss function
        # L1² = || dBr / dt + ∇h • (Uh Br) ||²
        # ∇h • (Uh Br) = (∇h • Uh) Br + Uh • (∇h Br)

        sin_th = torch.sin(self.quantities_nn["thetas"])
        tan_th = torch.tan(self.quantities_nn["thetas"])

        # We are defining u_th and u_ph with T and S
        u_th = -dT_dph / sin_th + dS_dth
        u_ph = dT_dth + dS_dph / sin_th

        # Computing ∇h • Uh
        u_th_sin_th = u_th * sin_th
        d_u_th_sin_th_dth = torch.autograd.grad(u_th_sin_th, self.quantities_nn["thetas"], grad_outputs=torch.ones_like(u_th_sin_th), create_graph=True, retain_graph=True)[0]

        d_u_ph_dph = torch.autograd.grad(u_ph, self.quantities_nn["phis"], grad_outputs=torch.ones_like(u_ph), create_graph=True, retain_graph=True)[0]

        divH_uH = (1 / (r * sin_th)) * (d_u_th_sin_th_dth + d_u_ph_dph)

        # Computing ∇h Br
        # The derivatives are provided as they are not the NN variables but inputs
        gradH_Br_th = (1 / r) * dBrdth
        gradH_Br_ph = (1 / (r * sin_th)) * dBrdph

        # Computing the predicted SV
        dBrdt_predicted = -(Br * divH_uH + u_th * gradH_Br_th + u_ph * gradH_Br_ph)

        # Computing L1
        L1 = self.quantities_nn["dBrdt"] - dBrdt_predicted

        # Computing L2
        L2 = divH_uH - u_th * tan_th / r

        # Computing L3
        if self.nb_outputs == 3:
            L3 = self.quantities_nn["Br"] - Br

        # Returning the predicted quantities and losses
        if self.nb_outputs != 3:
            return L1, L2, dBrdt_predicted, u_th, u_ph
        
        return L1, L2, L3, dBrdt_predicted, u_th, u_ph, Br
    
    # Training the model
    def train(self, nb_reals = 5, nb_epochs = 1000, algo = "lbfgs"):

        λ2 = 1e3
        λ3 = 1e3

        if algo == "adam":
            optimizer = torch.optim.Adam(self.model.parameters(), 1e-3)

            for epoch in range(nb_epochs):
                optimizer.zero_grad()

                if self.nb_outputs != 3:
                    L1, L2, *_ = self.loss(self.quantities_nn["inputs"])
                else:
                    L1, L2, L3, *_ = self.loss(self.quantities_nn["inputs"])

                L1_loss = (L1**2).mean()
                L2_loss = (L2**2).mean()

                if self.nb_outputs == 3:
                    L3_loss = (L3**2).mean()

                if self.nb_outputs != 3:
                    Loss = L1_loss + λ2 * L2_loss
                else:
                    Loss = L1_loss + λ2 * L2_loss + λ3 * L3_loss

                Loss.backward()

                optimizer.step()

                if epoch % 100 == 0:
                    if self.nb_outputs != 3:
                        print(f"Epoch {epoch}: L1 = {L1_loss}, L2 = {L2_loss}")
                    else:
                        print(f"Epoch {epoch}: L1 = {L1_loss}, L2 = {L2_loss}, L3 = {L3_loss}")

        if algo == "lbfgs":
            optimizer = torch.optim.LBFGS(self.model.parameters(), line_search_fn="strong_wolfe", tolerance_grad=1e-3, tolerance_change=1e-6)

            def closure():
                optimizer.zero_grad()

                if self.nb_outputs != 3:
                    L1, L2, *_ = self.loss(self.quantities_nn["inputs"])
                else:
                    L1, L2, L3, *_ = self.loss(self.quantities_nn["inputs"])

                L1_loss = (L1**2).mean()
                L2_loss = (L2**2).mean()

                if self.nb_outputs == 3:
                    L3_loss = (L3**2).mean()

                if self.nb_outputs != 3:
                    Loss = L1_loss + λ2 * L2_loss
                else:
                    Loss = L1_loss + λ2 * L2_loss + λ3 * L3_loss

                Loss.backward()

                return Loss

            for epoch in range(nb_epochs):
                optimizer.step(closure)

                if epoch % 100 == 0:
                    print(f"Epoch {epoch}: Loss = {closure()}")

    # Retrieving the results
    def results(self):
        if self.nb_outputs != 3:
            *_, dBrdt_pred, uth_pred, uph_pred = self.loss(self.quantities_nn["inputs"])
        
            return  dBrdt_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy(), \
                    uth_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy(), \
                    uph_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy()
        else:
            *_, dBrdt_pred, uth_pred, uph_pred, Br_pred = self.loss(self.quantities_nn["inputs"])

            return  dBrdt_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy(), \
                    uth_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy(), \
                    uph_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy(), \
                    Br_pred.reshape(self.quantities["dBrdt"].shape).detach().numpy()

"""
Creating the neural network model
with `nb_layers` hidden layers and `nb_nodes` nodes
"""
class Model(torch.nn.Module):
    def __init__(self, nb_layers = 3, nb_nodes = 64, nb_inputs = 2, nb_outputs = 2):
        super(Model, self).__init__()

        # For storing the layers
        layers = []

        # Adding the first layer 
        layers.append(torch.nn.Linear(nb_inputs, nb_nodes))
        layers.append(torch.nn.Tanh())

        # Adding the hidden layers
        for _ in range(nb_layers):
            layers.append(torch.nn.Linear(nb_nodes, nb_nodes))
            layers.append(torch.nn.Tanh())

        # Adding the last layer
        layers.append(torch.nn.Linear(nb_nodes, nb_outputs))

        # Creating the neural network
        self.net = torch.nn.Sequential(*layers)

    def forward(self, x):
        return self.net(x)