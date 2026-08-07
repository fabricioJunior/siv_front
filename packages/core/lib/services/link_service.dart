import 'package:url_launcher/url_launcher.dart';

/// Wrapper fino sobre `url_launcher` — evita dependência direta de package
/// de terceiro fora do core (ver convenção do projeto).
class LinkService {
  Future<bool> abrirLink(String url) {
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
