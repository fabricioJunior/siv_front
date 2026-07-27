import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioComprasClientes {
  final IRelatorioRepository _repository;
  GetRelatorioComprasClientes(this._repository);

  Future<RelatorioComprasClientes> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String agruparPor = 'produto',
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.comprasClientes(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        agruparPor: agruparPor,
        produtoIds: produtoIds,
        referenciaIds: referenciaIds,
        categoriaIds: categoriaIds,
        corIds: corIds,
        tamanhoIds: tamanhoIds,
        page: page,
        limit: limit,
      );
}
