import 'package:core/equals.dart';

enum SituacaoCreditoDevolucao {
  disponivel,
  usado,
  expirado,
  removido;

  static SituacaoCreditoDevolucao de(Object? v) => values.firstWhere(
        (s) => s.name == v,
        orElse: () => SituacaoCreditoDevolucao.disponivel,
      );
}

/// Um crédito de devolução (por unidade): origem, validade, original/restante.
class CreditoDevolucao extends Equatable {
  final int id;
  final String codigo;
  final String origem;
  final String? motivo;
  final String? observacao;
  final int? romaneioId;
  final int? faturaId;
  final int? faturaParcela;
  final int empresaId;
  final String? empresaNome;
  final DateTime data;
  final DateTime? validade;
  final double valorOriginal;
  final double valorRestante;
  final SituacaoCreditoDevolucao situacao;
  final String? operadorNome;
  final DateTime? encerradoEm;
  final String? motivoEncerramento;

  const CreditoDevolucao({
    required this.id,
    required this.codigo,
    required this.origem,
    this.motivo,
    this.observacao,
    this.romaneioId,
    this.faturaId,
    this.faturaParcela,
    required this.empresaId,
    this.empresaNome,
    required this.data,
    this.validade,
    required this.valorOriginal,
    required this.valorRestante,
    required this.situacao,
    this.operadorNome,
    this.encerradoEm,
    this.motivoEncerramento,
  });

  /// Só crédito disponível com valor restante pode ser expirado/removido.
  bool get temSaldo =>
      situacao == SituacaoCreditoDevolucao.disponivel && valorRestante > 0;

  @override
  List<Object?> get props => [
        id,
        codigo,
        origem,
        motivo,
        observacao,
        romaneioId,
        faturaId,
        faturaParcela,
        empresaId,
        empresaNome,
        data,
        validade,
        valorOriginal,
        valorRestante,
        situacao,
        operadorNome,
        encerradoEm,
        motivoEncerramento,
      ];
}

class ResumoCreditoDevolucao extends Equatable {
  final double saldoDisponivel;
  final int quantidadeDisponiveis;
  final double venceEm30Dias;
  final DateTime? proximoVencimento;
  final double usado12Meses;
  final int vendasComUso12Meses;
  final double expirado12Meses;
  final int creditosExpirados12Meses;

  const ResumoCreditoDevolucao({
    this.saldoDisponivel = 0,
    this.quantidadeDisponiveis = 0,
    this.venceEm30Dias = 0,
    this.proximoVencimento,
    this.usado12Meses = 0,
    this.vendasComUso12Meses = 0,
    this.expirado12Meses = 0,
    this.creditosExpirados12Meses = 0,
  });

  @override
  List<Object?> get props => [
        saldoDisponivel,
        quantidadeDisponiveis,
        venceEm30Dias,
        proximoVencimento,
        usado12Meses,
        vendasComUso12Meses,
        expirado12Meses,
        creditosExpirados12Meses,
      ];
}

/// Retorno das ações (adicionar/remover/expirar): crédito atualizado e saldo novo.
class ResultadoAcaoCredito extends Equatable {
  final CreditoDevolucao credito;
  final double saldoDisponivel;

  const ResultadoAcaoCredito({
    required this.credito,
    required this.saldoDisponivel,
  });

  @override
  List<Object?> get props => [credito, saldoDisponivel];
}
