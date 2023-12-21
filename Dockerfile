#use the latest python runtime as a parent image
FROM python:3.10.10-buster
#3.8.9

#Set the working directory to /app
WORKDIR /app

#copy the current directory contents into the container at  / app
COPY . /app

#install rust
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

#install the required libaries

# RUN pip --no-cache-dir install numpy pandas seaborn sklearn
RUN pip --no-cache-dir install jupyterlab
RUN pip --no-cache-dir install -r requirements.txt
#make port 8888 availalble to outside of this container
EXPOSE 8888

RUN cargo install evcxr_jupyter \
    && evcxr_jupyter --install
#Run jupyter when container launches
ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]