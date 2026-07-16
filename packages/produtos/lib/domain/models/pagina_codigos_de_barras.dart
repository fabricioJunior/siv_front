import 'package:core/equals.dart';
import 'package:produtos/domain/models/codigo_barras_resumo.dart';

class MetaCodigosDeBarras extends Equatable {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const MetaCodigosDeBarras({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [
    totalItems,
    itemCount,
    itemsPerPage,
    totalPages,
    currentPage,
  ];
}

class PaginaCodigosDeBarras extends Equatable {
  final MetaCodigosDeBarras meta;
  final List<CodigoBarrasResumo> items;

  const PaginaCodigosDeBarras({required this.meta, required this.items});

  @override
  List<Object?> get props => [meta, items];
}
