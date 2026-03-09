import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:siv_front/bloc/app_bloc.dart';

class Permissoes implements IPermissoesController {
  final AppBloc _appBloc;

  Permissoes({required AppBloc appBloc}) : _appBloc = appBloc;

  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async {
    var permissao = _appBloc.state.permissoesDoUsuario[idComponente];
    if (permissao == null) {
      return false;
    }

    return permissao.grupoId == grupoId;
  }

  @override
  bool temAcesso({String? idComponente, int? grupoId}) {
    var permissao = _appBloc.state.permissoesDoUsuario[idComponente];
    if (permissao == null) {
      return false;
    }
    if (grupoId != null) {
      return permissao.grupoId == grupoId;
    }
    return true;
  }
}
