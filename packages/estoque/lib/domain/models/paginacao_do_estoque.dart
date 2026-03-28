import 'package:core/equals.dart';

class PaginacaoDoEstoque extends Equatable {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const PaginacaoDoEstoque({
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
