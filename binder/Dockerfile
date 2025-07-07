FROM quay.io/jupyter/minimal-notebook:notebook-7.4.3

# Step 1: Switch to root to install system packages
USER root

# Step 2: Install xpra and its dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    xpra \
    xauth \
    xterm \
    python3-gi \
    libdbus-glib-1-2 \
    python3-cryptography \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Install jupyter-xprahtml5-proxy (to integrate Xpra in JupyterLab)
RUN pip install --no-cache-dir jupyter-xprahtml5-proxy

# Step 4: Switch back to notebook user
USER ${NB_UID}

RUN echo 'c.ServerProxy.autostart = ["code"]' >> /etc/jupyter/jupyter_server_config.py
