import 'package:core/equals.dart';
import 'package:promocoes/domain/models/promocao_forma_pagamento.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Obrigatorio: um sem o outro e erro de validacao no backend (limite de usos
// por cliente no periodo, ex: desconto de aniversario 1x/ano).
enum PeriodoLimiteCliente {
  mes,
  ano;

  static PeriodoLimiteCliente? fromString(String? value) {
    switch (value) {
      case 'mes':
        return PeriodoLimiteCliente.mes;
      case 'ano':
        return PeriodoLimiteCliente.ano;
      default:
        return null;
    }
  }

  String get value {
    switch (this) {
      case PeriodoLimiteCliente.mes:
        return 'mes';
      case PeriodoLimiteCliente.ano:
        return 'ano';
    }
  }
}

enum PromocaoCanal {
  loja,
  ecommerce,
  ambos;

  static PromocaoCanal fromString(String? value) {
    switch (value) {
      case 'loja':
        return PromocaoCanal.loja;
      case 'ecommerce':
        return PromocaoCanal.ecommerce;
      case 'ambos':
      default:
        return PromocaoCanal.ambos;
    }
  }

  String get value {
    switch (this) {
      case PromocaoCanal.loja:
        return 'loja';
      case PromocaoCanal.ecommerce:
        return 'ecommerce';
      case PromocaoCanal.ambos:
        return 'ambos';
    }
  }
}

abstract class Promocao implements Equatable {
  int? get id;
  int? get empresaId;
  String get nome;
  String? get descricao;
  DateTime get dataInicio;
  DateTime get dataFim;
  TipoDesconto get tipoDesconto;
  double? get valorPercentual;
  double? get valorDescontoMaximo;
  double? get valorFixo;
  double? get valorMinimoCompra;
  int? get quantidadeMinima;
  double? get precoFixo;
  TipoEscopo get tipoEscopo;
  List<int>? get referenciaIds;
  List<ItemComboKit>? get comboKit;
  int? get quantidadeLeva;
  int? get quantidadePaga;
  int? get limiteUnidadesVendidas;
  int get unidadesVendidas;
  int? get limiteUsosPorCliente;
  PeriodoLimiteCliente? get periodoLimiteCliente;
  bool get somenteAniversariante;
  PromocaoCanal get canal;
  bool get ativa;
  bool get restringirFormasPagamento;
  List<PromocaoFormaPagamento> get formasPagamento;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;

  factory Promocao.create({
    int? id,
    int? empresaId,
    required String nome,
    String? descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoDesconto tipoDesconto,
    double? valorPercentual,
    double? valorDescontoMaximo,
    double? valorFixo,
    double? valorMinimoCompra,
    int? quantidadeMinima,
    double? precoFixo,
    required TipoEscopo tipoEscopo,
    List<int>? referenciaIds,
    List<ItemComboKit>? comboKit,
    int? quantidadeLeva,
    int? quantidadePaga,
    int? limiteUnidadesVendidas,
    int unidadesVendidas,
    int? limiteUsosPorCliente,
    PeriodoLimiteCliente? periodoLimiteCliente,
    bool somenteAniversariante,
    PromocaoCanal canal,
    bool ativa,
    bool restringirFormasPagamento,
    List<PromocaoFormaPagamento> formasPagamento,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) = _PromocaoImpl;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        nome,
        descricao,
        dataInicio,
        dataFim,
        tipoDesconto,
        valorPercentual,
        valorDescontoMaximo,
        valorFixo,
        valorMinimoCompra,
        quantidadeMinima,
        precoFixo,
        tipoEscopo,
        referenciaIds,
        comboKit,
        quantidadeLeva,
        quantidadePaga,
        limiteUnidadesVendidas,
        unidadesVendidas,
        limiteUsosPorCliente,
        periodoLimiteCliente,
        somenteAniversariante,
        canal,
        ativa,
        restringirFormasPagamento,
        formasPagamento,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}

class _PromocaoImpl implements Promocao {
  @override
  final int? id;
  @override
  final int? empresaId;
  @override
  final String nome;
  @override
  final String? descricao;
  @override
  final DateTime dataInicio;
  @override
  final DateTime dataFim;
  @override
  final TipoDesconto tipoDesconto;
  @override
  final double? valorPercentual;
  @override
  final double? valorDescontoMaximo;
  @override
  final double? valorFixo;
  @override
  final double? valorMinimoCompra;
  @override
  final int? quantidadeMinima;
  @override
  final double? precoFixo;
  @override
  final TipoEscopo tipoEscopo;
  @override
  final List<int>? referenciaIds;
  @override
  final List<ItemComboKit>? comboKit;
  @override
  final int? quantidadeLeva;
  @override
  final int? quantidadePaga;
  @override
  final int? limiteUnidadesVendidas;
  @override
  final int unidadesVendidas;
  @override
  final int? limiteUsosPorCliente;
  @override
  final PeriodoLimiteCliente? periodoLimiteCliente;
  @override
  final bool somenteAniversariante;
  @override
  final PromocaoCanal canal;
  @override
  final bool ativa;
  @override
  final bool restringirFormasPagamento;
  @override
  final List<PromocaoFormaPagamento> formasPagamento;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const _PromocaoImpl({
    this.id,
    this.empresaId,
    required this.nome,
    this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoDesconto,
    this.valorPercentual,
    this.valorDescontoMaximo,
    this.valorFixo,
    this.valorMinimoCompra,
    this.quantidadeMinima,
    this.precoFixo,
    required this.tipoEscopo,
    this.referenciaIds,
    this.comboKit,
    this.quantidadeLeva,
    this.quantidadePaga,
    this.limiteUnidadesVendidas,
    this.unidadesVendidas = 0,
    this.limiteUsosPorCliente,
    this.periodoLimiteCliente,
    this.somenteAniversariante = false,
    this.canal = PromocaoCanal.ambos,
    this.ativa = true,
    this.restringirFormasPagamento = false,
    this.formasPagamento = const [],
    this.criadoEm,
    this.atualizadoEm,
  });

  @override
  List<Object?> get props => [
        id,
        empresaId,
        nome,
        descricao,
        dataInicio,
        dataFim,
        tipoDesconto,
        valorPercentual,
        valorDescontoMaximo,
        valorFixo,
        valorMinimoCompra,
        quantidadeMinima,
        precoFixo,
        tipoEscopo,
        referenciaIds,
        comboKit,
        quantidadeLeva,
        quantidadePaga,
        limiteUnidadesVendidas,
        unidadesVendidas,
        limiteUsosPorCliente,
        periodoLimiteCliente,
        somenteAniversariante,
        canal,
        ativa,
        restringirFormasPagamento,
        formasPagamento,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}
