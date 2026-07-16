import 'package:core/equals.dart';
import 'package:financeiro/domain/models/caixa_do_historico.dart';

class MetaHistoricoDeCaixas extends Equatable {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const MetaHistoricoDeCaixas({
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

class PaginaHistoricoDeCaixas extends Equatable {
  final MetaHistoricoDeCaixas meta;
  final List<CaixaDoHistorico> items;

  const PaginaHistoricoDeCaixas({required this.meta, required this.items});

  @override
  List<Object?> get props => [meta, items];
}
