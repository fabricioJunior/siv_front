import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';

class GetRelatorioFrequenciaClientes {
  final IRelatorioRepository _repository;
  GetRelatorioFrequenciaClientes(this._repository);

  Future<RelatorioFrequenciaClientes> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<int>? funcionarioIds,
    List<int>? categoriaIds,
    String? classe,
    bool atrasados = false,
    String? busca,
    String ordenarPor = 'rank',
    String ordem = 'asc',
    int page = 1,
    int limit = 20,
  }) =>
      _repository.frequenciaClientes(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        funcionarioIds: funcionarioIds,
        categoriaIds: categoriaIds,
        classe: classe,
        atrasados: atrasados,
        busca: busca,
        ordenarPor: ordenarPor,
        ordem: ordem,
        page: page,
        limit: limit,
      );
}
