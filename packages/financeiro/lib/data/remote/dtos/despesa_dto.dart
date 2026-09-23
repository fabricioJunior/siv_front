import 'package:financeiro/domain/models/despesa.dart';

class DespesaDto extends Despesa {
  const DespesaDto({
    super.id,
    super.empresaId,
    required super.descricao,
    required super.valor,
    required super.categoriaId,
    required super.origemPagamentoId,
    super.formaPagamentoId,
    super.caixaId,
    super.dataPagamento,
    super.status,
    super.recorrente,
    super.diaVencimento,
    super.parcelas,
    super.grupoParcelamentoId,
    super.numeroParcela,
    super.totalParcelas,
  });

  factory DespesaDto.fromJson(Map<String, dynamic> json) {
    return DespesaDto(
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      descricao: (json['descricao'] as String?) ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      categoriaId: (json['categoriaId'] as num?)?.toInt() ?? 0,
      origemPagamentoId: (json['origemPagamentoId'] as num?)?.toInt() ?? 0,
      formaPagamentoId: (json['formaPagamentoId'] as num?)?.toInt(),
      caixaId: (json['caixaId'] as num?)?.toInt(),
      dataPagamento: json['dataPagamento'] == null
          ? null
          : DateTime.tryParse(json['dataPagamento'].toString()),
      status: json['status'] == null
          ? null
          : StatusDespesa.fromString(json['status'] as String?),
      recorrente: json['recorrente'] as bool? ?? false,
      diaVencimento: (json['diaVencimento'] as num?)?.toInt(),
      parcelas: (json['parcelas'] as num?)?.toInt(),
      grupoParcelamentoId: json['grupoParcelamentoId']?.toString(),
      numeroParcela: (json['numeroParcela'] as num?)?.toInt(),
      totalParcelas: (json['totalParcelas'] as num?)?.toInt(),
    );
  }

  factory DespesaDto.fromModel(Despesa despesa) {
    return DespesaDto(
      id: despesa.id,
      empresaId: despesa.empresaId,
      descricao: despesa.descricao,
      valor: despesa.valor,
      categoriaId: despesa.categoriaId,
      origemPagamentoId: despesa.origemPagamentoId,
      formaPagamentoId: despesa.formaPagamentoId,
      caixaId: despesa.caixaId,
      dataPagamento: despesa.dataPagamento,
      status: despesa.status,
      recorrente: despesa.recorrente,
      diaVencimento: despesa.diaVencimento,
      parcelas: despesa.parcelas,
      grupoParcelamentoId: despesa.grupoParcelamentoId,
      numeroParcela: despesa.numeroParcela,
      totalParcelas: despesa.totalParcelas,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      if (empresaId != null) 'empresaId': empresaId,
      'descricao': descricao,
      'valor': valor,
      'categoriaId': categoriaId,
      'origemPagamentoId': origemPagamentoId,
      if (formaPagamentoId != null) 'formaPagamentoId': formaPagamentoId,
      if (caixaId != null) 'caixaId': caixaId,
      if (dataPagamento != null)
        'dataPagamento': dataPagamento!.toIso8601String(),
      if (status != null) 'status': status!.value,
      if (recorrente) 'recorrente': recorrente,
      if (diaVencimento != null) 'diaVencimento': diaVencimento,
      if (parcelas != null) 'parcelas': parcelas,
    };
  }
}
