---
file_format: mystnb
kernelspec:
  name: bash
  language: bash
---

(Tutorials)=
# Tutorials

This chapter provides a detailed overview of flow simulations with **FLEXI**, assuming familiarity with setting compiler options and code compilation.

The compiler settings of each tutorial are provided as a CMake preset, which contains both the build options themselves (`configurePreset`) and the tutorial's directory as the build folder (`buildPreset`). Compiling the **flexi** executable thus reduces to executing
```{code-block} bash
cmake --preset <preset_name>
cmake --build --preset <preset_name>
```
from the top-level directory, in the following replaced by `FLEXI_ROOT`. Meanwhile, **hopr** is assumed to be already installed on your system.
Besides, a tutorial directory contains the necessary .ini files - `parameter_hopr.ini`, `parameter_flexi.ini`, `parameter_postiVisu.ini` - as well as the mesh file `*_mesh.h5` in HDF5 format (generated with **HOPR**).
```{code-block} bash
---
caption: Directory tree for a tutorial.
---
tutorial
├── mesh.h5
├── parameter_flexi.ini
├── parameter_hopr.ini
└── parameter_postiVisu.ini
```

```{tip}
While each tutorial can be run directly in its own directory, we recommend copying each folder to a new directory. This way, you can run the simulations and freely modify the .ini files without altering the original setup.
```

```{toctree}
---
maxdepth: 1
caption: Table of Contents
---
01_linadv/index.md
02_freestream/index.md
03_convtest/index.md
04_cavity/index.md
05_tgv/index.md
06_sod/index.md
07_dmr/index.md
08_channel/index.md
09_cylinder/index.md
10_naca0012/index.md
```

```{only} jupyter
**Table of Contents**
1. [Linear Scalar Advection-Diffusion Equation](01_linadv/index.ipynb)
2. [Freestream](02_freestream/index.ipynb)
3. [Convergence Test](03_convtest/index.ipynb)
4. [Lid-driven Cavity](04_cavity/index.ipynb)
5. [Taylor--Green Vortex](05_tgv/index.ipynb)
6. [Sod Shock Tube](06_sod/index.ipynb)
7. [Double Mach Reflection](07_dmr/index.ipynb)
8. [Plane Turbulent Channel Flow](08_channel/index.ipynb)
9. [Flow Around a Cylinder](09_cylinder/index.ipynb)
10. [Flow Around a NACA0012 Airfoil](10_naca0012/index.ipynb)
```
