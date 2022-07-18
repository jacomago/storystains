
# Backend

Backend is written in rust using the [actix-web](https://actix.rs/) framework. Use [rustup](https://rustup.rs/) to install.

## Backend commands

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
