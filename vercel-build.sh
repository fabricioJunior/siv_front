#!/bin/sh
set -e
git clone https://github.com/flutter/flutter.git -b 3.47.1 --depth 1 _flutter_sdk
export PATH="$PWD/_flutter_sdk/bin:$PATH"
flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release --dart-define=SENTRY_DSN=$SENTRY_DSN
