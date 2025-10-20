import 'package:autenticacao/models.dart';
import 'package:core/equals.dart';
import 'package:flutter/foundation.dart';

mixin GrupoDeAcesso implements EquatableMixin {
  int get id;
  String get nome;
  List<Permissao> get permissoes;

  @override
  List<Object?> get props => [
        id,
        nome,
        permissoes,
      ];
  @override
  bool? get stringify => true;

  GrupoDeAcesso copyWith({
    int? id,
    String? nome,
    List<Permissao>? permissoes,
  }) {
    return _GrupoDeAcesso(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      permissoes: permissoes ?? this.permissoes,
    );
  }

  @visibleForTesting
  static GrupoDeAcesso instance({
    required int id,
    required String nome,
    required List<Permissao> permissoes,
  }) =>
      _GrupoDeAcesso(
        id: id,
        nome: nome,
        permissoes: permissoes,
      );
}

class _GrupoDeAcesso with GrupoDeAcesso {
  @override
  final int id;

  @override
  final String nome;

  @override
  final List<Permissao> permissoes;

  _GrupoDeAcesso({
    required this.id,
    required this.nome,
    required this.permissoes,
  });
}
