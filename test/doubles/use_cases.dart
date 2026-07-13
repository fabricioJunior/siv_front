import 'package:autenticacao/domain/usecases/recuperar_permissoes_do_usuario.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/paginacao/limpar_sincronizacao_incremental.dart';
import 'package:estoque/estoque.dart';
import 'package:mockito/annotations.dart';
import 'package:precos/use_cases.dart';
import 'package:produtos/domain/use_cases/sincronizar_codigos.dart';

@GenerateMocks([
  OnAutenticado,
  OnDesautenticado,
  EstaAutenticado,
  Deslogar,
  RecuperarUsuarioDaSessao,
  RecuperarEmpresaDaSessao,
  SincronizarPermissoesDoUsuario,
  RecuperarPermissoesDoUsuario,
  LimparSincronizacaoIncremental,
  SincronizarCodigos,
  SincronizarEstoque,
  SincronziarTabelasDePreco,
  SincronizarPrecos,
])
void main() {}
