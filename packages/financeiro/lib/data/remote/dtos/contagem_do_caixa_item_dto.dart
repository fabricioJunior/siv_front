import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

class ContagemDoCaixaItemDto implements ContagemDoCaixaItem {
  @override
  final int? id;

  @override
  final double valor;

  @override
  final TipoContagemDoCaixaItem tipo;

  const ContagemDoCaixaItemDto({
    this.id,
    required this.valor,
    required this.tipo,
  });

  factory ContagemDoCaixaItemDto.fromJson(Map<String, dynamic> json) {
    return ContagemDoCaixaItemDto(
      id: (json['id'] as num?)?.toInt(),
      valor: _parseDouble(json['valor'] ?? json['amount']) ?? 0.0,
      tipo: _parseTipo(json['tipo'] ?? json['type']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static TipoContagemDoCaixaItem _parseTipo(dynamic value) {
    final str = value?.toString() ?? '';
    return TipoContagemDoCaixaItem.values.firstWhere(
      (e) => e.name == str || e.name.toLowerCase() == str.toLowerCase(),
      orElse: () => TipoContagemDoCaixaItem.dinheiro,
    );
  }

  @override
  List<Object?> get props => [id, valor, tipo];

  @override
  bool? get stringify => true;
}
