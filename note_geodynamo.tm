<TeXmacs|2.1.4>

<style|<tuple|elsarticle|number-long-article|british>>

<\body>
  <doc-data|<doc-title|Machine Learning for the geodynamo
  inverse<next-line>problem>|<doc-subtitle|Physics-informed Neural
  Network>|<doc-date|<date>>|<doc-author|<author-data|<author-name|Romain
  Claveau>>>>

  <\with|par-mode|right>
    <\table-of-contents|toc>
      <vspace*|1fn><with|font-series|bold|math-font-series|bold|1<space|1.1fn>Context>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|bold|math-font-series|bold|2<space|1.1fn>The
      geodynamo inverse problem> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|bold|math-font-series|bold|3<space|1.1fn>Tangential
      flow field> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <vspace*|1fn><with|font-series|bold|math-font-series|bold|4<space|1.1fn>Inverting
      for the tangential core flow> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4><vspace|0.5fn>

      <with|par-left|1tab|4.1<space|1.1fn>Framework
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|1tab|4.2<space|1.1fn>The equation and fields in
      spherical coordinates <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <vspace*|1fn><with|font-series|bold|math-font-series|bold|Appendix
      A<space|1.1fn>Del in spherical coordinates>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7><vspace|0.5fn>

      <with|par-left|1tab|A.1<space|1.1fn>Gradient
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>
    </table-of-contents>
  </with>

  <section|Context>

  The geodynamo is a physical process behind the Earth's sustained magnetic
  field, stemming from complex fluid motions of the electrically conducting
  liquid metal within the outer core. Because these processes occur at
  extreme depth and conditions, which are entirely out-of-reach of direct
  observations or experimental replicas, our understanding of the geodynamo
  relies heavily on numerical simulations.

  However, the Earth's physical parameters are also out-of-reach of numerical
  simulations as its outer core operates at low viscosity (as measured by
  <math|Ek \<simeq\> 10<rsup|-15>> and <math|Pm \<simeq\> 10<rsup|-6>>).
  Also, the Earth's dynamo features a small ratio of the kinetic to magnetic
  energy (as measured by <math|Al<rsup|2> \<simeq\> 10<rsup|-4>>). So,
  reproducing Earth-like conditions requires to reach an asymptotic regime,
  which afterwards could be extrapolated to the Earth.

  We recall the definitions of the Ekman number (<math|Ek>), the magnetic
  Prandlt number (<math|Pm>) and the Alfvén number (<math|Al>):

  <\equation>
    <tabular*|<tformat|<table|<row|<cell|Ek =
    <frac|\<tau\><rsub|\<Omega\>>|\<tau\><rsub|\<nu\>>>>|<cell|;>|<cell|Pm =
    <frac|\<tau\><rsub|\<eta\>>|\<tau\><rsub|\<nu\>>>>|<cell|;>|<cell|Al =
    <frac|\<tau\><rsub|A>|\<tau\><rsub|U>>>>>>>
  </equation>

  where <math|\<tau\><rsub|\<Omega\>>> the inverse rotation rate,
  <math|\<tau\><rsub|\<nu\>>> the viscous diffusion time,
  <math|\<tau\><rsub|\<eta\>>> the magnetic diffusion time,
  <math|\<tau\><rsub|A>> the Alfvén time and <math|\<tau\><rsub|U>> the
  convective overturn time.

  As a result, in addition to numerical simulations of the geodynamo, we rely
  on the induction equation relating the outer core motions and the magnetic
  field, to infers the flow through magnetic observations by solving the
  geodynamo inverse problem.

  <section|The geodynamo inverse problem>

  The induction equation, relating the core flow to the magnetic field, is
  obtained from Ohm's law (accounting for the Lorentz force)

  <\equation>
    <with|font-series|bold|J> = \<sigma\><around*|(|<with|font-series|bold|E>
    + <with|font-series|bold|u> \<times\><with|font-series|bold|B>|)>
  </equation>

  where <with|font-series|bold|<math|J>> is the electric current field,
  <math|<with|font-series|bold|E>> the electrical field,
  <math|<with|font-series|bold|u>> the velocity field and
  <math|<with|font-series|bold|B>> the magnetic field. Because the Earth's
  mantle is electrically insulating (at least has a very low electrical
  conductivity), <math|<with|font-series|bold|J>> vanishes. Then, taking the
  curl, and using the Faraday's law, one gets the ideal magneto-hydrodynamics
  equation

  <\equation>
    <frac|\<partial\><with|font-series|bold|B>|\<partial\>t> \ =
    <with|font-series|bold|\<nabla\>>\<times\><around*|(|<with|font-series|bold|u>\<times\><with|font-series|bold|B>|)>
  </equation>

  where <math|<with|font-series|bold|\<nabla\>>\<times\>> is the curl
  operator. Also, because we are considerating the mantle as insulating, the
  magnetic field is divergence-free and curl-free. As a result, it derives
  from a potential <math|<with|font-series|bold|B> =
  -<with|font-series|bold|\<nabla\>>V>, with <math|V> the magnetic potential,
  and its evolution above the outer core surface is entirely prescribed by
  its radial component at the core-mantle boundary (CMB).

  At the CMB, the outer core motions are constrained by the mantle as it
  cannot flow radially. As a result, only its tangential components are
  non-zero. Finally, because the radial magnetic field is the only one driven
  by these tangential motions, one gets the radial induction equation at the
  CMB, reading as

  <\equation>
    <frac|\<partial\>B<rsub|r>|\<partial\>t> =
    -<with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <around*|(|<with|font-series|bold|u><rsub|H> B<rsub|r>|)>
  </equation>

  where <math|<with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>> is the
  horizontal (tangential) divergence operator, <math|B<rsub|r>> the radial
  magnetic field and <math|<with|font-series|bold|u><rsub|H>> the tangential
  flow.

  Thus, the <with|font-shape|italic|geodynamo inverse problem> is precisely
  inferring the tangential outer core flow
  <math|<with|font-series|bold|u><rsub|H>> from the magnetic observations
  <math|B<rsub|r>>.

  <section|Tangential flow field>

  As the outer core flow is incompressible, it admits a unique
  toroidal\Upoloidal decomposition:

  <\equation>
    <with|font-series|bold|u> = <with|font-series|bold|\<nabla\>>\<times\><around*|(|<with|font-series|bold|r>
    <with|font|cal|T>|)> + <with|font-series|bold|\<nabla\>>\<times\><around*|(|<with|font-series|bold|\<nabla\>>\<times\><around*|(|<with|font-series|bold|r>
    <with|font|cal|S>|)>|)>
  </equation>

  with <math|<with|font|cal|T>> and <math|<with|font|cal|S>> the toroidal and
  poloidal scalar fields, respectively. The expression is further simplied as
  we are considering the tangential flow, and reads

  <\equation>
    <with|font-series|bold|u><rsub|H> = -<with|font-series|bold|r>\<times\><with|font-series|bold|\<nabla\>><rsub|H>
    <with|font|cal|T> + <with|font-series|bold|\<nabla\>><rsub|H><around*|(|r
    <with|font|cal|S>|)>
  </equation>

  Using this expression for the tangential flow field
  <math|<with|font-series|bold|u><rsub|H>> ensures the incompressibility
  condition (ie. <math|<with|font-series|bold|\<nabla\>> \<cdot\>
  <with|font-series|bold|u> = 0>).

  <section|Inverting for the tangential core flow>

  The <with|font-shape|italic|geodynamo inverse problem> is an ill-defined
  problem as we have to retrieve the two tangential components of the core
  flow, <math|u<rsub|\<theta\>>> and <math|u<rsub|\<phi\>>>, using one
  equation. In this context, we have to provide additional information to
  ensure the uniqueness of the solution. Although this is usually done using
  Bayesian-like optimization, the use of <with|font-shape|italic|physics-informed
  neural network> (PINN) could be a way forward, allowing (hopefully) to
  resolve small length-scales that are computationally prohibitive otherwise.

  <subsection|Framework>

  We are solving the radial induction equation at the CMB

  <\equation>
    <frac|\<partial\>B<rsub|r>|\<partial\>t> =
    -<with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <around*|(|<with|font-series|bold|u><rsub|H> B<rsub|r>|)>
  </equation>

  where <math|\<partial\><rsub|t> B<rsub|r>> and <math|B<rsub|r>> are
  extracted from already-existing magnetic models, such as
  <verbatim|COV-OBS.x2> or <verbatim|CHAOS-7>.

  The incompressibility condition on the tangential core flow
  <math|<with|font-series|bold|u><rsub|H>> is enforced by considering a
  toroidal\Upoloidal decomposition.

  <\equation>
    <with|font-series|bold|u><rsub|H> = -<with|font-series|bold|r>\<times\><with|font-series|bold|\<nabla\>><rsub|H>
    <with|font|cal|T> + <with|font-series|bold|\<nabla\>><rsub|H><around*|(|r
    <with|font|cal|S>|)>
  </equation>

  The flow can further be constrained, by having it to be quasi-geostrophic
  (ie. if the force balance is dominated by Coriolis forces, then the flow
  will align itself along the rotation axis, creating a columnar-like flow).
  This condition reads

  <\equation>
    <with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <around*|(|<with|font-series|bold|u><rsub|H>
    cos<around*|(|\<theta\>|)>|)> = 0
  </equation>

  which can further be expanded by distributing the horizontal divergence
  over the product, as

  <\equation>
    <with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <with|font-series|bold|u><rsub|H> - u<rsub|\<theta\>>
    <frac|tan<around*|(|\<theta\>|)>|r> = 0
  </equation>

  Then, we are defining two loss functions, <math|L<rsub|1>> and
  <math|L<rsub|2>> to quantify the misfits to data (<math|L<rsub|1>>) and the
  quasi-geostrophy (<math|L<rsub|2>>) as

  <\equation>
    <around*|{|<tabular*|<tformat|<cwith|1|-1|3|3|cell-halign|l>|<table|<row|<cell|L<rsub|1>>|<cell|=>|<cell|<frac|1|N><big|sum><rsub|grid><around*|\<\|\|\>|<frac|\<partial\>B<rsub|r>|\<partial\>t>+<with|font-series|bold|\<nabla\>><rsub|H>
    \<cdot\> <around*|(|<with|font-series|bold|u><rsub|H>
    B<rsub|r>|)>|\<\|\|\>><rsup|2>>>|<row|<cell|L<rsub|2>>|<cell|=>|<cell|<frac|1|N><big|sum><rsub|grid><around*|\<\|\|\>|<with|font-series|bold|\<nabla\>><rsub|H>
    \<cdot\> <with|font-series|bold|u><rsub|H> - u<rsub|\<theta\>>
    <frac|tan<around*|(|\<theta\>|)>|r>|\<\|\|\>><rsup|2>>>>>>|\<nobracket\>>
  </equation>

  The <with|font-shape|italic|best> model is that minimizing the total loss
  function

  <\equation>
    <below|arg min|\<lambda\>> L<rsub|1><around*|(|\<theta\>,\<phi\>|)>+\<lambda\>
    L<rsub|2><around*|(|\<theta\>,\<phi\>|)>
  </equation>

  <subsection|The equation and fields in spherical coordinates>

  First, we start by expressing the toroidal and poloidal parts of the
  tangential flow field. We define <math|<with|font-series|bold|u><rsub|T>
  \<assign\>-<with|font-series|bold|r>\<times\><with|font-series|bold|\<nabla\>><rsub|H>
  <with|font|cal|T> > and <math|<with|font-series|bold|u><rsub|S> \<assign\>
  <with|font-series|bold|\<nabla\>><rsub|H><around*|(|r
  <with|font|cal|S>|)>>. Consequently, these two fields read

  <\equation>
    <around*|{|<tabular*|<tformat|<cwith|1|-1|3|3|cell-halign|l>|<cwith|1|-1|1|1|cell-halign|r>|<table|<row|<cell|<with|font-series|bold|u><rsub|T>>|<cell|=>|<cell|<around*|(|<frac|1|sin<around*|(|\<theta\>|)>>
    <frac|\<partial\><with|font|cal|T>|\<partial\>\<phi\>>,-<frac|\<partial\><with|font|cal|T>|\<partial\>\<theta\>>|)>>>|<row|<cell|<with|font-series|bold|u><rsub|S>>|<cell|=>|<cell|<around*|(|
    <frac|\<partial\><with|font|cal|S>|\<partial\>\<theta\>>,<frac|1|sin<around*|(|\<theta\>|)>>
    <frac|\<partial\><with|font|cal|S>|\<partial\>\<phi\>>|)>>>>>>|\<nobracket\>>
  </equation>

  Recalling the induction equation, we need to express the horizontal
  divergence of the tangential flow in spherical coordinates.

  <\equation>
    <with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <with|font-series|bold|u><rsub|H> = <frac|1|r sin<around*|(|\<theta\>|)>>
    <frac|\<partial\>|\<partial\>\<theta\>><around*|(|u<rsub|\<theta\>>
    sin<around*|(|\<theta\>|)>|)> + \ <frac|1|r sin<around*|(|\<theta\>|)>>
    <frac|\<partial\>u<rsub|\<phi\>>|\<partial\>\<phi\>>
  </equation>

  Finally, the induction equation in spherical coordinates reads

  <\equation>
    <tabular*|<tformat|<cwith|1|-1|3|3|cell-halign|l>|<table|<row|<cell|<frac|\<partial\>B<rsub|r>|\<partial\>t>>|<cell|=>|<cell|-<frac|1|r
    sin<around*|(|\<theta\>|)>> <around*|[|<frac|\<partial\>|\<partial\>\<theta\>><around*|(|u<rsub|\<theta\>>
    sin<around*|(|\<theta\>|)>|)>+<frac|\<partial\>u<rsub|\<phi\>>|\<partial\>\<phi\>>|]>B<rsub|r>
    >>|<row|<cell|>|<cell|->|<cell|<frac|1|r
    sin<around*|(|\<theta\>|)>><around*|[|u<rsub|\<theta\>>
    sin<around*|(|\<theta\>|)><frac|\<partial\>B<rsub|r>|\<partial\>\<theta\>>
    + u<rsub|\<phi\>> <frac|\<partial\>B<rsub|r>|\<partial\>\<phi\>>|]>>>>>>
  </equation>

  with the quasi-geostrophic constraint

  <\equation>
    <frac|1|sin<around*|(|\<theta\>|)>> <around*|[|<frac|\<partial\>|\<partial\>\<theta\>><around*|(|u<rsub|\<theta\>>
    sin<around*|(|\<theta\>|)>|)>+<frac|\<partial\>u<rsub|\<phi\>>|\<partial\>\<phi\>>|]>-
    u<rsub|\<theta\>> tan<around*|(|\<theta\>|)>= 0
  </equation>

  <appendix|Del in spherical coordinates>

  Recalling the usual (but useful) formulae of the del operator in spherical
  coordinates, applied either on a scalar field
  <math|F<around*|(|r,\<theta\>,\<phi\>|)>> or a vector field
  <math|<with|font-series|bold|F><around*|(|r,\<theta\>,\<phi\>|)>>.

  <subsection|Horizontal gradient>

  <\equation>
    <with|font-series|bold|\<nabla\>><rsub|H>F = <around*|(|<frac|1|r>
    <frac|\<partial\>F|\<partial\>\<theta\>>,<frac|1|r
    sin<around*|(|\<theta\>|)>> <frac|\<partial\>F|\<partial\>\<phi\>>|)>
  </equation>

  <subsection|Horizontal divergence>

  <\equation>
    <with|font-series|bold|\<nabla\>><rsub|H> \<cdot\>
    <with|font-series|bold|F><rsub|H> = <frac|1|r sin<around*|(|\<theta\>|)>>
    <frac|\<partial\>|\<partial\>\<theta\>><around*|(|F<rsub|\<theta\>>
    sin<around*|(|\<theta\>|)>|)> + \ <frac|1|r sin<around*|(|\<theta\>|)>>
    <frac|\<partial\>F<rsub|\<phi\>>|\<partial\>\<phi\>>
  </equation>

  \;
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|2>>
    <associate|auto-3|<tuple|3|3>>
    <associate|auto-4|<tuple|4|3>>
    <associate|auto-5|<tuple|4.1|4>>
    <associate|auto-6|<tuple|4.2|5>>
    <associate|auto-7|<tuple|A|5>>
    <associate|auto-8|<tuple|A.1|5>>
    <associate|auto-9|<tuple|A.2|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|1.1fn>Context>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|1.1fn>The
      geodynamo inverse problem> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|1.1fn>Tangential
      flow field> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|1.1fn>Inverting
      for the tangential core flow> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4><vspace|0.5fn>

      <with|par-left|<quote|1tab>|4.1<space|1.1fn>Framework
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1tab>|4.2<space|1.1fn>The equation and fields in
      spherical coordinates <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Appendix
      A<space|1.1fn>Del in spherical coordinates>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7><vspace|0.5fn>

      <with|par-left|<quote|1tab>|A.1<space|1.1fn>Gradient
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>
    </associate>
  </collection>
</auxiliary>