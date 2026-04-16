import 'package:financeiro/domain/models/caixa.dart';

class CaixaDto implements Caixa {
  @override
  final int id;

  @override
  final int empresaId;

  @override
  final DateTime data;

  @override
  final int terminalId;

  @override
  final DateTime abertura;

  @override
  final DateTime? fechamento;

  @override
  final double valorAbertura;

  @override
  final double? valorFechamento;

  @override
  final SituacaoCaixa situacao;

  CaixaDto({
    required this.id,
    required this.empresaId,
    required this.data,
    required this.terminalId,
    required this.abertura,
    required this.fechamento,
    required this.valorAbertura,
    required this.valorFechamento,
    required this.situacao,
  });

  factory CaixaDto.fromJson(Map<String, dynamic> json) {
    final situacaoValue =
        (json['situacao']?.toString().toLowerCase() ?? 'aberto').trim();

    return CaixaDto(
      id: int.parse(json['id'] as String),
      empresaId: (json['empresaId'] as num?)?.toInt() ?? 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      terminalId: (json['terminalId'] as num?)?.toInt() ?? 0,
      abertura: DateTime.tryParse(json['abertura']?.toString() ?? '') ??
          DateTime.now(),
      fechamento: json['fechamento'] == null
          ? null
          : DateTime.tryParse(json['fechamento']?.toString() ?? ''),
      valorAbertura:
          double.tryParse(json['valorAbertura']?.toString() ?? '0') ?? 0,
      valorFechamento: (json['valorFechamento'] as num?)?.toDouble(),
      situacao: situacaoValue == 'fechado'
          ? SituacaoCaixa.fechado
          : SituacaoCaixa.aberto,
    );
  }
}
