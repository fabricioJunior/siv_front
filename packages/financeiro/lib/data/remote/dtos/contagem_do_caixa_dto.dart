import 'package:financeiro/data/remote/dtos/contagem_do_caixa_item_dto.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

class ContagemDoCaixaDto implements ContagemDoCaixa {
  @override
  final int? id;

  @override
  final int caixaId;

  @override
  final String observacao;

  @override
  final List<ContagemDoCaixaItem> itens;

  const ContagemDoCaixaDto({
    this.id,
    required this.caixaId,
    this.observacao = '',
    this.itens = const [],
  });

  factory ContagemDoCaixaDto.fromJson(
    Map<String, dynamic> json, {
    required int caixaId,
  }) {
    final itensJson = json['itens'] ?? json['items'];
    final itens = itensJson is List
        ? itensJson
            .map((item) => ContagemDoCaixaItemDto.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList()
        : <ContagemDoCaixaItemDto>[];

    return ContagemDoCaixaDto(
      id: (json['id'] as num?)?.toInt(),
      caixaId: (json['caixaId'] as num?)?.toInt() ??
          (json['caixa']?['id'] as num?)?.toInt() ??
          caixaId,
      observacao: (json['observacao'] ?? json['observation'] ?? '').toString(),
      itens: itens,
    );
  }

  @override
  List<Object?> get props => [id, caixaId, observacao, itens];

  @override
  bool? get stringify => true;
}
