import 'package:financeiro/domain/data/repositories/i_historico_de_caixas_repository.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/domain/models/pagina_historico_de_caixas.dart';

class RecuperarHistoricoDeCaixas {
  final IHistoricoDeCaixasRepository _repository;

  RecuperarHistoricoDeCaixas({
    required IHistoricoDeCaixasRepository repository,
  }) : _repository = repository;

  Future<PaginaHistoricoDeCaixas> call({
    required FiltroHistoricoDeCaixas filtro,
  }) {
    return _repository.obterHistorico(filtro: filtro);
  }
}
