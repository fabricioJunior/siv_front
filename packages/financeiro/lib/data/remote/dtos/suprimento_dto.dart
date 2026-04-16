import 'package:financeiro/domain/models/suprimento.dart';

class SuprimentoDto implements Suprimento {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final DateTime? canceladoEm;

  @override
  final int? id;

  @override
  final int caixaId;

  @override
  final double valor;

  @override
  final String descricao;

  @override
  final String? motivoCancelamento;

  @override
  final bool cancelado;

  const SuprimentoDto({
    this.criadoEm,
    this.atualizadoEm,
    this.canceladoEm,
    this.id,
    required this.caixaId,
    required this.valor,
    required this.descricao,
    this.motivoCancelamento,
    this.cancelado = false,
  });

  factory SuprimentoDto.fromJson(Map<String, dynamic> json) {
    final canceladoEm = _parseDateTime(
      json['canceladoEm'] ?? json['cancelledAt'] ?? json['deletedAt'],
    );

    return SuprimentoDto(
      criadoEm: _parseDateTime(json['criadoEm'] ?? json['createdAt']),
      atualizadoEm: _parseDateTime(json['atualizadoEm'] ?? json['updatedAt']),
      canceladoEm: canceladoEm,
      id: (json['id'] as num?)?.toInt(),
      caixaId: (json['caixaId'] as num?)?.toInt() ??
          (json['caixa']?['id'] as num?)?.toInt() ??
          0,
      valor: _parseDouble(json['valor'] ?? json['amount']) ?? 0,
      descricao: (json['descricao'] ?? json['description'] ?? '').toString(),
      motivoCancelamento:
          (json['motivoCancelamento'] ?? json['motivo'])?.toString(),
      cancelado: _parseBool(json['cancelado'] ?? json['cancelled']) ??
          canceladoEm != null,
    );
  }

  factory SuprimentoDto.fromModel(Suprimento suprimento) {
    return SuprimentoDto(
      criadoEm: suprimento.criadoEm,
      atualizadoEm: suprimento.atualizadoEm,
      canceladoEm: suprimento.canceladoEm,
      id: suprimento.id,
      caixaId: suprimento.caixaId,
      valor: suprimento.valor,
      descricao: suprimento.descricao,
      motivoCancelamento: suprimento.motivoCancelamento,
      cancelado: suprimento.cancelado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caixaId': caixaId,
      'valor': valor,
      'descricao': descricao,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'canceladoEm': canceladoEm?.toIso8601String(),
      'motivoCancelamento': motivoCancelamento,
      'cancelado': cancelado,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'valor': valor,
      'descricao': descricao,
    };
  }

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        canceladoEm,
        id,
        caixaId,
        valor,
        descricao,
        motivoCancelamento,
        cancelado,
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

double? _parseDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString().replaceAll(',', '.'));
}

bool? _parseBool(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is bool) {
    return value;
  }

  final texto = value.toString().trim().toLowerCase();
  if (texto == 'true' || texto == '1') {
    return true;
  }
  if (texto == 'false' || texto == '0') {
    return false;
  }

  return null;
}
