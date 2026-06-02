# Flutter Starter App

A reusable Flutter starter template for rapid Flutter application development.

## Features

- Multi-environment entrypoints: `lib/main_dev.dart`, `lib/main_sit.dart`, `lib/main.dart`
- Riverpod state management
- GoRouter based routing
- Dio based network layer
- Theme and localization scaffolding
- SharedPreferences utility and reusable UI components

## Getting Started

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

## Environment

Configure each environment in its own entrypoint by passing an `EnvConfig` to
`Application.run`. Replace the example domains, privacy policy URL, and user
agreement URL before using this template in production.
