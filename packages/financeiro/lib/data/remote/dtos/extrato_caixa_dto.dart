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
      empresaId: json['empresaId'] as int? ?? 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      caixaId: int.tryParse(json['caixaId']?.toString() ?? '') ?? 0,
      documento: int.tryParse(json['documento']?.toString() ?? '') ?? 0,
      liquidacao: int.tryParse(json['liquidacao']?.toString() ?? '') ?? 0,
      tipoDocumento:
          _tipoDocumentoFromJson(json['tipoDocumento']?.toString() ?? ''),
      tipoHistorico:
          _tipoHistoricoFromJson(json['tipoHistorico']?.toString() ?? ''),
      tipoMovimento:
          _tipoMovimentoFromJson(json['tipoMovimento']?.toString() ?? ''),
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      faturaId:  int.tryParse(json['faturaId']?.toString() ?? '') ?? 0,
      faturaParcela: int.tryParse(json['faturaParcela']?.toString() ?? '') ?? 0,
      observacao: json['observacao']?.toString(),
      cancelado: json['cancelado'] == true,
      motivoCancelamento: json['motivoCancelamento']?.toString(),
      operadorId: int.tryParse(json['operadorId']?.toString() ?? '') ?? 0,
    );
  }

  static TipoDocumentoExtratoCaixa _tipoDocumentoFromJson(String value) {
    switch (_normalizar(value)) {
      case 'pix':
        return TipoDocumentoExtratoCaixa.pix;
      case 'cartao':
        return TipoDocumentoExtratoCaixa.cartao;
      case 'cheque':
        return TipoDocumentoExtratoCaixa.cheque;
      case 'fatura':
        return TipoDocumentoExtratoCaixa.fatura;
      case 'troco':
        return TipoDocumentoExtratoCaixa.troco;
      case 'voucher':
        return TipoDocumentoExtratoCaixa.voucher;
      case 'ted_doc':
      case 'teddoc':
        return TipoDocumentoExtratoCaixa.tedDoc;
      case 'adiantamento':
        return TipoDocumentoExtratoCaixa.adiantamento;
      case 'credito_de_devolucao':
      case 'creditodevolucao':
        return TipoDocumentoExtratoCaixa.creditoDeDevolucao;
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

  static String _normalizar(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
