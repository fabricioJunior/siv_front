import 'package:flutter/material.dart';

// ignore: must_be_immutable

typedef SeletorWidget = Widget Function({
  List<SelectData>? itemsSelecionadosInicial,
  void Function(List<SelectData>)? onChanged,
});

abstract class ISeletor extends Widget {
  final List<SelectData>? itemsSelecionadosInicial;
  final Function(List<SelectData>)? onChanged;
  const ISeletor({
    super.key,
    required this.itemsSelecionadosInicial,
    this.onChanged,
  });
}

class SelectData {
  final int id;
  final String nome;
  final Map<String, dynamic> data;

  SelectData({required this.id, required this.nome, required this.data});
}
