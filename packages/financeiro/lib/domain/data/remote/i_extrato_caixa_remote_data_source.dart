import '../../models/extrato_caixa.dart';

abstract class IExtratoCaixaRemoteDataSource {
  Future<List<ExtratoCaixa>> buscarExtratoCaixa({
    required int caixaId,
  });

  Future<List<ExtratoCaixa>> buscarExtratoCaixaPorDocumento({
    required int caixaId,
    required String documento,
  });
}
