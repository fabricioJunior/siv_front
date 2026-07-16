import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/domain/models/pagina_historico_de_caixas.dart';

abstract class IHistoricoDeCaixasRemoteDataSource {
  Future<PaginaHistoricoDeCaixas> obterHistorico({
    required FiltroHistoricoDeCaixas filtro,
  });
}
