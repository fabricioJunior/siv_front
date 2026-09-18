import 'package:autenticacao/domain/usecases/recuperar_permissoes_do_usuario.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/paginacao/limpar_sincronizacao_incremental.dart';
import 'package:core/sync.dart';
import 'package:estoque/estoque.dart';
import 'package:mockito/annotations.dart';
import 'package:precos/use_cases.dart';
import 'package:produtos/domain/use_cases/sincronizar_codigos.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

@GenerateMocks([
  OnAutenticado,
  OnDesautenticado,
  EstaAutenticado,
  Deslogar,
  RecuperarUsuarioDaSessao,
  RecuperarEmpresaDaSessao,
  SincronizarPermissoesDoUsuario,
  RecuperarPermissoesDoUsuarioLocal,
  RecuperarPermissoesDoUsuario,
  LimparSincronizacaoIncremental,
  SincronizarCodigos,
  SincronizarEstoque,
  SincronziarTabelasDePreco,
  SincronizarPrecos,
  RecuperarTokenJwt,
  SyncWebSocketService,
  SyncDataBloc,
])
void main() {}
