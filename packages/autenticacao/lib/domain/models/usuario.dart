import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/equals.dart';

abstract class Usuario implements Equatable {
  int get id;
  String get login;
  String get nome;
  TipoUsuario get tipo;
  String? get senha;

  List<TerminalDoUsuario> get terminaisDoUsuario;

  factory Usuario.create({
    required int id,
    required String login,
    required String nome,
    required TipoUsuario tipo,
    String? senha,
    required List<TerminalDoUsuario> terminaisDoUsuario,
  }) = _UsuarioImpl;

  @override
  List<Object?> get props => [
        id,
        login,
        nome,
        tipo,
      ];

  @override
  bool? get stringify => true;
}

class _UsuarioImpl implements Usuario {
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

  @override
  final List<TerminalDoUsuario> terminaisDoUsuario;

  _UsuarioImpl({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.terminaisDoUsuario,
    this.senha,
  });

  _UsuarioImpl copyWith({
    int? id,
    String? login,
    String? nome,
    TipoUsuario? tipo,
    String? senha,
    List<TerminalDoUsuario>? terminaisDoUsuario,
  }) {
    return _UsuarioImpl(
      id: id ?? this.id,
      login: login ?? this.login,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      senha: senha ?? this.senha,
      terminaisDoUsuario: terminaisDoUsuario ?? this.terminaisDoUsuario,
    );
  }

  @override
  List<Object?> get props => [
        id,
        login,
        nome,
        tipo,
      ];

  @override
  bool? get stringify => true;
}

extension UsuarioCopyWith on Usuario {
  Usuario copyWith({
    int? id,
    String? login,
    String? nome,
    TipoUsuario? tipo,
    String? senha,
    List<TerminalDoUsuario>? terminaisDoUsuario,
  }) {
    if (this is _UsuarioImpl) {
      return (this as _UsuarioImpl).copyWith(
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
        senha: senha,
        terminaisDoUsuario: terminaisDoUsuario,
      );
    }
    return Usuario.create(
      id: id ?? this.id,
      login: login ?? this.login,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      senha: senha ?? this.senha,
      terminaisDoUsuario: terminaisDoUsuario ?? this.terminaisDoUsuario,
    );
  }
}

enum TipoUsuario {
  padrao(nome: 'Padrão'),
  administrador(nome: 'Administrador'),
  sysadmin(nome: 'Sysadmin');

  final String nome;

  const TipoUsuario({required this.nome});
}
