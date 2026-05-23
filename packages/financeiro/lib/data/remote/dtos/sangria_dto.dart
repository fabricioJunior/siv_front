import 'package:financeiro/domain/models/sangria.dart';

class SangriaDto implements Sangria {
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
  final String origem;

  @override
  final String descricao;

  @override
  final String? motivoCancelamento;

  @override
  final bool cancelado;

  const SangriaDto({
    this.criadoEm,
    this.atualizadoEm,
    this.canceladoEm,
    this.id,
    required this.caixaId,
    required this.valor,
    required this.origem,
    required this.descricao,
    this.motivoCancelamento,
    this.cancelado = false,
  });

  factory SangriaDto.fromJson(Map<String, dynamic> json) {
    final canceladoEm = _parseDateTime(
      json['canceladoEm'] ?? json['cancelledAt'] ?? json['deletedAt'],
    );

    return SangriaDto(
      criadoEm: _parseDateTime(json['criadoEm'] ?? json['createdAt']),
      atualizadoEm: _parseDateTime(json['atualizadoEm'] ?? json['updatedAt']),
      canceladoEm: canceladoEm,
      id: int.tryParse(json['id'].toString()),
      caixaId: int.tryParse(json['caixaId'].toString()) ??
          int.tryParse(json['caixa']?['id']?.toString() ?? '') ??
          0,
      valor: _parseDouble(json['valor'] ?? json['amount']) ?? 0,
      origem: (json['origem'] ?? json['source'] ?? 'externa').toString(),
      descricao: (json['descricao'] ?? json['description'] ?? '').toString(),
      motivoCancelamento:
          (json['motivoCancelamento'] ?? json['motivo'])?.toString(),
      cancelado: _parseBool(json['cancelado'] ?? json['cancelled']) ??
          canceladoEm != null,
    );
  }

  factory SangriaDto.fromModel(Sangria sangria) {
    return SangriaDto(
      criadoEm: sangria.criadoEm,
      atualizadoEm: sangria.atualizadoEm,
      canceladoEm: sangria.canceladoEm,
      id: sangria.id,
      caixaId: sangria.caixaId,
      valor: sangria.valor,
      origem: sangria.origem,
      descricao: sangria.descricao,
      motivoCancelamento: sangria.motivoCancelamento,
      cancelado: sangria.cancelado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caixaId': caixaId,
      'valor': valor,
      'origem': origem,
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
      'origem': origem,
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
        origem,
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
