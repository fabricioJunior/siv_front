import 'package:autenticacao/models.dart';

Usuario fakeUsuario({
  int id = 1,
  DateTime? criadoEm,
  DateTime? atualizadoEm,
  String login = 'login',
  String nome = 'nome do usuario',
  String tipo = 'tipo',
}) =>
    Usuario(
      id: id,
      criadoEm: criadoEm ?? DateTime(2020),
      atualizadoEm: atualizadoEm ?? DateTime(2020),
      login: login,
      nome: nome,
      tipo: tipo,
    );
