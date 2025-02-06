FROM nvidia/cuda:12.4.0-base-ubuntu22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    aria2 \
    build-essential \
    curl \
    git \
    tar \
    wget \
    unzip \
    vim \
    libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# Add conda to path
ENV PATH /opt/conda/bin:$PATH

# Install Python 3.11
RUN conda install -y python=3.11 -c conda-forge && \
    conda clean --all --yes

WORKDIR /opt
ADD . /opt/BindCraft/

WORKDIR /opt/BindCraft/

RUN bash install_bindcraft.sh --cuda '12.4' --pkg_manager 'conda'

# Set the default command to use conda
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["conda", "run", "-n", "base"]
