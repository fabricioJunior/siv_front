import 'package:produtos/models.dart';

class ReferenciasSemPesoResultado {
  final List<Referencia> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  const ReferenciasSemPesoResultado({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });
}

class AtualizarDadosLogisticosEmMassaResultado {
  final int atualizadas;
  final int ignoradas;

  const AtualizarDadosLogisticosEmMassaResultado({
    required this.atualizadas,
    required this.ignoradas,
  });
}

abstract class IReferenciasPendentesPesoRemoteDataSource {
  Future<ReferenciasSemPesoResultado> fetchReferenciasSemPeso({
    String? search,
    String orderBy,
    String orderDir,
    int page,
  });

  Future<AtualizarDadosLogisticosEmMassaResultado>
      atualizarDadosLogisticosEmMassa();
}
