# Story Stains

[![Backend](https://github.com/jacomago/storystains/actions/workflows/backend.yml/badge.svg)](https://github.com/jacomago/storystains/actions/workflows/backend.yml)
[![Frontend](https://github.com/jacomago/storystains/actions/workflows/frontend.yml/badge.svg)](https://github.com/jacomago/storystains/actions/workflows/frontend.yml)
[![codecov](https://codecov.io/gh/jacomago/storystains/branch/main/graph/badge.svg?token=RIHLTO9AAB)](https://codecov.io/gh/jacomago/storystains)

A mood tracker for stories. Find the patterns in your favorite stories.

## Design

Heavily inspired by [zero2prod](https://zero2prod.com) and [RealWorld](https://github.com/gothinkster/realworld) in particular [CodeIdeal's implementation](https://github.com/CodeIdeal/realworld_flutter) and
[snamiki1212's actix version](https://github.com/snamiki1212/realworld-v1-rust-actix-web-diesel).

## Requirements

- Backend
  - rust  (use [rustup](https://rustup.rs/) to install)
  - sqlx-cli (for running migrations)
  - Docker (for running Redis and Postgres)
- Frontend
  - flutter (To install go to [Flutter install](https://docs.flutter.dev/get-started/install), it takes a while ...)
- Deployment
  - Using [fly](http://fly.io) (since using docker other sites are easy to setup)

## Putting it all together

Using the [Dockerfile](/Dockerfile) will build a release version of the flutter front end which will be served by the actix backend. A parameter needed to be set is the FRONT_BASE_URL, which is the url called for doing requests to the backend api.

```sh
    docker build --tag storystains --file Dockerfile . --build-args FRONT_BASE_URL="http://localhost:8080/api"
```

### Deployment

Currently using [fly.io](http://fly.io) with their Postgres instance and using a Redis instance.

```sh
    flyctl deploy --remote-only 
```

Listed in the [fly toml](/fly.toml) are secrets needed to be set on the instance. Other configuration is in [configuration](/configuration) for the backend, and in [AppConfig](/frontend/lib/common/constant/app_config.dart) for the front.
