import 'package:flutter/material.dart';

// ignore: must_be_immutable

typedef SeletorWidget = Widget Function({
  List<SelectData>? itemsSelecionadosInicial,
  void Function(List<SelectData>)? onChanged,
  bool? onlyView,
});

class SeletorParamentros {
  final List<SelectData>? itemsSelecionadosInicial;
  final void Function(List<SelectData>)? onChanged;
  final bool onlyView;

  const SeletorParamentros({
    this.itemsSelecionadosInicial,
    this.onChanged,
    this.onlyView = false,
  });
}

typedef SeletorParametros = SeletorParamentros;

extension SeletorWidgetExtension on SeletorWidget {
  Widget buildComParametros(SeletorParamentros parametros) {
    return call(
      itemsSelecionadosInicial: parametros.itemsSelecionadosInicial,
      onChanged: parametros.onChanged,
      onlyView: parametros.onlyView,
    );
  }
}

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
