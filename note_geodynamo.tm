<TeXmacs|2.1.4>

<style|<tuple|elsarticle|number-long-article|british>>

<\body>
  <doc-data|<doc-title|Machine Learning for the geodynamo
  inverse<next-line>problem>|<doc-subtitle|Physics-informed Neural
  Network>|<doc-date|<date>>|<doc-author|<author-data|<author-name|Romain
  Claveau>>>>

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
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|2>>
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
    </associate>
  </collection>
</auxiliary>