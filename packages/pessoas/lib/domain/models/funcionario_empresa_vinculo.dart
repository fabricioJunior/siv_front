import 'package:core/equals.dart';

class FuncionarioEmpresaVinculo extends Equatable {
  final int funcionarioId;
  final int empresaId;
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const FuncionarioEmpresaVinculo({
    required this.funcionarioId,
    required this.empresaId,
    required this.ativo,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory FuncionarioEmpresaVinculo.fromJson(Map<String, dynamic> json) {
    return FuncionarioEmpresaVinculo(
      funcionarioId: _toInt(json['funcionarioId']),
      empresaId: _toInt(json['empresaId']),
      ativo: _toBool(json['ativo']),
      criadoEm: _toDateTime(json['criadoEm']),
      atualizadoEm: _toDateTime(json['atualizadoEm']),
    );
  }

  FuncionarioEmpresaVinculo copyWith({bool? ativo}) {
    return FuncionarioEmpresaVinculo(
      funcionarioId: funcionarioId,
      empresaId: empresaId,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }

  @override
  List<Object?> get props =>
      [funcionarioId, empresaId, ativo, criadoEm, atualizadoEm];
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  if (value is num) return value != 0;
  return false;
}
