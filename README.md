# Three D Radio Player

[![ThreeDRadio](https://circleci.com/gh/ThreeDRadio/threedradio-app.svg?style=shield)](https://app.circleci.com/pipelines/github/ThreeDRadio/threedradio-app)

This is [Three D Radio's](https://www.threedradio.com) app for live and on demand streaming.

This app is built with [Flutter](https://flutter.dev). Here are some technology buzzwords for the main tools we are using:

- [Dart](https://dart.dev) and [Flutter](https://flutter.dev)
- [Redux](https://github.com/johnpryan/redux.dart) for state management, including:
  - [Redux Entity](https://github.com/MichaelMarner/dart_redux_entity) for storing collections in the Redux store
  - [Redux Epics](https://pub.dartlang.org/packages/redux_epics) for asynchronous work
  - [Redux Remote Devtools](https://pub.dev/packages/redux_remote_devtools) for debugging the Redux store
- [Swagger CodeGen](https://bitbucket.org/careapp-inc/careapp-dart-api/src/master/) for automatically building the API code
- [audio_service](https://pub.dev/packages/audio_service) for handling background audio
- [just_audio](https://pub.dev/packages/just_audio) for audio playback

## Getting Started

- **Install Flutter**. We are keeping up with the latest Beta. So make sure you run `flutter channel beta` and regularly run `flutter upgrade` to stay in sync.
- If you're using VS Code with the Flutter plugin, dependencies will be installed automatically
- Run build runner to generate api types: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- `flutter run`

## Contributing

1. Fork this repo & create yourself a branch
1. Make your code changes
   - Make your code changes
1. Write tests
   - Write tests for all new code
   - Use golden files for testing appearance
1. Make sure you fix any dart analysis problems
1. Make sure tests pass
1. Create your Pull Request

We use the same analysis options as Flutter.

## Deployment

The app is automatically deployed to Play Store Internal testing and TestFlight Internal Testing with every merge to `master`. For more information have a look in the CircleCI config file.

Promotion to production is done manually through the Play/AppStoreConnect console.
