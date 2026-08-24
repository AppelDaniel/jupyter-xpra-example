#!/bin/bash

# Check prerequisites for conversion: MyST-NB package
python3 -c "import myst_nb"

# $? stores the exit value of the last command that was executed
if [[ $? -eq 0 ]]; then
  cd 04_tutorials
  cp index.md temp.md

  # Use the tutorial overview in 04_tutorials/index.md as start notebook (landing page) that references the tutorial notebooks
  # NOTE: Requires the preprocessing below, since the toctree directive cannot be parsed by mystnb and 04_tutorials/index.md references the md-files (instead of the ipynb-notebooks)
  # (1) Print links to tutorial notebooks, i.e. all lines between the "```{only} jupyter" ... "```" tags excluding the boundary lines themselves
  # (2) Remove "```{only} jupyter" directive, which cannot be parsed by mystnb-to-jupyter and is skipped by Sphinx when converting md -> html / latex
  # (3) Remove "```{toctree}" directive, which cannot be parsed by mystnb-to-jupyter but is used by Sphinx to insert the tutorial sections
  sed -i -e '/```{only} jupyter/,/```/{//!p}' -e '/```{only} jupyter/,/```/d' -e '/```{toctree}/,/```/d' index.md
  mystnb-to-jupyter -o index.md
  # Recover the original markdown file
  mv temp.md index.md

  # For each tutorial, convert myst-flavored markdown file to Jupyter notebook
  for f in */index.md
    do mystnb-to-jupyter -o $f
  done

  # Output info where the Jupyter notebooks are
  echo -e "\nThe Jupyter notebooks have been created. Run, e.g., 'jupyter lab 04_tutorials/01_linadv/index.ipynb' to launch a live tutorial."

  # Check prerequisites for live execution: bash kernel
  python3 -c "import bash_kernel"
  if [[ $? -ne 0 ]]; then
    echo -e "\nWarning: No bash kernel found! Install via 'pip install bash_kernel' to run tutorials interactively."
  fi
else
  echo -e "\nError: Could not build the Jupyter notebooks due to missing MyST-NB! Install via 'pip install myst-nb' and run the script again."
fi
