import 'package:financeiro/data/remote/dtos/contagem_do_caixa_item_dto.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';
import 'package:financeiro/domain/models/faturamento_do_caixa.dart';

class FaturamentoItemDto implements FaturamentoItem {
  @override
  final TipoContagemDoCaixaItem tipoDocumento;

  @override
  final double valor;

  const FaturamentoItemDto({required this.tipoDocumento, required this.valor});

  factory FaturamentoItemDto.fromJson(Map<String, dynamic> json) {
    // Reaproveita o parsing de tipoDocumento de ContagemDoCaixaItemDto -- mesmos labels
    // (acentuados/com barra) vindos do backend, mesma normalização já corrigida lá.
    final item = ContagemDoCaixaItemDto.fromJson(json);
    return FaturamentoItemDto(tipoDocumento: item.tipoDocumento, valor: item.valor);
  }
}

class FaturamentoDoCaixaDto implements FaturamentoDoCaixa {
  @override
  final List<FaturamentoItem> contabilizado;

  @override
  final List<FaturamentoItem> naoContabilizado;

  @override
  final double totalContabilizado;

  @override
  final double totalNaoContabilizado;

  @override
  final double totalFaturamento;

  const FaturamentoDoCaixaDto({
    required this.contabilizado,
    required this.naoContabilizado,
    required this.totalContabilizado,
    required this.totalNaoContabilizado,
    required this.totalFaturamento,
  });

  factory FaturamentoDoCaixaDto.fromJson(Map<String, dynamic> json) {
    List<FaturamentoItem> parseLista(dynamic valor) => (valor as List? ?? [])
        .map((e) => FaturamentoItemDto.fromJson(e as Map<String, dynamic>))
        .toList();

    double parseDouble(dynamic valor) => (valor as num?)?.toDouble() ?? 0.0;

    return FaturamentoDoCaixaDto(
      contabilizado: parseLista(json['contabilizado']),
      naoContabilizado: parseLista(json['naoContabilizado']),
      totalContabilizado: parseDouble(json['totalContabilizado']),
      totalNaoContabilizado: parseDouble(json['totalNaoContabilizado']),
      totalFaturamento: parseDouble(json['totalFaturamento']),
    );
  }
}
