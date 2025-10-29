import 'package:autenticacao/models.dart';

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
    Usuario.instance(
      id: id,
      login: login,
      nome: nome,
      tipo: tipo,
      senha: senha,
    );

Permissao fakePermissao({
  String id = '1',
  String nome = "Teste",
  bool descontinuado = false,
}) {
  return Permissao.instance(
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
    GrupoDeAcesso.instance(
      id: id,
      nome: nome,
      permissoes: permissoes,
    );

VinculoGrupoDeAcessoEUsuario fakeVinculoGrupoDeAcessoEUsuario({
  int idUsuario = 0,
  GrupoDeAcesso? grupoDeAcesso,
  Empresa? empresa,
}) =>
    VinculoGrupoDeAcessoEUsuario.instance(
      idUsuario: idUsuario,
      grupoDeAcesso: grupoDeAcesso,
      empresa: empresa,
    );

Empresa fakeEmpresa({
  int id = 0,
  String nome = 'nome',
}) =>
    Empresa.instance(
      id: id,
      nome: nome,
    );
