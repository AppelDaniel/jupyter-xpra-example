# =================================================================================================
# Ubuntu-based FLEXI environment including ParaView and HOPR / PyHOPE
# build docker image with github namespace:          docker build -t ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_vscode --build-arg BUILDTARGET=minimal .
# launch with X11-forwarding [BUILDTARGET=minimal]:  xhost +local:docker && docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_vscode
# launch starting Jupyter    [BUILDTARGET=jupyter]:  docker run --rm -it -p 8888:8888 ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_vscode jupyter lab --ip=0.0.0.0 --no-browser --allow-root
# launch as root user        [BUILDTARGET=jupyter]:  docker run --rm -it --user root -e NB_USER="root" -e NB_UID=0 -e NB_GID=0 ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_vscode bash
# ==================================================================================================

# Build argument to optionally skip Jupyter-specific images layers and thereby reduce the image size (--build-arg BUILDTARGET=minimal)
ARG BUILDTARGET=jupyter

# Set default root image: Jupyter docker-stacks-foundation
# > Dockerfile:              https://github.com/jupyter/docker-stacks/blob/main/images/docker-stacks-foundation/Dockerfile
# > Quay container registry: https://quay.io/repository/jupyter/docker-stacks-foundation?tab=tags
# NOTE: Pull image by digest instead of tag (python-3.13) for reproducibility of docker image itself
FROM quay.io/jupyter/docker-stacks-foundation@sha256:e9aa9f644b219a0e9d59af91c51fc86c22c30a91e740257771560849bc4cb7ea AS jupyter
FROM ubuntu:26.04                                                                                                     AS minimal


# =================================================================================================
# 0. Setup FLEXI environment as root [independent from BUILDTARGET]
# =================================================================================================

# Load root image
FROM $BUILDTARGET AS minimal0

# Numerics Research Group
LABEL maintainer="Numerics Reseach Group, University of Stuttgart <numerics@iag.uni-stuttgart.de>"

# Configure system environment:
# - Use timezone (TZ) of Berlin as default
# - Suppress user-interaction during package installation (e.g. timezone configuration dialog of tzdata)
# - Set default locale for consistent build behavior and enabled non-ASCII keys (e.g. Umlaute): C = computer language, UTF-8 = utf8-encoding
# - Set bash as default shell (especially for the terminal in Jupyter notebooks)
ENV TZ=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    SHELL=/bin/bash

# Install basic packages and libraries as root
USER root

