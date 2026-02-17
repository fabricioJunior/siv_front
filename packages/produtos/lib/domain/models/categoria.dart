import 'package:flutter/material.dart';

mixin Categoria {
  bool get inativa;
  String get nome;
  int? get id;

  @visibleForTesting
  static Categoria instance({
    required bool inativa,
    required String nome,
    int? id,
  }) => _Categoria(inativa: inativa, nome: nome, id: id);
}

class _Categoria implements Categoria {
  @override
  final bool inativa;
  @override
  final String nome;
  @override
  final int? id;

  _Categoria({required this.inativa, required this.nome, this.id});
}
