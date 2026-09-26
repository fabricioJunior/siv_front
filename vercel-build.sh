#!/bin/sh
set -e
git clone https://github.com/flutter/flutter.git -b 3.47.1 --depth 1 _flutter_sdk
export PATH="$PWD/_flutter_sdk/bin:$PATH"
flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release --dart-define=SENTRY_DSN=$SENTRY_DSN

# Sem isso o Sentry nunca recebe o source map do build web -- todo stack trace de
# produção chega com tipos ofuscados tipo "minified:ach" em vez do nome real, e o
# erro fica impossível de rastrear até a origem. Precisa de SENTRY_AUTH_TOKEN nas
# env vars do projeto na Vercel (config de org/project já está em pubspec.yaml).
if [ -n "$SENTRY_AUTH_TOKEN" ]; then
  dart run sentry_dart_plugin
else
  echo "SENTRY_AUTH_TOKEN nao configurado -- pulando upload de source maps pro Sentry"
fi
