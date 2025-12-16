FROM ghcr.io/flexi-framework/ubuntu24.04_gcc:v2025.10.0
ARG NB_USER=jovyan
ARG NB_UID=1001
ARG NB_GID=1001

# Install Jupyter
# NOTE: jupyterlab is pinned to version 4.2 since links are no longer highlighted as of version 4.3 with jupyterlab-myst
#       see this issue: https://github.com/jupyter-book/jupyterlab-myst/issues/248
RUN pip install --no-cache-dir \
    numpy matplotlib h5py notebook 'jupyterlab==4.2' jupyterhub ipykernel

## replace current documentation -> TODO remove once merged into master
## docker build -t ghcr.io/flexi-framework/ubuntu24.04_gcc:devel_jupyter --build-arg BUILDMODE=jupyter --build-context docs=../../docs .
#COPY --chown=${NB_UID}:${NB_GID} --from=docs documentation /home/${NB_USER}/flexi/docs/documentation
## Enable Jupyter-based tutorials: install Sphinx/MyST packages, register bash kernel, generate notebooks
#RUN pip install --no-cache-dir -r flexi/docs/documentation/requirements.txt && \
#    python -m bash_kernel.install && \
#    cd /home/${NB_USER}/flexi/docs/documentation && ./buildJupyter.sh
## Export path to FLEXI root directory since required for navigating through tutorials
#ENV FLEXI_ROOT=/home/${NB_USER}/flexi

# Install PyVista for basic visualization of VTU files within Jupyter
# https://github.com/pyvista/pyvista/tree/main/docker
RUN pip install --no-cache-dir \
    'pyvista[all]' 'ipywidgets<9.0.0' jupyter-server-proxy meshio trimesh 'trame>=2.5.2' 'trame-vtk>=2.5.8' 'trame-vuetify>=2.3.1'
# Enable JupyterLab in container, configure PyVista/Trame for remote Jupyter environment
ENV JUPYTER_ENABLE_LAB=yes \
    PYVISTA_TRAME_SERVER_PROXY_PREFIX='/proxy/'

# Install Jupyter-remote-desktop-proxy package to run XFCE desktop environment in Jupyter
# https://github.com/jupyterhub/jupyter-remote-desktop-proxy
RUN pip install --no-cache-dir jupyter-remote-desktop-proxy
# Install the packages needed to provide the VNC server (TigerVNC) and the actual Linux Desktop environment (Xubuntu)
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs npm dbus-x11 \
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

# TODO should be in base image
# Copy and execute script to correct permissions
# Taken from: https://github.com/jupyter/docker-stacks/tree/main/images/docker-stacks-foundation
COPY binder/fix-permissions.sh /usr/local/bin/fix-permissions.sh
RUN chmod +x /usr/local/bin/fix-permissions.sh

# JupyterHub helper scripts
# Taken from: https://github.com/jupyter/docker-stacks/tree/main/images/base-notebook
COPY binder/start-singleuser.sh binder/start-notebook.sh binder/start-singleuser.py binder/start-notebook.py  /usr/local/bin/
COPY binder/jupyter_server_config.py binder/docker_healthcheck.py                                             /etc/jupyter/

# Adjust permissions and ownerships
RUN chmod +x \
    /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.sh \
    /usr/local/bin/start-singleuser.py /usr/local/bin/start-notebook.py && \
    /usr/local/bin/fix-permissions.sh /etc/jupyter

# Configure container startup, ensuring that JupyterHub can intially change to relative directory "home/jovyan"
ENV JUPYTER_PORT=8888
EXPOSE ${JUPYTER_PORT}
WORKDIR /
CMD ["start-notebook.py"]

# Healthcheck
HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 \
    CMD /etc/jupyter/docker_healthcheck.py || exit 1

# Switch (back) to user
USER $NB_USER
