# Story Stains

[![Backend](https://github.com/jacomago/storystains/actions/workflows/backend.yml/badge.svg)](https://github.com/jacomago/storystains/actions/workflows/backend.yml)
[![Frontend](https://github.com/jacomago/storystains/actions/workflows/frontend.yml/badge.svg)](https://github.com/jacomago/storystains/actions/workflows/frontend.yml)
[![codecov](https://codecov.io/gh/jacomago/storystains/branch/main/graph/badge.svg?token=RIHLTO9AAB)](https://codecov.io/gh/jacomago/storystains)

Yet another Goodreads alternative. Focusing on documenting the stain a story leaves behind and why.

Heavily inspired by [zero2prod](https://zero2prod.com) and [RealWorld](https://github.com/gothinkster/realworld) in particular [CodeIdeal's implementation](https://github.com/CodeIdeal/realworld_flutter) and
[snamiki1212's actix version](https://github.com/snamiki1212/realworld-v1-rust-actix-web-diesel).

## Backend

Backend is written in rust using the [actix-web](https://actix.rs/) framework. Use [rustup](https://rustup.rs/) to install.

### Backend commands

Test everything.

```sh
    cargo test
```

Check everything.

```sh
    cargo clippy
```

Format everything.

```sh
    cargo fmt
```

Build release version.

```sh
    cargo build --release
```

Update all packages.

```sh
    cargo update
```

Run version and recompile on changes

```sh
    cargo watch -x run
```

Update sqlx offline [files](/sqlx-data.json) for docker building. (use cargo install sqlx-cli to use)

```sh
    cargo sqlx prepare -- --lib      
```

Start up postgres docker container with a [script](/scripts/init_db.sh).

```sh
    ./scripts/init_db.sh
```

## Frontend

[Frontend](/frontend) written in Flutter. To install go to [Flutter install](https://docs.flutter.dev/get-started/install), it takes a while ...

### Frontend commands

Test everything.

```sh
    flutter test
```

Generate all auto-generated files.

```sh
    flutter pub run build_runner build --delete-conflicting-outputs
```

Run debug version in web with a specific port (useful for local testing)

```sh
    flutter run -d chrome --web-port=50547
```

Build a web release.

```sh
    flutter build web --release
```

Update all packages to latest acceptable with dependencies.

```sh
    flutter pub upgrade --major-versions
```

## Putting it all together

Using the [Dockerfile](/Dockerfile) will build a release version of the flutter front end which will be served by the actix backend. A parameter needed to be set is the FRONT_BASE_URL, which is the url called for doing requests to the backend api.

```sh
    docker build --tag storystains --file Dockerfile . --build-args FRONT_BASE_URL="http://localhost:8080/api"
```

### Deployment

Currently using [fly.io](http://fly.io) with their postgres instance.

```sh
    flyctl deploy --remote-only 
```

Listed in the [fly toml](/fly.toml) are secrets needed to be set on the instance. Other configuration is in [configuration](/configuration) for the backend, and in [AppConfig](/frontend/lib/common/constant/app_config.dart) for the front.
