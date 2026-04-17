import 'package:financeiro/domain/data/remote/i_contagem_do_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';

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
  Future<void> salvarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) {
    return remoteDataSource.salvarItemDaContagemDoCaixa(
      caixaId: caixaId,
      contagemDoCaixa: contagemDoCaixa,
    );
  }
}
