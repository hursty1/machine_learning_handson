FROM nvidia/cuda:12.0.1-cudnn8-runtime-ubuntu22.04

LABEL authors="Daniel Hayhurst <danhursty@gmail.com>"

RUN chmod 1777 /tmp && chmod 1777 /var/tmp

# install apt-utils in header to fix warnings in docker-stacks
RUN apt-get update && \
    apt-get -y install apt-utils

############################################################################
#################### Dependency: python  ###################################
############################################################################
ARG PYTHON_VERSION=3.10.4
FROM python:3.10.4
USER root
RUN apt-get update --yes && \
    # - `apt-get upgrade` is run to patch known vulnerabilities in apt-get packages as
    #   the Ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    locales \
    sudo \
    # - tini is installed as a helpful container entrypoint that reaps zombie
    #   processes and such of the actual executable we want to start, see
    #   https://github.com/krallin/tini#why-tini for details.
    tini \
    dvipng \
    # for matplotlib anim
    ffmpeg \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install useful packages and Graphviz
RUN apt-get update \
 && apt-get -y install --no-install-recommends htop apt-utils iputils-ping graphviz libgraphviz-dev openssh-client \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


WORKDIR /app

#copy the current directory contents into the container at  / app
COPY . /app

############################################################################
#################### Dependency: RUST  #####################################
############################################################################

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.74
ENV RUSTUP_VERSION=1.25.1
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='5cc9ffd1026e82e7fb2eec2121ad71f4b0f044e88bca39207b3f6b769aaa799c' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='e189948e396d47254103a49c987e7fb0e5dd8e34b200aa4481ecc4b8e41fb929' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain ${RUST_VERSION}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

############################################################################
############################ Useful packages ###############################
############################################################################

# RUN pip --no-cache-dir install numpy pandas seaborn sklearn
RUN pip install --upgrade pip && \
    pip install --no-cache-dir tensorflow==2.15.0 keras==2.15.0 && \
    pip --no-cache-dir install numpy pandas seaborn scikit-learn && \
    pip install --no-cache-dir install torch torchvision torchaudio && \ 
    pip --no-cache-dir install jupyterlab && \
    pip --no-cache-dir install -r requirements.txt

############################################################################
############################ RUST packages #################################
############################################################################

RUN cargo install evcxr_jupyter \
    && evcxr_jupyter --install


EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]