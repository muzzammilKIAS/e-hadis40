#!/bin/bash
cd "$(dirname "$0")"
flutter pub get || exit 1
flutter run -d chrome
