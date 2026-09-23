import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class OrigemPagamentoDespesaDto extends OrigemPagamentoDespesa {
  const OrigemPagamentoDespesaDto({
    super.id,
    super.empresaId,
    required super.nome,
    required super.tipo,
    super.diaVencimento,
    super.prazoFechamentoDias,
  });

  factory OrigemPagamentoDespesaDto.fromJson(Map<String, dynamic> json) {
    return OrigemPagamentoDespesaDto(
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      nome: (json['nome'] as String?) ?? '',
      tipo: TipoOrigemPagamentoDespesa.fromString(json['tipo'] as String?),
      diaVencimento: (json['diaVencimento'] as num?)?.toInt(),
      prazoFechamentoDias: (json['prazoFechamentoDias'] as num?)?.toInt(),
    );
  }

  factory OrigemPagamentoDespesaDto.fromModel(OrigemPagamentoDespesa origem) {
    return OrigemPagamentoDespesaDto(
      id: origem.id,
      empresaId: origem.empresaId,
      nome: origem.nome,
      tipo: origem.tipo,
      diaVencimento: origem.diaVencimento,
      prazoFechamentoDias: origem.prazoFechamentoDias,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (empresaId != null) 'empresaId': empresaId,
      'nome': nome,
      'tipo': tipo.value,
      if (tipo == TipoOrigemPagamentoDespesa.cartaoCredito) ...{
        'diaVencimento': diaVencimento,
        'prazoFechamentoDias': prazoFechamentoDias,
      },
    };
  }
}
