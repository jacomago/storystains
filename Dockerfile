#Stage 1 - Install dependencies and build the app
FROM debian:stable AS frontflutterget
WORKDIR /root

# Setup apt packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    git \
    gnupg \
    curl \
    file \
    unzip \
    wget \
    xz-utils \
    zip

# # Setup flutter
RUN cd /opt && \
    git clone https://github.com/flutter/flutter.git -b stable 

ENV PATH=$PATH:/opt/flutter/bin

RUN flutter precache
RUN flutter doctor
RUN apt-get clean
RUN apt-get autoremove

FROM frontflutterget as frontpubactions
# Copy files to container and build
RUN mkdir /app/
COPY ./frontend /app/
WORKDIR /app/
RUN flutter pub get
RUN flutter pub run build_runner build

FROM frontpubactions as frontbuild
# Copy files to container and build
WORKDIR /app/
ARG FRONT_BASE_URL
RUN flutter build web --web-renderer canvaskit --release --dart-define BASE_URL=${FRONT_BASE_URL}

FROM lukemathwalker/cargo-chef:latest-rust-1.61 as chef
WORKDIR /app
RUN apt update && apt install lld clang -y

FROM chef as planner
COPY ./backend .
# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release --recipe-path recipe.json
# Up to this point, if our dependency tree stays the same,
# all layers should be cached.
COPY ./backend .
ENV SQLX_OFFLINE true
# Build our project
RUN cargo build --release --bin storystains

FROM debian:bullseye-slim AS runtime
WORKDIR /app
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/storystains storystains
COPY --from=builder /app/assets/images static/images
COPY --from=frontbuild /app/build/web static/root
COPY ./backend/configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./storystains"]