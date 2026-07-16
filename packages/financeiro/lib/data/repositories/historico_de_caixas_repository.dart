import 'package:financeiro/domain/data/remote/i_historico_de_caixas_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_historico_de_caixas_repository.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/domain/models/pagina_historico_de_caixas.dart';

class HistoricoDeCaixasRepository implements IHistoricoDeCaixasRepository {
  final IHistoricoDeCaixasRemoteDataSource historicoDeCaixasRemoteDataSource;

  HistoricoDeCaixasRepository({
    required this.historicoDeCaixasRemoteDataSource,
  });

  @override
  Future<PaginaHistoricoDeCaixas> obterHistorico({
    required FiltroHistoricoDeCaixas filtro,
  }) {
    return historicoDeCaixasRemoteDataSource.obterHistorico(filtro: filtro);
  }
}
