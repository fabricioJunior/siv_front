import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

abstract class IListaPersonalizadaRemoteDataSource {
  Future<ListaPersonalizada> criar({
    required int tabelaPrecoId,
    required DateTime dataExpiracao,
    List<int> referenciaIds,
    String? titulo,
  });

  Future<ListaPersonalizada> atualizarTitulo(int id, String? titulo);

  Future<ListaPersonalizada> adicionarItens(int id, List<int> referenciaIds);

  Future<ListaPersonalizada> removerItens(int id, List<int> referenciaIds);

  Future<ListaPersonalizada> buscarPorId(int id);

  Future<String> buscarLink(int id);

  Future<PaginaListasPersonalizadas> listar({int page = 1, int limit = 20});
}
