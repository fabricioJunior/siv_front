import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';

class DespesaOcorrenciaCalendarioDto extends DespesaOcorrenciaCalendario {
  const DespesaOcorrenciaCalendarioDto({
    super.despesaId,
    required super.descricao,
    required super.valor,
    required super.categoriaId,
    required super.origemPagamentoId,
    super.formaPagamentoId,
    required super.dataPagamento,
    required super.status,
    super.virtual,
    super.despesaRecorrentePaiId,
    super.grupoParcelamentoId,
    super.numeroParcela,
    super.totalParcelas,
  });

  factory DespesaOcorrenciaCalendarioDto.fromJson(Map<String, dynamic> json) {
    return DespesaOcorrenciaCalendarioDto(
      despesaId: (json['despesaId'] as num?)?.toInt(),
      descricao: (json['descricao'] as String?) ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      categoriaId: (json['categoriaId'] as num?)?.toInt() ?? 0,
      origemPagamentoId: (json['origemPagamentoId'] as num?)?.toInt() ?? 0,
      formaPagamentoId: (json['formaPagamentoId'] as num?)?.toInt(),
      dataPagamento:
          DateTime.tryParse(json['dataPagamento']?.toString() ?? '') ??
              DateTime.now(),
      status: StatusDespesa.fromString(json['status'] as String?),
      virtual: json['virtual'] as bool? ?? false,
      despesaRecorrentePaiId:
          (json['despesaRecorrentePaiId'] as num?)?.toInt(),
      grupoParcelamentoId: json['grupoParcelamentoId']?.toString(),
      numeroParcela: (json['numeroParcela'] as num?)?.toInt(),
      totalParcelas: (json['totalParcelas'] as num?)?.toInt(),
    );
  }
}
