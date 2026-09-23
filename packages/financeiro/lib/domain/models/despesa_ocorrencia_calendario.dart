import 'package:core/equals.dart';
import 'package:financeiro/domain/models/despesa.dart';

/// Linha do calendário mensal de pagamentos (`GET /despesas/calendario`).
/// `virtual: true` e `despesaId == null` indica ocorrência de despesa
/// recorrente ainda não materializada nesse mês -- pagar/editar/cancelar
/// exige `POST /despesas/{despesaRecorrentePaiId}/ocorrencias`.
class DespesaOcorrenciaCalendario extends Equatable {
  final int? despesaId;
  final String descricao;
  final double valor;
  final int categoriaId;
  final int origemPagamentoId;
  final int? formaPagamentoId;
  final DateTime dataPagamento;
  final StatusDespesa status;
  final bool virtual;
  final int? despesaRecorrentePaiId;
  final String? grupoParcelamentoId;
  final int? numeroParcela;
  final int? totalParcelas;

  const DespesaOcorrenciaCalendario({
    this.despesaId,
    required this.descricao,
    required this.valor,
    required this.categoriaId,
    required this.origemPagamentoId,
    this.formaPagamentoId,
    required this.dataPagamento,
    required this.status,
    this.virtual = false,
    this.despesaRecorrentePaiId,
    this.grupoParcelamentoId,
    this.numeroParcela,
    this.totalParcelas,
  });

  /// Id usado para pagar/editar/cancelar essa ocorrência via
  /// `POST /despesas/{id}/ocorrencias` -- despesa concreta ou template
  /// recorrente quando ainda virtual.
  int? get idParaOcorrencia => despesaId ?? despesaRecorrentePaiId;

  @override
  List<Object?> get props => [
        despesaId,
        descricao,
        valor,
        categoriaId,
        origemPagamentoId,
        formaPagamentoId,
        dataPagamento,
        status,
        virtual,
        despesaRecorrentePaiId,
        grupoParcelamentoId,
        numeroParcela,
        totalParcelas,
      ];
}
