import 'package:financeiro/domain/models/extrato_caixa.dart';

class ExtratoCaixaDto implements ExtratoCaixa {
  @override
  final DateTime criadoEm;

  @override
  final DateTime atualizadoEm;

  @override
  final int empresaId;

  @override
  final DateTime data;

  @override
  final int caixaId;

  @override
  final int documento;

  @override
  final int liquidacao;

  @override
  final TipoDocumentoExtratoCaixa tipoDocumento;

  @override
  final TipoHistoricoExtratoCaixa tipoHistorico;

  @override
  final TipoMovimentoExtratoCaixa tipoMovimento;

  @override
  final double valor;

  @override
  final int? faturaId;

  @override
  final int? faturaParcela;

  @override
  final String? observacao;

  @override
  final bool cancelado;

  @override
  final String? motivoCancelamento;

  @override
  final int operadorId;

  ExtratoCaixaDto({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.empresaId,
    required this.data,
    required this.caixaId,
    required this.documento,
    required this.liquidacao,
    required this.tipoDocumento,
    required this.tipoHistorico,
    required this.tipoMovimento,
    required this.valor,
    required this.faturaId,
    required this.faturaParcela,
    required this.observacao,
    required this.cancelado,
    required this.motivoCancelamento,
    required this.operadorId,
  });

  factory ExtratoCaixaDto.fromJson(Map<String, dynamic> json) {
    return ExtratoCaixaDto(
      criadoEm: DateTime.tryParse(json['criadoEm']?.toString() ?? '') ??
          DateTime.now(),
      atualizadoEm: DateTime.tryParse(json['atualizadoEm']?.toString() ?? '') ??
          DateTime.now(),
      empresaId: (json['empresaId'] as num?)?.toInt() ?? 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      caixaId: (json['caixaId'] as num?)?.toInt() ?? 0,
      documento: (json['documento'] as num?)?.toInt() ?? 0,
      liquidacao: (json['liquidacao'] as num?)?.toInt() ?? 0,
      tipoDocumento:
          _tipoDocumentoFromJson(json['tipoDocumento']?.toString() ?? ''),
      tipoHistorico:
          _tipoHistoricoFromJson(json['tipoHistorico']?.toString() ?? ''),
      tipoMovimento:
          _tipoMovimentoFromJson(json['tipoMovimento']?.toString() ?? ''),
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      faturaId: (json['faturaId'] as num?)?.toInt(),
      faturaParcela: (json['faturaParcela'] as num?)?.toInt(),
      observacao: json['observacao']?.toString(),
      cancelado: json['cancelado'] == true,
      motivoCancelamento: json['motivoCancelamento']?.toString(),
      operadorId: (json['operadorId'] as num?)?.toInt() ?? 0,
    );
  }

  static TipoDocumentoExtratoCaixa _tipoDocumentoFromJson(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dinheiro':
      default:
        return TipoDocumentoExtratoCaixa.dinheiro;
    }
  }

  static TipoHistoricoExtratoCaixa _tipoHistoricoFromJson(String value) {
    switch (value.trim().toLowerCase()) {
      case 'abertura de caixa':
      default:
        return TipoHistoricoExtratoCaixa.aberturaDeCaixa;
    }
  }

  static TipoMovimentoExtratoCaixa _tipoMovimentoFromJson(String value) {
    switch (value.trim().toLowerCase()) {
      case 'crédito':
      case 'credito':
        return TipoMovimentoExtratoCaixa.credito;
      case 'débito':
      case 'debito':
      default:
        return TipoMovimentoExtratoCaixa.debito;
    }
  }
}
