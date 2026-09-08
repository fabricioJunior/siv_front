import 'package:comercial/domain/data/remote/i_lista_personalizada_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

class ListaPersonalizadaRepository implements IListaPersonalizadaRepository {
  final IListaPersonalizadaRemoteDataSource remoteDataSource;

  ListaPersonalizadaRepository({required this.remoteDataSource});

  @override
  Future<ListaPersonalizada> criar({
    required int tabelaPrecoId,
    required DateTime dataExpiracao,
    List<int> referenciaIds = const [],
    String? titulo,
  }) =>
      remoteDataSource.criar(
        tabelaPrecoId: tabelaPrecoId,
        dataExpiracao: dataExpiracao,
        referenciaIds: referenciaIds,
        titulo: titulo,
      );

  @override
  Future<ListaPersonalizada> atualizarTitulo(int id, String? titulo) =>
      remoteDataSource.atualizarTitulo(id, titulo);

  @override
  Future<ListaPersonalizada> adicionarItens(int id, List<int> referenciaIds) =>
      remoteDataSource.adicionarItens(id, referenciaIds);

  @override
  Future<ListaPersonalizada> removerItens(int id, List<int> referenciaIds) =>
      remoteDataSource.removerItens(id, referenciaIds);

  @override
  Future<ListaPersonalizada> buscarPorId(int id) => remoteDataSource.buscarPorId(id);

  @override
  Future<String> buscarLink(int id) => remoteDataSource.buscarLink(id);

  @override
  Future<PaginaListasPersonalizadas> listar({int page = 1, int limit = 20}) =>
      remoteDataSource.listar(page: page, limit: limit);
}
