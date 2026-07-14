import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

class ContagemDoCaixaItemDto implements ContagemDoCaixaItem {
  @override
  final int? id;

  @override
  final double valor;

  @override
  
  final TipoContagemDoCaixaItem tipoDocumento;

  const ContagemDoCaixaItemDto({
    this.id,
    required this.valor,
    required this.tipoDocumento,
  });

  factory ContagemDoCaixaItemDto.fromJson(Map<String, dynamic> json) {
    return ContagemDoCaixaItemDto(
      id: int.tryParse(json['id'] as String? ?? ''),
      valor: _parseDouble(json['valor'] ?? json['amount']) ?? 0.0,
      tipoDocumento: _parseTipo(json['tipoDocumento'] ?? json['type']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static TipoContagemDoCaixaItem _parseTipo(dynamic value) {
    final str = value?.toString() ?? '';
    final strNormalizado = _normalizarTexto(str);
    return TipoContagemDoCaixaItem.values.firstWhere(
      (e) =>
          e.name == str ||
          _normalizarTexto(e.name) == strNormalizado,
      orElse: () => TipoContagemDoCaixaItem.dinheiro,
    );
  }

  static String _normalizarTexto(String value) {
    return value
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
        // Remove espaços/barras/pontuação -- o enum local usa camelCase sem
        // separadores (ex: "creditoDeDevolucao", "tedDoc"), mas os labels que
        // vêm do backend têm espaço/barra ("Crédito de devolução", "TED/DOC").
        // Sem isso a comparação nunca batia pra esses tipos e o firstWhere
        // caía silenciosamente no orElse (dinheiro), fazendo pagamentos em
        // crédito de devolução serem contados como dinheiro físico na
        // contagem de caixa -- travando o fechamento.
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  List<Object?> get props => [id, valor, tipoDocumento];

  @override
  bool? get stringify => true;
}
