import 'package:estoque/data/remote/dtos/produto_do_estoque_dto.dart';
import 'package:estoque/domain/models/paginacao_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saldo_do_estoque_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SaldoDoEstoqueDto implements SaldoDoEstoque {
  @override
  final MetaSaldoDoEstoqueDto meta;

  @override
  final List<ProdutoDoEstoqueDto> items;

  SaldoDoEstoqueDto({required this.meta, required this.items});

  factory SaldoDoEstoqueDto.fromJson(Map<String, dynamic> json) =>
      _$SaldoDoEstoqueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SaldoDoEstoqueDtoToJson(this);

  @override
  List<Object?> get props => [meta, items];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class MetaSaldoDoEstoqueDto implements PaginacaoDoEstoque {
  @override
  final int totalItems;

  @override
  final int itemCount;

  @override
  final int itemsPerPage;

  @override
  final int totalPages;

  @override
  final int currentPage;

  MetaSaldoDoEstoqueDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory MetaSaldoDoEstoqueDto.fromJson(Map<String, dynamic> json) =>
      _$MetaSaldoDoEstoqueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MetaSaldoDoEstoqueDtoToJson(this);

  @override
  List<Object?> get props => [
    totalItems,
    itemCount,
    itemsPerPage,
    totalPages,
    currentPage,
  ];

  @override
  bool? get stringify => true;
}
