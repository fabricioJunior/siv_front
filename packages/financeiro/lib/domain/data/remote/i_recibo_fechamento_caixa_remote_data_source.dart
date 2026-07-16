import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

abstract class IReciboFechamentoCaixaRemoteDataSource {
  Future<ReciboFechamentoCaixa> recuperarReciboFechamento({
    required int caixaId,
  });
}
