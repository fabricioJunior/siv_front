import 'package:produtos/domain/data/remote/i_referencias_pendentes_ncm_remote_data_source.dart';

export 'package:produtos/domain/data/remote/i_referencias_pendentes_ncm_remote_data_source.dart'
    show ReferenciasSemNcmResultado, AtualizarNcmEmMassaResultado;

abstract class IReferenciasPendentesNcmRepository {
  Future<ReferenciasSemNcmResultado> obterReferenciasSemNcm({
    String? search,
    String orderBy,
    String orderDir,
    int page,
  });

  Future<AtualizarNcmEmMassaResultado> atualizarNcmEmMassa();
}
