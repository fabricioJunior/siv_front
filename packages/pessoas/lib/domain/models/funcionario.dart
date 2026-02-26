import 'package:core/equals.dart';

class Funcionario extends Equatable {
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final int empresaId;
  final int id;
  final String nome;
  final int pessoaId;
  final TipoFuncionario tipo;
  final bool inativo;

  const Funcionario({
    this.criadoEm,
    this.atualizadoEm,
    required this.empresaId,
    required this.id,
    required this.nome,
    required this.pessoaId,
    required this.tipo,
    required this.inativo,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      criadoEm: _toDateTime(json['criadoEm']),
      atualizadoEm: _toDateTime(json['atualizadoEm']),
      empresaId: _toInt(json['empresaId']),
      id: _toInt(json['id']),
      nome: (json['nome'] ?? '').toString(),
      pessoaId: _toInt(json['pessoaId']),
      tipo: _tipoFuncionarioFromJson(json['tipo']),
      inativo: _toBool(json['inativo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'empresaId': empresaId,
      'id': id,
      'nome': nome,
      'pessoaId': pessoaId,
      'tipo': _tipoFuncionarioToJson(tipo),
      'inativo': inativo,
    };
  }

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        empresaId,
        id,
        nome,
        pessoaId,
        tipo,
        inativo,
      ];
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
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

enum TipoFuncionario {
  comprador,
  vendedor,
  caixa,
  gerente,
}

TipoFuncionario _tipoFuncionarioFromJson(dynamic value) {
  final normalized = (value ?? '').toString().toLowerCase().trim();
  switch (normalized) {
    case 'comprador':
      return TipoFuncionario.comprador;
    case 'vendedor':
      return TipoFuncionario.vendedor;
    case 'caixa':
      return TipoFuncionario.caixa;
    case 'gerente':
      return TipoFuncionario.gerente;
    default:
      return TipoFuncionario.comprador;
  }
}

String _tipoFuncionarioToJson(TipoFuncionario value) {
  switch (value) {
    case TipoFuncionario.comprador:
      return 'Comprador';
    case TipoFuncionario.vendedor:
      return 'Vendedor';
    case TipoFuncionario.caixa:
      return 'Caixa';
    case TipoFuncionario.gerente:
      return 'Gerente';
  }
}
