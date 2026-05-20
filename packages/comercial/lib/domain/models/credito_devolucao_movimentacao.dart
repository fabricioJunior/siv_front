import 'package:core/equals.dart';

abstract class CreditoDevolucaoMovimentacao implements Equatable {
  DateTime get criadoEm;
  DateTime get atualizadoEm;
  int get empresaId;
  DateTime get data;
  int get liquidacao;
  int get pessoaId;
  int? get faturaId;
  int? get romaneioId;
  int? get faturaParcela;
  String get tipoDocumento;
  String get tipoMovimento;
  double get valor;
  String? get descricao;
  String? get observacao;
  bool get cancelado;
  String? get motivoCancelamento;
  int get operadorId;

  factory CreditoDevolucaoMovimentacao.create({
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    required int empresaId,
    required DateTime data,
    required int liquidacao,
    required int pessoaId,
    int? faturaId,
    int? romaneioId,
    int? faturaParcela,
    required String tipoDocumento,
    required String tipoMovimento,
    required double valor,
    String? descricao,
    String? observacao,
    required bool cancelado,
    String? motivoCancelamento,
    required int operadorId,
  }) = _CreditoDevolucaoMovimentacaoImpl;

  double get valorAssinado {
    final movimentoNormalizado = tipoMovimento.trim().toLowerCase();

    if (movimentoNormalizado.contains('debito') ||
        movimentoNormalizado.contains('débito') ||
        movimentoNormalizado.contains('saida') ||
        movimentoNormalizado.contains('saída')) {
      return -valor.abs();
    }

    return valor.abs();
  }

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        empresaId,
        data,
        liquidacao,
        pessoaId,
        faturaId,
        romaneioId,
        faturaParcela,
        tipoDocumento,
        tipoMovimento,
        valor,
        descricao,
        observacao,
        cancelado,
        motivoCancelamento,
        operadorId,
      ];

  @override
  bool? get stringify => true;
}

class _CreditoDevolucaoMovimentacaoImpl
    implements CreditoDevolucaoMovimentacao {
  @override
  final DateTime criadoEm;
  @override
  final DateTime atualizadoEm;
  @override
  final int empresaId;
  @override
  final DateTime data;
  @override
  final int liquidacao;
  @override
  final int pessoaId;
  @override
  final int? faturaId;
  @override
  final int? romaneioId;
  @override
  final int? faturaParcela;
  @override
  final String tipoDocumento;
  @override
  final String tipoMovimento;
  @override
  final double valor;
  @override
  final String? descricao;
  @override
  final String? observacao;
  @override
  final bool cancelado;
  @override
  final String? motivoCancelamento;
  @override
  final int operadorId;

  const _CreditoDevolucaoMovimentacaoImpl({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.empresaId,
    required this.data,
    required this.liquidacao,
    required this.pessoaId,
    this.faturaId,
    this.romaneioId,
    this.faturaParcela,
    required this.tipoDocumento,
    required this.tipoMovimento,
    required this.valor,
    this.descricao,
    this.observacao,
    required this.cancelado,
    this.motivoCancelamento,
    required this.operadorId,
  });

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        empresaId,
        data,
        liquidacao,
        pessoaId,
        faturaId,
        romaneioId,
        faturaParcela,
        tipoDocumento,
        tipoMovimento,
        valor,
        descricao,
        observacao,
        cancelado,
        motivoCancelamento,
        operadorId,
      ];

  @override
  bool? get stringify => true;
  
  @override
  double get valorAssinado => 0;
}
