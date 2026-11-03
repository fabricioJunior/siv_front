#!/bin/sh
set -e
git clone https://github.com/flutter/flutter.git -b 3.47.1 --depth 1 _flutter_sdk
export PATH="$PWD/_flutter_sdk/bin:$PATH"
flutter config --enable-web --no-analytics
flutter pub get
# release = commit do deploy: o app (SENTRY_RELEASE) e o upload dos source maps usam o MESMO
# valor, que é o que o Sentry usa para casar o stack trace minificado com o map certo.
# --source-maps gera build/web/main.dart.js.map (sem a flag não há o que subir ao Sentry).
SENTRY_RELEASE_ID="${VERCEL_GIT_COMMIT_SHA:-local}"
flutter build web --release --source-maps \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE_ID

# Sem isso o Sentry nunca recebe o source map do build web -- todo stack trace de
# produção chega com tipos ofuscados tipo "minified:ach" em vez do nome real, e o
# erro fica impossível de rastrear até a origem. Precisa de SENTRY_AUTH_TOKEN nas
# env vars do projeto na Vercel (config de org/project já está em pubspec.yaml).
if [ -n "$SENTRY_AUTH_TOKEN" ]; then
  # commits=false: o clone da Vercel e raso, sem historico para associar commits ao release.
  # Falha no upload nunca deve derrubar o deploy.
  dart run sentry_dart_plugin \
    --sentry-define=release=$SENTRY_RELEASE_ID \
    --sentry-define=commits=false \
    || echo "ATENCAO: upload dos source maps ao Sentry falhou -- o deploy segue sem eles"
else
  echo "ATENCAO: SENTRY_AUTH_TOKEN nao configurado -- stack traces do Sentry vao continuar minificados"
fi

# Os .map nao devem ser servidos publicamente (exporiam o codigo-fonte): ficam so no Sentry.
rm -f build/web/*.map
