import '../../models/caixa.dart';

abstract class ICaixaRemoteDataSource {
  Future<Caixa> abrirCaixa({
    required int idEmpresa,
    required int terminalId,
  });

  Future<Caixa?> recuperarCaixaAberto({
    required int idEmpresa,
    required int terminalId,
  });
}
