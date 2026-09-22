import 'package:core/equals.dart';

enum TipoOperacaoFormaPagamento {
  manual,
  online;

  static TipoOperacaoFormaPagamento fromString(String? value) {
    switch (value) {
      case 'online':
        return TipoOperacaoFormaPagamento.online;
      case 'manual':
      default:
        return TipoOperacaoFormaPagamento.manual;
    }
  }

  String get value => name;
}

abstract class FormaDePagamento implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  int? get id;
  String get descricao;
  int get inicio;
  int get parcelas;
  String get tipo;
  bool get inativa;
  TipoOperacaoFormaPagamento get tipoOperacao;
  String? get provider;
  double? get custoPercentual;
  double? get custoFixo;

  factory FormaDePagamento.create({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    required String descricao,
    required int inicio,
    required int parcelas,
    required String tipo,
    required bool inativa,
    TipoOperacaoFormaPagamento tipoOperacao,
    String? provider,
    double? custoPercentual,
    double? custoFixo,
  }) = _FormaDePagamentoImpl;

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        id,
        descricao,
        inicio,
        parcelas,
        tipo,
        inativa,
        tipoOperacao,
        provider,
        custoPercentual,
        custoFixo,
      ];

  @override
  bool? get stringify => true;
}

class _FormaDePagamentoImpl implements FormaDePagamento {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final int? id;

  @override
  final String descricao;

  @override
  final int inicio;

  @override
  final int parcelas;

  @override
  final String tipo;

  @override
  final bool inativa;

  @override
  final TipoOperacaoFormaPagamento tipoOperacao;

  @override
  final String? provider;

  @override
  final double? custoPercentual;

  @override
  final double? custoFixo;

  const _FormaDePagamentoImpl({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    required this.descricao,
    required this.inicio,
    required this.parcelas,
    required this.tipo,
    this.inativa = false,
    this.tipoOperacao = TipoOperacaoFormaPagamento.manual,
    this.provider,
    this.custoPercentual,
    this.custoFixo,
  });

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        id,
        descricao,
        inicio,
        parcelas,
        tipo,
        inativa,
        tipoOperacao,
        provider,
        custoPercentual,
        custoFixo,
      ];

  @override
  bool? get stringify => true;
}
