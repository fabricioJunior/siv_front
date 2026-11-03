#!/bin/sh
set -e
git clone https://github.com/flutter/flutter.git -b 3.47.1 --depth 1 _flutter_sdk
export PATH="$PWD/_flutter_sdk/bin:$PATH"
flutter config --enable-web --no-analytics
flutter pub get

# Em PRODUCAO o app nao sobe sem Sentry (DSN no app + token para subir os source maps):
# qualquer falha derruba o build. Em preview/outros ambientes so avisa, para PRs e o projeto
# de teste nao quebrarem se a variavel nao estiver configurada la.
ESTRITO=""
[ "$VERCEL_ENV" = "production" ] && ESTRITO=1
sentry_falha() {
  echo "ERRO SENTRY: $1"
  if [ -n "$ESTRITO" ]; then
    echo "Build de producao interrompido: o app nao pode ser publicado sem o Sentry configurado."
    exit 1
  fi
  echo "(ambiente nao-producao: seguindo sem Sentry)"
}
[ -n "$SENTRY_DSN" ] || sentry_falha "SENTRY_DSN nao configurado -- o app nao enviaria erros ao Sentry"
[ -n "$SENTRY_AUTH_TOKEN" ] || sentry_falha "SENTRY_AUTH_TOKEN nao configurado -- source maps nao seriam enviados"
# release = commit do deploy: o app (SENTRY_RELEASE) e o upload dos source maps usam o MESMO
# valor, que é o que o Sentry usa para casar o stack trace minificado com o map certo.
# --source-maps gera build/web/main.dart.js.map (sem a flag não há o que subir ao Sentry).
SENTRY_RELEASE_ID="${VERCEL_GIT_COMMIT_SHA:-local}"
flutter build web --release --source-maps \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE_ID

# Sem os source maps no Sentry, todo stack trace de producao chega minificado ("minified:ach").
# Config de org/project em pubspec.yaml.
if [ -n "$SENTRY_AUTH_TOKEN" ]; then
  [ -f build/web/main.dart.js.map ] || sentry_falha "build/web/main.dart.js.map nao foi gerado"
  # commits=false: o clone da Vercel e raso, sem historico para associar commits ao release.
  dart run sentry_dart_plugin \
    --sentry-define=release=$SENTRY_RELEASE_ID \
    --sentry-define=commits=false \
    || sentry_falha "upload dos source maps ao Sentry falhou (confira org/project no pubspec.yaml e as permissoes do token)"
fi

# Os .map nao devem ser servidos publicamente (exporiam o codigo-fonte): ficam so no Sentry.
rm -f build/web/*.map
