#!/bin/bash
cd "$(dirname "$0")"
flutter pub get || exit 1
flutter build web || exit 1
open build/web
