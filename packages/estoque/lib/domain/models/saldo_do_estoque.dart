import 'package:core/equals.dart';
import 'package:estoque/domain/models/paginacao_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';

class SaldoDoEstoque extends Equatable {
  final PaginacaoDoEstoque meta;
  final List<ProdutoDoEstoque> items;

  const SaldoDoEstoque({required this.meta, required this.items});

  @override
  List<Object?> get props => [meta, items];
}
