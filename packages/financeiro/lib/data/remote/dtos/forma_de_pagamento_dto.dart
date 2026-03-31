import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class FormaDePagamentoDto implements FormaDePagamento {
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

  const FormaDePagamentoDto({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    required this.descricao,
    required this.inicio,
    required this.parcelas,
    required this.tipo,
    this.inativa = false,
  });

  factory FormaDePagamentoDto.fromJson(Map<String, dynamic> json) {
    return FormaDePagamentoDto(
      criadoEm: _parseDateTime(json['criadoEm']),
      atualizadoEm: _parseDateTime(json['atualizadoEm']),
      id: (json['id'] as num?)?.toInt(),
      descricao: (json['descricao'] as String?) ?? '',
      inicio: (json['inicio'] as num?)?.toInt() ?? 0,
      parcelas: (json['parcelas'] as num?)?.toInt() ?? 0,
      tipo: (json['tipo'] as String?) ?? 'Dinheiro',
      inativa: json['inativa'] as bool? ?? false,
    );
  }

  factory FormaDePagamentoDto.fromModel(FormaDePagamento forma) {
    return FormaDePagamentoDto(
      criadoEm: forma.criadoEm,
      atualizadoEm: forma.atualizadoEm,
      id: forma.id,
      descricao: forma.descricao,
      inicio: forma.inicio,
      parcelas: forma.parcelas,
      tipo: forma.tipo,
      inativa: forma.inativa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'id': id,
      'descricao': descricao,
      'inicio': inicio,
      'parcelas': parcelas,
      'tipo': tipo,
      'inativa': inativa,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'descricao': descricao,
      'inicio': inicio,
      'parcelas': parcelas,
      'tipo': tipo,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'descricao': descricao,
      'inicio': inicio,
      'parcelas': parcelas,
      'tipo': tipo,
      'inativa': inativa,
    };
  }

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
      ];

  @override
  bool? get stringify => true;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(value.toString());
}
