import 'dart:math' as math;

import 'package:core/equals.dart';

// Item enviado na apuracao (POST /v1/desconto-elegibilidade/apurar) -- espelha
// ItemElegibilidadeDto do backend (apps/api/.../desconto-elegibilidade/dto).
class ItemApuracaoElegibilidade extends Equatable {
  final int referenciaId;
  final int produtoId;
  final int quantidade;
  final double valorUnitario;

  const ItemApuracaoElegibilidade({
    required this.referenciaId,
    required this.produtoId,
    required this.quantidade,
    required this.valorUnitario,
  });

  Map<String, dynamic> toJson() => {
        'referenciaId': referenciaId,
        'produtoId': produtoId,
        'quantidade': quantidade,
        'valorUnitario': valorUnitario,
      };

  @override
  List<Object?> get props =>
      [referenciaId, produtoId, quantidade, valorUnitario];
}

// Espelha override por forma de pagamento dentro de OpcaoElegivelResponse.
// Só um dos 3 campos vem preenchido -- indica o tipoDesconto da promoção
// pra essa forma (percentual/valorFixo/precoFixo), o backend não expõe o
// tipo explicitamente.
class OverridePorFormaPagamento extends Equatable {
  final int formaDePagamentoId;
  final double? valorPercentual;
  final double? valorFixo;
  final double? precoFixo;

  const OverridePorFormaPagamento({
    required this.formaDePagamentoId,
    this.valorPercentual,
    this.valorFixo,
    this.precoFixo,
  });

  factory OverridePorFormaPagamento.fromJson(Map<String, dynamic> json) {
    return OverridePorFormaPagamento(
      formaDePagamentoId: (json['formaDePagamentoId'] as num).toInt(),
      valorPercentual: _numOuString(json['valorPercentual']),
      valorFixo: _numOuString(json['valorFixo']),
      precoFixo: _numOuString(json['precoFixo']),
    );
  }

  // Coluna decimal do backend (TypeORM) pode vir como String quando falta
  // transformer -- tolera os dois formatos em vez de estourar cast.
  static double? _numOuString(Object? valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString());
  }

  @override
  List<Object?> get props =>
      [formaDePagamentoId, valorPercentual, valorFixo, precoFixo];
}

// Espelha OpcaoElegivelResponse do backend.
class OpcaoElegivel extends Equatable {
  final String tipo; // 'promocao' | 'cupom'
  final int id;
  final String nome;
  // Codigo digitado do cupom (so tipo 'cupom'; null em backend antigo).
  final String? codigo;
  final double valorDesconto;
  final double valorFinalUnitario;
  // Presente e preenchido só quando a promoção restringe forma de
  // pagamento -- null/ausente = sem restrição, libera todas.
  final List<int>? formasPagamentoPermitidasIds;
  // Presente só quando existe override REAL de desconto pra alguma forma
  // de pagamento -- formas sem override não entram nessa lista.
  final List<OverridePorFormaPagamento>? overridesPorFormaPagamento;

  const OpcaoElegivel({
    required this.tipo,
    required this.id,
    required this.nome,
    this.codigo,
    required this.valorDesconto,
    required this.valorFinalUnitario,
    this.formasPagamentoPermitidasIds,
    this.overridesPorFormaPagamento,
  });

  factory OpcaoElegivel.fromJson(Map<String, dynamic> json) {
    return OpcaoElegivel(
      tipo: json['tipo'] as String,
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      codigo: json['codigo'] as String?,
      valorDesconto: (json['valorDesconto'] as num).toDouble(),
      valorFinalUnitario: (json['valorFinalUnitario'] as num).toDouble(),
      formasPagamentoPermitidasIds:
          (json['formasPagamentoPermitidasIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      overridesPorFormaPagamento:
          (json['overridesPorFormaPagamento'] as List<dynamic>?)
              ?.map((e) =>
                  OverridePorFormaPagamento.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  bool get ehCupom => tipo == 'cupom';

  // Desconto (por unidade) efetivo pra forma de pagamento escolhida --
  // recalcula a partir do override quando existir, senão devolve o valor
  // base (mesmo comportamento de antes). Prévia de UI: cálculo final de
  // verdade é sempre feito no backend no fechamento da venda.
  double valorDescontoParaForma(
    int? formaDePagamentoId, {
    required double valorUnitario,
  }) {
    OverridePorFormaPagamento? override;
    if (formaDePagamentoId != null) {
      for (final o in overridesPorFormaPagamento ?? const []) {
        if (o.formaDePagamentoId == formaDePagamentoId) {
          override = o;
          break;
        }
      }
    }
    if (override == null) return valorDesconto;

    if (override.valorPercentual != null) {
      // ponytail: sem teto de valorDescontoMaximo, backend não expõe esse
      // campo nesse response -- prévia simplificada, fechamento é o real.
      return valorUnitario * (override.valorPercentual! / 100);
    }
    if (override.valorFixo != null) {
      return math.min(override.valorFixo!, valorUnitario);
    }
    if (override.precoFixo != null) {
      return valorUnitario - math.min(override.precoFixo!, valorUnitario);
    }
    return valorDesconto;
  }

  @override
  List<Object?> get props => [
        tipo,
        id,
        nome,
        codigo,
        valorDesconto,
        valorFinalUnitario,
        formasPagamentoPermitidasIds,
        overridesPorFormaPagamento,
      ];
}

// Espelha ItemElegibilidadeResponse do backend.
class ItemElegibilidade extends Equatable {
  final int referenciaId;
  final List<OpcaoElegivel> opcoesElegiveis;
  // Soma unitaria (com teto no preco) das opcoes de cupom; so vem com 2+
  // cupons aplicaveis no item.
  final double? descontoCuponsSomado;

  const ItemElegibilidade({
    required this.referenciaId,
    required this.opcoesElegiveis,
    this.descontoCuponsSomado,
  });

  factory ItemElegibilidade.fromJson(Map<String, dynamic> json) {
    final opcoes = json['opcoesElegiveis'] as List<dynamic>? ?? const [];
    return ItemElegibilidade(
      referenciaId: (json['referenciaId'] as num).toInt(),
      opcoesElegiveis: opcoes
          .map((o) => OpcaoElegivel.fromJson(o as Map<String, dynamic>))
          .toList(),
      descontoCuponsSomado: (json['descontoCuponsSomado'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [referenciaId, opcoesElegiveis, descontoCuponsSomado];
}

// Espelha ElegibilidadeResponse do backend.
class ResultadoElegibilidade extends Equatable {
  final List<ItemElegibilidade> itens;
  final String? cupomInvalido;
  // Codigos de cupom aceitos pela apuracao; null = backend antigo (nao manda).
  final List<String>? cuponsAceitos;

  const ResultadoElegibilidade({
    required this.itens,
    this.cupomInvalido,
    this.cuponsAceitos,
  });

  factory ResultadoElegibilidade.fromJson(Map<String, dynamic> json) {
    final itens = json['itens'] as List<dynamic>? ?? const [];
    return ResultadoElegibilidade(
      itens: itens
          .map((i) => ItemElegibilidade.fromJson(i as Map<String, dynamic>))
          .toList(),
      cupomInvalido: json['cupomInvalido'] as String?,
      cuponsAceitos: (json['cupons'] as List<dynamic>?)
          ?.map((c) => (c as Map<String, dynamic>)['codigo'] as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [itens, cupomInvalido, cuponsAceitos];
}
