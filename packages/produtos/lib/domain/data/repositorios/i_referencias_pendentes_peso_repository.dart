import 'package:produtos/domain/data/remote/i_referencias_pendentes_peso_remote_data_source.dart';

export 'package:produtos/domain/data/remote/i_referencias_pendentes_peso_remote_data_source.dart'
    show ReferenciasSemPesoResultado, AtualizarDadosLogisticosEmMassaResultado;

abstract class IReferenciasPendentesPesoRepository {
  Future<ReferenciasSemPesoResultado> obterReferenciasSemPeso({
    String? search,
    String orderBy,
    String orderDir,
    int page,
  });

  Future<AtualizarDadosLogisticosEmMassaResultado>
      atualizarDadosLogisticosEmMassa();
}
