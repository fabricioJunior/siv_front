import 'package:precos/models.dart';

class PrecoDaReferenciaDto implements PrecoDaReferencia {
  @override
  final DateTime criadoEm;
  @override
  final DateTime atualizadoEm;
  @override
  final int tabelaDePrecoId;
  @override
  final int referenciaId;
  @override
  final String referenciaIdExterno;
  @override
  final String referenciaNome;
  @override
  final double valor;
  @override
  final int operadorId;

  const PrecoDaReferenciaDto({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.valor,
    required this.operadorId,
  });

  factory PrecoDaReferenciaDto.fromJson(Map<String, dynamic> json) {
    return PrecoDaReferenciaDto(
      criadoEm: _parseDate(json['criadoEm']),
      atualizadoEm: _parseDate(json['atualizadoEm']),
      tabelaDePrecoId: _parseInt(json['tabelaDePrecoId']),
      referenciaId: _parseInt(json['referenciaId']),
      referenciaIdExterno: (json['referenciaIdExterno'] ?? '').toString(),
      referenciaNome: (json['referenciaNome'] ?? '').toString(),
      valor: _parseDouble(json['valor']),
      operadorId: _parseInt(json['operadorId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
      'tabelaDePrecoId': tabelaDePrecoId,
      'referenciaId': referenciaId,
      'referenciaIdExterno': referenciaIdExterno,
      'referenciaNome': referenciaNome,
      'valor': valor,
      'operadorId': operadorId,
    };
  }

  @override
  List<Object?> get props => [
    criadoEm,
    atualizadoEm,
    tabelaDePrecoId,
    referenciaId,
    referenciaIdExterno,
    referenciaNome,
    valor,
    operadorId,
  ];

  @override
  bool? get stringify => true;

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse((value ?? '').toString());
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    final normalized = (value ?? '').toString().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }
}
