import 'package:flutter/material.dart';

// ignore: must_be_immutable

class SeletorData {
  final List<SelectData>? itemsSelecionadosInicial;
  final void Function(List<SelectData>)? onChanged;
  final bool onlyView;
  final Set<int>? idsPermitidos;

  const SeletorData({
    this.itemsSelecionadosInicial,
    this.onChanged,
    this.onlyView = false,
    this.idsPermitidos,
  });
}

typedef SeletorWidget = Widget Function(SeletorData data);

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
