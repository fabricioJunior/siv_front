import 'package:financeiro/domain/models/despesa_do_caixa.dart';

abstract class IDespesasDoCaixaRemoteDataSource {
  Future<DespesaDoCaixa> criarDespesa({
    required int caixaId,
    required double valor,
    required String descricao,
    required int categoriaId,
  });

  Future<List<DespesaDoCaixa>> recuperarDespesas({required int caixaId});

  Future<List<CategoriaDespesaDoCaixa>> recuperarCategorias({
    required int caixaId,
  });

  Future<void> cancelarDespesa({
    required int caixaId,
    required int despesaId,
    required String motivo,
  });
}
