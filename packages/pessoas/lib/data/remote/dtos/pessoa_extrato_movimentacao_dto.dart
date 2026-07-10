import 'package:pessoas/domain/models/pessoa_extrato_movimentacao.dart';

class PessoaExtratoMovimentacaoDto implements PessoaExtratoMovimentacao {
  @override
  final int empresaId;
  @override
  final int pessoaId;
  @override
  final DateTime data;
  @override
  final String tipoDocumento;
  @override
  final String tipoMovimento;
  @override
  final double valor;
  @override
  final int? romaneioId;
  @override
  final int? faturaId;
  @override
  final int? liquidacao;
  @override
  final String? descricao;
  @override
  final String? observacao;

  const PessoaExtratoMovimentacaoDto({
    required this.empresaId,
    required this.pessoaId,
    required this.data,
    required this.tipoDocumento,
    required this.tipoMovimento,
    required this.valor,
    this.romaneioId,
    this.faturaId,
    this.liquidacao,
    this.descricao,
    this.observacao,
  });

  factory PessoaExtratoMovimentacaoDto.fromJson(Map<String, dynamic> json) {
    return PessoaExtratoMovimentacaoDto(
      empresaId: _toInt(json['empresaId']) ?? 0,
      pessoaId: _toInt(json['pessoaId']) ?? 0,
      data: _toDate(json['data']) ?? DateTime.now(),
      tipoDocumento: json['tipoDocumento']?.toString() ?? '-',
      tipoMovimento: json['tipoMovimento']?.toString() ?? '-',
      valor: _toDouble(json['valor']) ?? 0,
      romaneioId: _toInt(json['romaneioId']),
      faturaId: _toInt(json['faturaId']),
      liquidacao: _toInt(json['liquidacao']),
      descricao: json['descricao']?.toString(),
      observacao: json['observacao']?.toString(),
    );
  }

  @override
  double get valorAssinado {
    final movimentoNormalizado = tipoMovimento.trim().toLowerCase();

    if (movimentoNormalizado.contains('debito') ||
        movimentoNormalizado.contains('débito') ||
        movimentoNormalizado.contains('saida') ||
        movimentoNormalizado.contains('saída')) {
      return -valor.abs();
    }

    return valor.abs();
  }

  @override
  List<Object?> get props => [
        empresaId,
        pessoaId,
        data,
        tipoDocumento,
        tipoMovimento,
        valor,
        romaneioId,
        faturaId,
        liquidacao,
        descricao,
        observacao,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) => (value as num?)?.toDouble();

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