# Setup required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Utility
    vim nano tzdata tree eog git git-lfs wget curl tar bzip2 build-essential \
    # FLEXI environment
    cmake cmake-curses-gui gfortran zlib1g-dev python3-dev python3-pip python3-venv python-is-python3 \
    # PyHOPE
    libxft-dev libxfixes3 \
    # ParaView setup
    mesa-common-dev libglu1-mesa-dev libgl1-mesa-dev libegl1-mesa-dev \
    qtbase5-dev qt5-qmake libqt5x11extras5-dev libqt5opengl5-dev libqt5help5 qtbase5-dev-tools qttools5-dev qtxmlpatterns5-dev-tools libqt5svg5-dev && \
    # reduce image size
    apt-get clean -y && apt-get autoremove -y --purge && rm -rf /var/lib/apt/lists/*

# Setup build environment, disabling CPU-specific optimizations to ensure portability of image:
# position-independent code (PIC) for shared libraries, compatibility with x86-64 processors, generic CPU scheduler
ENV CPU_PORTABLE_FLAGS="-fPIC -march=x86-64 -mtune=generic"
ENV CC=gcc \
    CXX=g++ \
    FC=gfortran \
    F90=gfortran \
    CFLAGS=${CPU_PORTABLE_FLAGS} \
    CXXFLAGS=${CPU_PORTABLE_FLAGS} \
    CPPFLAGS=${CPU_PORTABLE_FLAGS} \
    FFLAGS=${CPU_PORTABLE_FLAGS} \
    FCFLAGS=${CPU_PORTABLE_FLAGS}

# Setup OpenBLAS, ensure cross-platform portability by building library for multiple targets and detecting CPU at runtime (DYNAMIC_ARCH=ON)
RUN OPENBLAS_VERSION=0.3.33 && cd /tmp && \
    wget https://github.com/OpenMathLib/OpenBLAS/archive/refs/tags/v${OPENBLAS_VERSION}.tar.gz && \
    tar -xvf v${OPENBLAS_VERSION}.tar.gz && \
    cd OpenBLAS-${OPENBLAS_VERSION} && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt -DDYNAMIC_ARCH=ON .. && \
    make -j$(nproc) && cmake --install . && \
    cd /tmp && rm -rf OpenBLAS* && rm -rf v${OPENBLAS_VERSION}.tar.gz

# Setup OpenMPI
RUN OPENMPI_VERSION=5.0.10 && cd /tmp && \
    wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-${OPENMPI_VERSION}.tar.bz2 && \
    tar -xvf openmpi-${OPENMPI_VERSION}.tar.bz2 && \
    cd openmpi-${OPENMPI_VERSION} && \
    ./configure --prefix=/opt && \
    make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf openmpi*

# Setup HDF5
RUN HDF5_VERSION=2.1.1 && cd /tmp && \
    wget https://github.com/HDFGroup/hdf5/releases/download/${HDF5_VERSION}/hdf5-${HDF5_VERSION}.tar.gz && \
    tar -xvf hdf5-${HDF5_VERSION}.tar.gz && \
    cd hdf5-${HDF5_VERSION} && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt \
          -DHDF5_BUILD_FORTRAN=ON \
          -DHDF5_ENABLE_PARALLEL=ON \
          -DHDF5_USE_ZLIB_STATIC=ON \
          -DZLIB_USE_EXTERNAL=ON \
          .. && \
    make -j$(nproc) && cmake --install . && \
    cd /tmp && rm -rf hdf5*

# Setup FFTW
RUN FFTW_VERSION=3.3.11 && cd /tmp && \
    wget https://fftw.org/fftw-${FFTW_VERSION}.tar.gz && \
    tar -xvf fftw-${FFTW_VERSION}.tar.gz && \
    cd fftw-${FFTW_VERSION} && \
    ./configure --prefix=/opt && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf fftw*

# Setup CGNS
RUN CGNS_VERSION=4.5.2 && cd /tmp && \
    wget https://github.com/CGNS/CGNS/archive/refs/tags/v${CGNS_VERSION}.tar.gz && \
    tar -xvf v${CGNS_VERSION}.tar.gz && \
    cd CGNS-${CGNS_VERSION} && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt \
          -DCGNS_ENABLE_FORTRAN=ON \
          -DCGNS_ENABLE_64BIT=ON \
          -DCGNS_BUILD_SHARED=OFF \
          -DCGNS_USE_SHARED=OFF \
          -DCMAKE_BUILD_TYPE=Release \
          -DCGNS_BUILD_CGNSTOOLS=OFF \
          -DCGNS_ENABLE_HDF5=ON \
          -DHDF5_NEED_MPI=ON \
          -DCGNS_ENABLE_PARALLEL=OFF \
          -DCGNS_ENABLE_TESTS=OFF \
          -DCMAKE_SKIP_RPATH=ON \
          .. && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf v* CGNS-*

# Setup ParaView (self-built for POSTI plug-in)
# NOTE: Ubuntu24 apt-repository provides v5.11.2 which suffers from XML-parsing bug (https://discourse.paraview.org/t/i-cannot-read-a-vtp-file-i-could-open-yesterday-can-someone-try-to-open-it/13938)
COPY binder/FileParser_5_9_0.patch /tmp
RUN PARAVIEW_VERSION=6.1.1 && cd /tmp && \
    wget https://www.paraview.org/files/v${PARAVIEW_VERSION%??}/ParaView-v${PARAVIEW_VERSION}.tar.gz && \
    tar -xvf ParaView-v${PARAVIEW_VERSION}.tar.gz && \
    cd ParaView-v${PARAVIEW_VERSION} && \
    mv /tmp/FileParser_5_9_0.patch . && patch -p0 < FileParser_5_9_0.patch && \
    mkdir build && cd build/ && \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DPARAVIEW_USE_MPI=ON \
      -DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON \
      -DPARAVIEW_USE_PYTHON=ON \
      -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
      -DHDF5_IS_PARALLEL=ON \
      -DHDF5_DIR=/opt/cmake \
      -DCMAKE_INSTALL_PREFIX=/opt \
      ../ && \
    make -j $(nproc) && make install && \
    cd /tmp && rm -rf ParaView*


# =================================================================================================
# 1. Create new user to install FLEXI [dependent on BUILDTARGET]
# =================================================================================================

# [BUILDTARGET=minimal]
FROM minimal0 AS minimal1

# Set name and user/group ID of non-root user to "jovyan" (default of Jupyter-notebooks)
ARG NB_USER=jovyan
ARG NB_UID=1000
ARG NB_GID=100

# Delete existing user with UID="${NB_UID}" if it exists
RUN if id -un "${NB_UID}" >/dev/null 2>&1; then \
        userdel --remove "$(id -un "${NB_UID}")"; \
    fi && \
    useradd --no-log-init --create-home --shell /bin/bash --uid "${NB_UID}" --gid ${NB_GID} --no-user-group "${NB_USER}"

# Switch to non-root user
USER ${NB_USER}

# Create virtualenv and enable it to allow for pip installations
RUN cd /home/${NB_USER} && python -m venv venv
ENV PATH="/home/${NB_USER}/venv/bin:$PATH"

# -------------------------------------------------------------------------------------------------

# [BUILDTARGET=jupyter]
FROM minimal0 AS jupyter1

# NOTE: No virtualenv necessary for pip installations due to activated conda environment

# Switch to non-root user
USER ${NB_USER}


# =================================================================================================
# 2. Install FLEXI and HOPR / PyHOPE [independent from BUILDTARGET]
# =================================================================================================

# Start from either of the previous stages
FROM ${BUILDTARGET}1 AS minimal2

# FLEXI environment installed to /opt, hence include directory in PATH variable
ENV PATH="/opt/bin:$PATH"

# Setup vim
COPY binder/vimrc /home/${NB_USER}/.vimrc

# Avoid ParaView warnings:
# - Create runtime directory for Qt applications manually under default path to avoid warning when building ParaView plugin
# - Enforce software rendering (Mesa) to avoid warning when launching ParaView
ENV XDG_RUNTIME_DIR=/tmp/runtime-${NB_USER} \
    LIBGL_ALWAYS_SOFTWARE=TRUE
RUN mkdir ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR}

# Setup HOPR
RUN cd /home/${NB_USER} && \
    git clone https://github.com/hopr-framework/hopr.git && \
    cd hopr && mkdir build && cd build && \
    cmake -DLIBS_BUILD_HDF5=OFF -DLIBS_BUILD_CGNS=OFF -DHOPR_INSTRUCTION='-march=x86-64 -mtune=generic' ../ && \
    make -j $(nproc)
ENV PATH="/home/${NB_USER}/hopr/build/bin:$PATH"

# Setup PyHOPE
# NOTE: Install editable from GitHub repository (instead of PyPI) to provide tutorials for verification run and remove created mesh files afterwards
RUN cd /home/${NB_USER} && \
    pip install --no-cache-dir https://piclas.boltzplatz.eu/public-libs/python-gmsh/-/raw/master/gmsh-4.15.2.post1-py3-none-linux_x86_64.whl && \
    git clone https://github.com/hopr-framework/PyHOPE.git && \
    pip install --no-cache-dir -e PyHOPE && \
    cd PyHOPE && pyhope --verify && \
    git clean -fX .

# Download FLEXI (installation depends on BUILDTARGET)
RUN cd /home/${NB_USER} && \
    git clone https://github.com/flexi-framework/flexi.git
# Export path to FLEXI root directory since required to define workdir when launching container and to step through tutorial notebooks
ENV FLEXI_ROOT=/home/${NB_USER}/flexi


# =================================================================================================
# 3. Setup Jupyter environment (optionally) and define default command [dependent on BUILDTARGET]
# =================================================================================================

# [BUILDTARGET=minimal]
FROM minimal2 AS minimal3

# Pre-build FLEXI only in default configuration, without CPU-specific optimizations to ensure portability
RUN cd ${FLEXI_ROOT} && \
    cmake -DFLEXI_INSTRUCTION='-march=x86-64 -mtune=generic' -B build && cmake --build build -j ${nproc}

# Default command
CMD ["/bin/bash"]

# -------------------------------------------------------------------------------------------------

# [BUILDTARGET=jupyter]
FROM minimal2 AS jupyter3

# Pre-build FLEXI for all tutorials using the presets, without CPU-specific optimizations to ensure portability
RUN cd ${FLEXI_ROOT} && \
    for PRESET in $(cmake --list-presets | sed -n 's/"\(.*\)"/\1/p'); do \
        cmake -DFLEXI_INSTRUCTION='-march=x86-64 -mtune=generic' --preset $PRESET && cmake --build --preset $PRESET -j ${nproc}; \
    done

# replace current documentation -> TODO remove once merged into master
# NOTE: Since image is built from FLEXI root directory "docker build -f binder/Dockerfile ." no named context is needed to specify the path to the docs files
COPY --chown=${NB_UID}:${NB_GID} ./docs/documentation ${FLEXI_ROOT}/docs/documentation
# docker build -t ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_jupyter --build-arg BUILDTARGET=jupyter --build-context docs=../../docs .
#COPY --chown=${NB_UID}:${NB_GID} --from=docs ./docs/documentation ${FLEXI_ROOT}/docs/documentation
# Enable Jupyter-based tutorials: install Sphinx/MyST packages, register bash kernel, generate notebooks
RUN pip install --no-cache-dir -r ${FLEXI_ROOT}/docs/documentation/requirements.txt && \
    python -m bash_kernel.install && \
    cd ${FLEXI_ROOT}/docs/documentation && ./buildJupyter.sh

# Install Jupyter
# NOTE: jupyterlab_myst in requirements.txt is set to minimum version 4.6. due to a rendering issue with links (https://github.com/jupyter-book/jupyterlab-myst/issues/248)
RUN pip install --no-cache-dir \
    numpy matplotlib h5py notebook jupyterlab jupyterhub ipykernel \
    # packages required for NFDI JupyterHub by JSC (https://hub.nfdi-jupyter.de/hub/home)
    jupyter-collaboration jupyterlab-hub-credit-extension jupyterlab-data-mount
# Enable JupyterLab in container
ENV JUPYTER_ENABLE_LAB=yes

# Install Jupyter-remote-desktop-proxy package to run XFCE desktop environment in Jupyter
# > Documentation / Dockerfile: https://github.com/jupyterhub/jupyter-remote-desktop-proxy
RUN pip install --no-cache-dir jupyter-remote-desktop-proxy
# Install the packages needed to provide the VNC server (TigerVNC) and the actual Linux Desktop environment (Xubuntu)
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs npm dbus-x11 curl \
    # xclip is added as jupyter-remote-desktop-proxy's tests requires it
    xclip \
    # XFCE desktop environment
    xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme fonts-dejavu \
    # TigerVNC server
    tigervnc-standalone-server && \
    # Disable the automatic screenlock since the account password is unknown
    apt-get -y -qq remove xfce4-screensaver && \
    # chown $HOME to workaround that the xorg installation creates a /home/jovyan/.cache directory owned by root
    chown -R $NB_UID:$NB_GID $HOME && \   
    rm -rf /var/lib/apt/lists/*

# Integrate VS Code adaptation by Code-Server in JupyterLab environment (requires jupyter-server-proxy)
# > Documentation: https://github.com/coder/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    # Remove deb package file
    rm -r /home/${NB_USER}/.cache/code-server/ && \
    # Install VS Code proxy for Jupyter Lab integration, and Fortran language server for "Modern Fortran" extension
    pip install jupyter-vscode-proxy fortls && \
    fix-permissions "/home/${NB_USER}/.cache"

# JupyterHub helper scripts
# > Taken from: https://github.com/jupyter/docker-stacks/tree/main/images/base-notebook
COPY binder/start-singleuser.sh binder/start-notebook.sh binder/start-singleuser.py binder/start-notebook.py  /usr/local/bin/
COPY binder/jupyter_server_config.py binder/docker_healthcheck.py                                             /etc/jupyter/

# Adjust permissions and ownerships using fix-permissions script from root image (docker-stacks-foundation)
RUN chmod +x \
    /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.sh \
    /usr/local/bin/start-singleuser.py /usr/local/bin/start-notebook.py && \
    /usr/local/bin/fix-permissions /etc/jupyter

# Enable JupyterLab in container and expose port for it
ENV JUPYTER_ENABLE_YES=yes \
    JUPYTER_PORT=8888
EXPOSE ${JUPYTER_PORT}

# Start JupyterLab upon container launchi and show default notebook (see configuration in jupyter_server_config.py)
CMD ["start-notebook.py"]

# Healthcheck
# > Documentation: https://docs.docker.com/reference/dockerfile#healthcheck
HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 \
    CMD ["/etc/jupyter/docker_healthcheck.py"]

# Switch (back) to user
USER $NB_USER

# Pre-install "Modern Fortran" VS Code extension from Coder extension marketplace
RUN code-server --install-extension fortran-lang.linter-gfortran


# =================================================================================================
# 4. Switch to user and finalize [independent from BUILDTARGET]
# =================================================================================================

# Start from either of the previous stages
FROM ${BUILDTARGET}3 AS minimal4

# Define working directory when launching container:
# Should be FLEXI root for 'minimal' build due to convenience, must be FLEXI root for 'jupyter' build as documentation references tutorial parameter files
WORKDIR ${FLEXI_ROOT}

# Switch (back) to user
USER ${NB_USER}
