import 'package:financeiro/domain/data/remote/i_despesas_do_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_do_caixa_repository.dart';
import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class DespesasDoCaixaRepository implements IDespesasDoCaixaRepository {
  final IDespesasDoCaixaRemoteDataSource remoteDataSource;

  DespesasDoCaixaRepository({required this.remoteDataSource});

  @override
  Future<DespesaDoCaixa> criarDespesa({
    required int caixaId,
    required double valor,
    required String descricao,
    required int categoriaId,
  }) {
    return remoteDataSource.criarDespesa(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
      categoriaId: categoriaId,
    );
  }

  @override
  Future<List<DespesaDoCaixa>> recuperarDespesas({required int caixaId}) {
    return remoteDataSource.recuperarDespesas(caixaId: caixaId);
  }

  @override
  Future<List<CategoriaDespesaDoCaixa>> recuperarCategorias({
    required int caixaId,
  }) {
    return remoteDataSource.recuperarCategorias(caixaId: caixaId);
  }

  @override
  Future<void> cancelarDespesa({
    required int caixaId,
    required int despesaId,
    required String motivo,
  }) {
    return remoteDataSource.cancelarDespesa(
      caixaId: caixaId,
      despesaId: despesaId,
      motivo: motivo,
    );
  }
}
