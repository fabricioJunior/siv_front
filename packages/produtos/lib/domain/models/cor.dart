import 'package:flutter/material.dart';

mixin Cor {
  bool? get inativo;
  String get nome;
  int? get id;

  @visibleForTesting
  static Cor instance({required bool inativo, required String nome, int? id}) =>
      _Cor(inativo: inativo, nome: nome, id: id);
}

class _Cor implements Cor {
  @override
  final bool inativo;
  @override
  final String nome;
  @override
  final int? id;

  _Cor({required this.inativo, required this.nome, this.id});
}
