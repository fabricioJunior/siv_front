// ignore_for_file: constant_identifier_names

import 'package:core/equals.dart';

enum TipoOperacao {
  compra,
  compra_devolucao,
  venda,
  venda_devolucao,
  consignacao_saida,
  consignacao_devolucao,
  consignacao_acerto,
  transferencia_saida,
  transferencia_entrada,
  transferencia_devolucao,
  outros;

  String toJsonValue() => name;

  String get descricao => toJsonValue();

  static TipoOperacao? fromJson(dynamic value) {
    if (value == null) return null;

    final normalized =
        value.toString().trim().replaceFirst('TipoOperacao.', '');

    for (final operacao in TipoOperacao.values) {
      if (operacao.name == normalized) {
        return operacao;
      }
    }

    return null;
  }
}

abstract class Romaneio implements Equatable {
  int? get id;
  int? get pessoaId;
  String? get pessoaNome;
  int? get funcionarioId;
  String? get funcionarioNome;
  int? get tabelaPrecoId;
  String? get modalidade;
  TipoOperacao? get operacao;
  String? get situacao;
  double? get quantidade;
  double? get valorBruto;
  double? get valorDesconto;
  double? get valorLiquido;
  String? get observacao;
  DateTime? get data;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  List<RomaneioPagamentoRealizado> get formasDePagamentoRealizadas;

  factory Romaneio.create({
    int? id,
    int? pessoaId,
    String? pessoaNome,
    int? funcionarioId,
    String? funcionarioNome,
    int? tabelaPrecoId,
    String? modalidade,
    TipoOperacao? operacao,
    String? situacao,
    double? quantidade,
    double? valorBruto,
    double? valorDesconto,
    double? valorLiquido,
    String? observacao,
    DateTime? data,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    List<RomaneioPagamentoRealizado>? formasDePagamentoRealizadas,
  }) = _RomaneioImpl;

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        pessoaNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        modalidade,
        operacao,
        situacao,
        quantidade,
        valorBruto,
        valorDesconto,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioImpl implements Romaneio {
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final String? pessoaNome;
  @override
  final int? funcionarioId;
  @override
  final String? funcionarioNome;
  @override
  final int? tabelaPrecoId;
  @override
  final String? modalidade;
  @override
  final TipoOperacao? operacao;
  @override
  final String? situacao;
  @override
  final double? quantidade;
  @override
  final double? valorBruto;
  @override
  final double? valorDesconto;
  @override
  final double? valorLiquido;
  @override
  final String? observacao;
  @override
  final DateTime? data;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;
  @override
  final List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas;

  const _RomaneioImpl({
    this.id,
    this.pessoaId,
    this.pessoaNome,
    this.funcionarioId,
    this.funcionarioNome,
    this.tabelaPrecoId,
    this.modalidade,
    this.operacao,
    this.situacao,
    this.quantidade,
    this.valorBruto,
    this.valorDesconto,
    this.valorLiquido,
    this.observacao,
    this.data,
    this.criadoEm,
    this.atualizadoEm,
    List<RomaneioPagamentoRealizado>? formasDePagamentoRealizadas,
  }) : formasDePagamentoRealizadas = formasDePagamentoRealizadas ?? const [];

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        pessoaNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        modalidade,
        operacao,
        situacao,
        quantidade,
        valorBruto,
        valorDesconto,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
      ];

  @override
  bool? get stringify => true;
}

abstract class RomaneioPagamentoRealizado implements Equatable {
  int get controle;
  int get formaDePagamentoId;
  int get parcela;
  double get valor;
  String? get descricao;

  factory RomaneioPagamentoRealizado.create({
    required int controle,
    required int formaDePagamentoId,
    required int parcela,
    required double valor,
    String? descricao,
  }) = _RomaneioPagamentoRealizadoImpl;

  @override
  List<Object?> get props => [controle, formaDePagamentoId, parcela, valor, descricao];

  @override
  bool? get stringify => true;
}

class _RomaneioPagamentoRealizadoImpl implements RomaneioPagamentoRealizado {
  @override
  final int controle;
  @override
  final int formaDePagamentoId;
  @override
  final int parcela;
  @override
  final double valor;
  @override
  final String? descricao;

  const _RomaneioPagamentoRealizadoImpl({
    required this.controle,
    required this.formaDePagamentoId,
    required this.parcela,
    required this.valor,
    this.descricao,
  });

  @override
  List<Object?> get props => [controle, formaDePagamentoId, parcela, valor, descricao];

  @override
  bool? get stringify => true;
}
