import 'package:flutter/material.dart';

mixin Tamanho {
  bool get inativo;
  String get nome;
  int? get id;

  @visibleForTesting
  static Tamanho instance({
    required bool inativo,
    required String nome,
    int? id,
  }) =>
      _Tamanho(
        inativo: inativo,
        nome: nome,
        id: id,
      );
}

class _Tamanho implements Tamanho {
  @override
  final bool inativo;
  @override
  final String nome;
  @override
  final int? id;

  _Tamanho({
    required this.inativo,
    required this.nome,
    this.id,
  });
}
