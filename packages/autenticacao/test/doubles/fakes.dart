import 'package:autenticacao/domain/models/token.dart';
import 'package:autenticacao/domain/models/usuario.dart';

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

Usuario fakeUsuario({
  int id = 0,
  DateTime? criadoEm,
  DateTime? atualizadoEm,
  String login = 'login',
  String nome = 'nome',
  String tipo = 'padrao',
}) =>
    Usuario(
      id: id,
      criadoEm: criadoEm ?? DateTime.now(),
      atualizadoEm: atualizadoEm ?? DateTime.now(),
      login: login,
      nome: nome,
      tipo: tipo,
    );
