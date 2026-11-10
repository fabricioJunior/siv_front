import 'package:package_info_plus/package_info_plus.dart';

// Commit do deploy (vercel-build.sh passa o mesmo valor ao Sentry). Vazio fora do deploy.
const _release = String.fromEnvironment('SENTRY_RELEASE');

/// Wrapper fino sobre `package_info_plus`: texto da versão do app para exibir na tela.
class AppVersaoService {
  /// Ex.: `v1.0.0+1 · a1b2c3d` (o commit só aparece em builds de deploy). Vazio se não der para ler.
  Future<String> rotulo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final versao = info.buildNumber.isEmpty
          ? info.version
          : '${info.version}+${info.buildNumber}';
      return rotuloDe(versao, _release);
    } catch (_) {
      return '';
    }
  }

  static String rotuloDe(String versao, String release) {
    final curto = (release.isEmpty || release == 'local' || release == 'teste')
        ? ''
        : (release.length > 7 ? release.substring(0, 7) : release);
    return curto.isEmpty ? 'v$versao' : 'v$versao · $curto';
  }
}
