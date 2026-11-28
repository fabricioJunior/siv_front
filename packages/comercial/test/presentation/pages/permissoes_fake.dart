import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';

class PermissoesFake implements IPermissoesController {
  final Set<String> ok;
  PermissoesFake(this.ok);

  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      ok.contains(idComponente);

  @override
  bool temAcesso({String? idComponente, int? grupoId}) =>
      ok.contains(idComponente);
}

/// Registra as permissões liberadas para o teste (limpa o que havia).
Future<void> registrarPermissoes(Set<String> ok) async {
  if (sl.isRegistered<IPermissoesController>()) {
    await sl.unregister<IPermissoesController>();
  }
  sl.registerSingleton<IPermissoesController>(PermissoesFake(ok));
}
