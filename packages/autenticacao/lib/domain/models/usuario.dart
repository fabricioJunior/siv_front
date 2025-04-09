import 'package:core/equals.dart';

mixin Usuario implements EquatableMixin {
  int get id;
  String get login;
  String get nome;
  TipoUsuario get tipo;
  String? get senha;

  Usuario copyWith({
    String? login,
    String? senha,
    String? nome,
  }) =>
      _Usuario(
        id: id,
        login: login ?? this.login,
        nome: nome ?? this.nome,
        tipo: tipo,
        senha: senha ?? this.senha,
      );

  @override
  List<Object?> get props => [
        id,
        login,
        nome,
        tipo,
      ];

  static Usuario instance({
    required int id,
    required String login,
    required String nome,
    required TipoUsuario tipo,
    required String? senha,
  }) =>
      _Usuario(
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
        senha: senha,
      );
}

enum TipoUsuario {
  padrao(nome: 'Padrão'),
  administrador(nome: 'Administrador'),
  sysadmin(nome: 'Sysadmin');

  final String nome;

  const TipoUsuario({required this.nome});
}

class _Usuario extends Equatable with Usuario {
  const _Usuario({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.senha,
  });

  @override
  List<Object?> get props => [
        id,
        login,
        nome,
        tipo,
      ];

  @override
  final int id;

  @override
  final String login;

  @override
  final String nome;

  @override
  final TipoUsuario tipo;

  @override
  final String? senha;
}
