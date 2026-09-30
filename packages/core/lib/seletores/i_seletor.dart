import 'package:flutter/material.dart';

// ignore: must_be_immutable

class SeletorData {
  final List<SelectData>? itemsSelecionadosInicial;
  final void Function(List<SelectData>)? onChanged;
  final bool onlyView;
  final Set<int>? idsPermitidos;

  /// Quando true, o seletor renderiza como campo fechado (ícone + valor +
  /// chevron) que abre a busca real num modal, em vez da busca inline
  /// sempre visível. Ver [SeletorGenericoCompacto].
  final bool compacto;

  const SeletorData({
    this.itemsSelecionadosInicial,
    this.onChanged,
    this.onlyView = false,
    this.idsPermitidos,
    this.compacto = false,
  });
}

typedef SeletorWidget = Widget Function(SeletorData data);

/// Igual [SeletorWidget], mas pro seletor que precisa da empresa em contexto
/// (ex: terminais de uma empresa) — empresaId só é conhecido em tempo de
/// build no package consumidor, não no composition root.
typedef SeletorPorEmpresaWidget = Widget Function({
  required int empresaId,
  String? tipoFiltro,
  required SeletorData data,
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
