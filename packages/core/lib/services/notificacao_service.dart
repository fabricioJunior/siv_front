import 'package:core/services/notificacao_plataforma_io.dart'
    if (dart.library.js_interop) 'package:core/services/notificacao_plataforma_web.dart'
    as plataforma;

/// Notificação do SISTEMA (toast do SO / `Notification` do navegador). Esconde
/// a plataforma e nunca lança: sem suporte ou sem permissão, não faz nada.
class NotificacaoService {
  Future<void> inicializar() async {
    try {
      await plataforma.inicializar();
    } catch (_) {}
  }

  Future<void> exibir({required String titulo, required String corpo}) async {
    try {
      await plataforma.exibir(titulo, corpo);
    } catch (_) {}
  }
}
