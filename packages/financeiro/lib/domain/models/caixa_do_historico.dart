import 'package:core/equals.dart';
import 'package:financeiro/domain/models/caixa.dart';

/// Item da listagem paginada de caixas (`GET /caixas`, FCXFP008) --
/// diferente de [Caixa] (usado em `/v1/caixas/aberto`), traz nome do
/// operador de abertura/fechamento e `id` já numérico (não string).
abstract class CaixaDoHistorico implements Equatable {
  int get id;
  int get empresaId;
  DateTime get data;
  int get terminalId;
  DateTime get abertura;
  double get valorAbertura;
  int get operadorAberturaId;
  String get operadorAberturaNome;
  DateTime? get fechamento;
  double? get valorFechamento;
  int? get operadorFechamentoId;
  String? get operadorFechamentoNome;
  SituacaoCaixa get situacao;

  factory CaixaDoHistorico.create({
    required int id,
    required int empresaId,
    required DateTime data,
    required int terminalId,
    required DateTime abertura,
    required double valorAbertura,
    required int operadorAberturaId,
    required String operadorAberturaNome,
    DateTime? fechamento,
    double? valorFechamento,
    int? operadorFechamentoId,
    String? operadorFechamentoNome,
    required SituacaoCaixa situacao,
  }) = _CaixaDoHistoricoImpl;

  @override
  List<Object?> get props => [
    id,
    empresaId,
    data,
    terminalId,
    abertura,
    valorAbertura,
    operadorAberturaId,
    operadorAberturaNome,
    fechamento,
    valorFechamento,
    operadorFechamentoId,
    operadorFechamentoNome,
    situacao,
  ];

  @override
  bool? get stringify => true;
}

class _CaixaDoHistoricoImpl implements CaixaDoHistorico {
  @override
  final int id;
  @override
  final int empresaId;
  @override
  final DateTime data;
  @override
  final int terminalId;
  @override
  final DateTime abertura;
  @override
  final double valorAbertura;
  @override
  final int operadorAberturaId;
  @override
  final String operadorAberturaNome;
  @override
  final DateTime? fechamento;
  @override
  final double? valorFechamento;
  @override
  final int? operadorFechamentoId;
  @override
  final String? operadorFechamentoNome;
  @override
  final SituacaoCaixa situacao;

  _CaixaDoHistoricoImpl({
    required this.id,
    required this.empresaId,
    required this.data,
    required this.terminalId,
    required this.abertura,
    required this.valorAbertura,
    required this.operadorAberturaId,
    required this.operadorAberturaNome,
    this.fechamento,
    this.valorFechamento,
    this.operadorFechamentoId,
    this.operadorFechamentoNome,
    required this.situacao,
  });

  @override
  List<Object?> get props => [
    id,
    empresaId,
    data,
    terminalId,
    abertura,
    valorAbertura,
    operadorAberturaId,
    operadorAberturaNome,
    fechamento,
    valorFechamento,
    operadorFechamentoId,
    operadorFechamentoNome,
    situacao,
  ];

  @override
  bool? get stringify => true;
}
