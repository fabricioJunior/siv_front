import 'package:autenticacao/models.dart';
import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';

Token fakeToken({
  String jwtToken = 'jwtToken',
  DateTime? dataDeCriacao,
  DateTime? dataDeExpiracao,
}) =>
    Token(
      jwtToken: jwtToken,
      dataDeCriacao: dataDeCriacao ?? DateTime(2024, 05, 1),
      dataDeExpiracao: DateTime(2024, 05, 1),
    );

Usuario fakeUsuario(
        {int id = 0,
        DateTime? criadoEm,
        DateTime? atualizadoEm,
        String login = 'login',
        String nome = 'nome',
        TipoUsuario tipo = TipoUsuario.sysadmin,
        String senha = 'senha'}) =>
    Usuario.create(
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
        senha: senha,
        terminaisDoUsuario: []);

Permissao fakePermissao({
  String id = '1',
  String nome = "Teste",
  bool descontinuado = false,
}) {
  return PermissaoDto(
    id: id,
    nome: nome,
    descontinuado: descontinuado,
  );
}

GrupoDeAcesso fakeGrupoDeAcesso({
  int id = 0,
  String nome = 'nome',
  List<Permissao> permissoes = const [],
}) =>
    GrupoDeAcessoDto(
      id: id,
      nome: nome,
      permissoes: permissoes.map((p) => p as PermissaoDto).toList(),
    );

VinculoGrupoDeAcessoEUsuario fakeVinculoGrupoDeAcessoEUsuario({
  int idUsuario = 0,
  GrupoDeAcesso? grupoDeAcesso,
  Empresa? empresa,
}) =>
    throw UnimplementedError('Use VinculoGrupoDeAcessoComUsuarioDto or mock');

Empresa fakeEmpresa({
  int id = 0,
  String nome = 'nome',
}) =>
    throw UnimplementedError('Use EmpresaDto or mock');
