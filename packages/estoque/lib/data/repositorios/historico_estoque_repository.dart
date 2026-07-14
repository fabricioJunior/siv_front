import 'package:estoque/domain/data/remote/i_historico_estoque_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_historico_estoque_repository.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/pagina_historico_estoque.dart';

class HistoricoEstoqueRepository implements IHistoricoEstoqueRepository {
  final IHistoricoEstoqueRemoteDataSource historicoEstoqueRemoteDataSource;

  HistoricoEstoqueRepository({required this.historicoEstoqueRemoteDataSource});

  @override
  Future<PaginaHistoricoEstoque> obterHistorico({
    required FiltroHistoricoEstoque filtro,
  }) {
    return historicoEstoqueRemoteDataSource.obterHistorico(filtro: filtro);
  }
}
