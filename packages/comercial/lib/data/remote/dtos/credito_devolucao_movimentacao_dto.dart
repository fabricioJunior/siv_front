import 'package:comercial/models.dart';

class CreditoDevolucaoMovimentacaoDto implements CreditoDevolucaoMovimentacao {
  @override
  final DateTime criadoEm;
  @override
  final DateTime atualizadoEm;
  @override
  final int empresaId;
  @override
  final DateTime data;
  @override
  final int liquidacao;
  @override
  final int pessoaId;
  @override
  final int? faturaId;
  @override
  final int? romaneioId;
  @override
  final int? faturaParcela;
  @override
  final String tipoDocumento;
  @override
  final String tipoMovimento;
  @override
  final double valor;
  @override
  final String? descricao;
  @override
  final String? observacao;
  @override
  final bool cancelado;
  @override
  final String? motivoCancelamento;
  @override
  final int operadorId;

  const CreditoDevolucaoMovimentacaoDto({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.empresaId,
    required this.data,
    required this.liquidacao,
    required this.pessoaId,
    this.faturaId,
    this.romaneioId,
    this.faturaParcela,
    required this.tipoDocumento,
    required this.tipoMovimento,
    required this.valor,
    this.descricao,
    this.observacao,
    required this.cancelado,
    this.motivoCancelamento,
    required this.operadorId,
  });

  factory CreditoDevolucaoMovimentacaoDto.fromJson(Map<String, dynamic> json) {
    return CreditoDevolucaoMovimentacaoDto(
      criadoEm: _toDate(json['criadoEm']) ?? DateTime.now(),
      atualizadoEm: _toDate(json['atualizadoEm']) ?? DateTime.now(),
      empresaId: _toInt(json['empresaId']) ?? 0,
      data: _toDate(json['data']) ?? DateTime.now(),
      liquidacao: _toInt(json['liquidacao']) ?? 0,
      pessoaId: _toInt(json['pessoaId']) ?? 0,
      faturaId: _toInt(json['faturaId']),
      romaneioId: _toInt(json['romaneioId']),
      faturaParcela: _toInt(json['faturaParcela']),
      tipoDocumento: json['tipoDocumento']?.toString() ?? '',
      tipoMovimento: json['tipoMovimento']?.toString() ?? '',
      valor: _toDouble(json['valor']) ?? 0,
      descricao: json['descricao']?.toString(),
      observacao: json['observacao']?.toString(),
      cancelado: json['cancelado'] == true,
      motivoCancelamento: json['motivoCancelamento']?.toString(),
      operadorId: _toInt(json['operadorId']) ?? 0,
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
        criadoEm,
        atualizadoEm,
        empresaId,
        data,
        liquidacao,
        pessoaId,
        faturaId,
        romaneioId,
        faturaParcela,
        tipoDocumento,
        tipoMovimento,
        valor,
        descricao,
        observacao,
        cancelado,
        motivoCancelamento,
        operadorId,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
