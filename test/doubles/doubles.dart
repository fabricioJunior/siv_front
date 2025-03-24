import 'package:autenticacao/models.dart';

Usuario fakeUsuario({
  int id = 1,
  DateTime? criadoEm,
  DateTime? atualizadoEm,
  String login = 'login',
  String nome = 'nome do usuario',
  TipoUsuario tipo = TipoUsuario.padrao,
}) =>
    Usuario.instance(
      id: id,
      login: login,
      nome: nome,
      tipo: tipo,
      senha: 'senha',
    );
