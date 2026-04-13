import '../../models/caixa.dart';

abstract class ICaixaRemoteDataSource {
  Future<Caixa> abrirCaixa({
    int idEmpresa,
    int terminalId,
  });
}
