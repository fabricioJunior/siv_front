// ignore_for_file: constant_identifier_names

import 'package:comercial/domain/models/consignacao_item.dart';
import 'package:core/equals.dart';

enum SituacaoConsignacao {
  em_andamento,
  encerrada,
  cancelada;

  String toJsonValue() => name;

  static SituacaoConsignacao? fromJson(dynamic value) {
    if (value == null) return null;

    final normalized =
        value.toString().trim().replaceFirst('SituacaoConsignacao.', '');

    for (final situacao in SituacaoConsignacao.values) {
      if (situacao.name == normalized) {
        return situacao;
      }
    }

    return null;
  }
}

abstract class Consignacao implements Equatable {
  int? get empresaId;
  int? get id;
  int? get pessoaId;
  String? get nomePessoa;
  int? get tabelaPrecoId;
  int? get caixaAbertura;
  DateTime? get dataAbertura;
  DateTime? get previsaoFechamento;
  int? get caixaFechamento;
  DateTime? get dataFechamento;
  int? get funcionarioId;
  String? get nomeFuncionario;
  String? get observacao;
  SituacaoConsignacao? get situacao;
  String? get motivoCancelamento;
  double? get solicitado;
  double? get valorSolicitado;
  double? get devolvido;
  double? get valorDevolvido;
  double? get acertado;
  double? get valorAcertado;
  double? get pendente;
  double? get valorPendente;
  int? get operadorId;
  List<ConsignacaoItem> get itens;

  factory Consignacao.create({
    int? empresaId,
    int? id,
    int? pessoaId,
    String? nomePessoa,
    int? tabelaPrecoId,
    int? caixaAbertura,
    DateTime? dataAbertura,
    DateTime? previsaoFechamento,
    int? caixaFechamento,
    DateTime? dataFechamento,
    int? funcionarioId,
    String? nomeFuncionario,
    String? observacao,
    SituacaoConsignacao? situacao,
    String? motivoCancelamento,
    double? solicitado,
    double? valorSolicitado,
    double? devolvido,
    double? valorDevolvido,
    double? acertado,
    double? valorAcertado,
    double? pendente,
    double? valorPendente,
    int? operadorId,
    List<ConsignacaoItem>? itens,
  }) = _ConsignacaoImpl;

  @override
  List<Object?> get props => [
        empresaId,
        id,
        pessoaId,
        nomePessoa,
        tabelaPrecoId,
        caixaAbertura,
        dataAbertura,
        previsaoFechamento,
        caixaFechamento,
        dataFechamento,
        funcionarioId,
        nomeFuncionario,
        observacao,
        situacao,
        motivoCancelamento,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
        itens,
      ];

  @override
  bool? get stringify => true;
}

class _ConsignacaoImpl implements Consignacao {
  @override
  final int? empresaId;
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final String? nomePessoa;
  @override
  final int? tabelaPrecoId;
  @override
  final int? caixaAbertura;
  @override
  final DateTime? dataAbertura;
  @override
  final DateTime? previsaoFechamento;
  @override
  final int? caixaFechamento;
  @override
  final DateTime? dataFechamento;
  @override
  final int? funcionarioId;
  @override
  final String? nomeFuncionario;
  @override
  final String? observacao;
  @override
  final SituacaoConsignacao? situacao;
  @override
  final String? motivoCancelamento;
  @override
  final double? solicitado;
  @override
  final double? valorSolicitado;
  @override
  final double? devolvido;
  @override
  final double? valorDevolvido;
  @override
  final double? acertado;
  @override
  final double? valorAcertado;
  @override
  final double? pendente;
  @override
  final double? valorPendente;
  @override
  final int? operadorId;
  @override
  final List<ConsignacaoItem> itens;

  const _ConsignacaoImpl({
    this.empresaId,
    this.id,
    this.pessoaId,
    this.nomePessoa,
    this.tabelaPrecoId,
    this.caixaAbertura,
    this.dataAbertura,
    this.previsaoFechamento,
    this.caixaFechamento,
    this.dataFechamento,
    this.funcionarioId,
    this.nomeFuncionario,
    this.observacao,
    this.situacao,
    this.motivoCancelamento,
    this.solicitado,
    this.valorSolicitado,
    this.devolvido,
    this.valorDevolvido,
    this.acertado,
    this.valorAcertado,
    this.pendente,
    this.valorPendente,
    this.operadorId,
    List<ConsignacaoItem>? itens,
  }) : itens = itens ?? const [];

  @override
  List<Object?> get props => [
        empresaId,
        id,
        pessoaId,
        nomePessoa,
        tabelaPrecoId,
        caixaAbertura,
        dataAbertura,
        previsaoFechamento,
        caixaFechamento,
        dataFechamento,
        funcionarioId,
        nomeFuncionario,
        observacao,
        situacao,
        motivoCancelamento,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
        itens,
      ];

  @override
  bool? get stringify => true;
}
