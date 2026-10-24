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

/// Seletor que depende de categorias já escolhidas (ex: subcategorias).
typedef SeletorPorCategoriasWidget = Widget Function({
  required List<int> categoriaIds,
  required SeletorData data,
});

/// Dados da grade tipo → forma de pagamento (etapa de pagamento, ref. 2b).
class FormaPagamentoGradeData {
  final SelectData? selecionada;
  final void Function(SelectData forma) onEscolhida;

  /// `'manual'`/`'online'` filtram as formas; null mostra todas.
  final String? tipoOperacao;

  /// Formas fora do conjunto aparecem bloqueadas (promoção restrita).
  final Set<int>? idsPermitidos;

  /// Saldo do cliente (crédito de devolução + adiantamento); o tipo "Saldo
  /// do cliente" só aparece com saldo > 0.
  final double saldoCliente;

  /// Nó de foco da grade: quem hospeda controla para onde o teclado vai
  /// (letras e setas só chegam à grade com o foco nela).
  final FocusNode? foco;

  const FormaPagamentoGradeData({
    required this.onEscolhida,
    this.foco,
    this.selecionada,
    this.tipoOperacao,
    this.idsPermitidos,
    this.saldoCliente = 0,
  });
}

typedef FormaPagamentoGradeWidget = Widget Function(
  FormaPagamentoGradeData data,
);

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
