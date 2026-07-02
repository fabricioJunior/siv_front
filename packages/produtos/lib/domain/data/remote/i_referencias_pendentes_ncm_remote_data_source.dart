import 'package:produtos/models.dart';

class ReferenciasSemNcmResultado {
  final List<Referencia> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  const ReferenciasSemNcmResultado({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });
}

class AtualizarNcmEmMassaResultado {
  final int atualizadas;
  final int ignoradas;

  const AtualizarNcmEmMassaResultado({
    required this.atualizadas,
    required this.ignoradas,
  });
}

abstract class IReferenciasPendentesNcmRemoteDataSource {
  Future<ReferenciasSemNcmResultado> fetchReferenciasSemNcm({
    String? search,
    String orderBy,
    String orderDir,
    int page,
  });

  Future<AtualizarNcmEmMassaResultado> atualizarNcmEmMassa();
}
