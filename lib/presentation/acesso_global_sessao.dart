import 'package:core/sessao/i_acesso_global_sessao.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class AcessoGlobalSessao implements IAcessoGlobalSessao {
  final AppBloc _appBloc;
  final SyncDataBloc _syncDataBloc;
  
  
  AcessoGlobalSessao({required AppBloc appBloc, required SyncDataBloc syncDataBloc}) : _appBloc = appBloc, _syncDataBloc = syncDataBloc;
  
  @override
  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId}) {
    _appBloc.add(AppAtualizouCaixaDaSessao(terminalId: terminalId, caixaId: caixaId));
  }
  
  @override
  int? get caixaIdDaSessao => _appBloc.state.caixaIdDaSessao;
  
  @override
  int? get empresaIdDaSessao => _appBloc.state.empresaDaSessao?.id;

  @override
  String? get empresaNomeDaSessao => _appBloc.state.empresaDaSessao?.nome;
  
  @override
  int? get terminalIdDaSessao => _appBloc.state.terminalDaSessao?.id;
  
  @override
  String? get terminalNomeDaSessao => _appBloc.state.terminalDaSessao?.nome;
  
  @override
  int? get usuarioIdDaSessao => _appBloc.state.usuarioDaSessao?.id;
  
  @override
  bool get dadosSincronizados => _syncDataBloc.state.sincronizando == false;
  
  @override
  Stream<bool> get sincronizandoDados => _syncDataBloc.stream.map((state) => state.sincronizando);
}