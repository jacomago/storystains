# [Choice] Debian OS version (use bullseye on local arm64/Apple Silicon): buster, bullseye
ARG VARIANT="bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/rust:0-${VARIANT} AS rust_inbuilt

# Include lld linker to improve build times either by using environment variable
# RUSTFLAGS="-C link-arg=-fuse-ld=lld" or with Cargo's configuration file (i.e see .cargo/config.toml).
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install clang lld git gnupg curl file unzip wget xz-utils zip \
    && apt-get autoremove -y && apt-get clean -y

FROM rust_inbuilt as fluttersetup
# # Setup flutter
RUN cd /opt && \
    git clone https://github.com/flutter/flutter.git -b stable


ENV PATH=$PATH:/opt/flutter/bin

RUN flutter precache
RUN flutter doctor

RUN apt-get clean
RUN apt-get autoremove

FROM fluttersetup as devtime
# prebuild 
RUN cargo build