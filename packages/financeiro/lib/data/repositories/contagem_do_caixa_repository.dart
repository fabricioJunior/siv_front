import 'package:financeiro/domain/data/remote/i_contagem_do_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

class ContagemDoCaixaRepository implements IContagemDoCaixaRepository {
  final IContagemDoCaixaRemoteDataSource remoteDataSource;

  ContagemDoCaixaRepository({required this.remoteDataSource});

  @override
  Future<ContagemDoCaixa?> recuperarContagemDoCaixa({
    required int caixaId,
  }) {
    return remoteDataSource.recuperarContagemDoCaixa(caixaId: caixaId);
  }

  @override
  Future<void> encerrarContagemDoCaixa({required int caixaId}) {
    return remoteDataSource.encerrarContagemDoCaixa(caixaId: caixaId);
  }

  @override
  Future<ContagemDoCaixa> salvarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) {
    if (contagemDoCaixa.id == null) {
      return remoteDataSource.criarItemDaContagemDoCaixa(
        caixaId: caixaId,
        contagemDoCaixa: contagemDoCaixa,
      );
    }

    return remoteDataSource.atualizarContagemDoCaixa(
      caixaId: caixaId,
      contagemDoCaixa: contagemDoCaixa,
    );
  }

  @override
  Future<List<ContagemDoCaixaItem>> recuperarItensPendentesParaContagemDoCaixa({
    required int caixaId,
  }) {
    return remoteDataSource.recuperarItensPendentesParaContagemDoCaixa(
      caixaId: caixaId,
    );
  }
}
