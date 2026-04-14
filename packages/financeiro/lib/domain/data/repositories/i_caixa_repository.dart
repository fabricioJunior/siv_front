import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/extrato_caixa.dart';

abstract class ICaixaRepository {
  Future<Caixa> abrirCaixa({
    required int idEmpresa,
    required int terminalId,
  });

  Future<Caixa?> recuperarCaixaAberto({
    required int idEmpresa,
    required int terminalId,
  });

  Future<List<ExtratoCaixa>> buscarExtratoCaixa({
    required int caixaId,
  });

  Future<List<ExtratoCaixa>> buscarExtratoCaixaPorDocumento({
    required int caixaId,
    required String documento,
  });
}
