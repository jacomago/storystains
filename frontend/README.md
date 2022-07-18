# storystains

A new Flutter project.

## Frontend commands

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
