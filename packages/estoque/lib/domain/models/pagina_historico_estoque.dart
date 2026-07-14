import 'package:core/equals.dart';
import 'package:estoque/domain/models/historico_estoque.dart';
import 'package:estoque/domain/models/paginacao_do_estoque.dart';

class PaginaHistoricoEstoque extends Equatable {
  final PaginacaoDoEstoque meta;
  final List<HistoricoEstoque> items;

  const PaginaHistoricoEstoque({required this.meta, required this.items});

  @override
  List<Object?> get props => [meta, items];
}
