import 'dart:typed_data';

import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

abstract class IListaPersonalizadaRepository {
  Future<ListaPersonalizada> criar(ListaPersonalizadaInput input);

  Future<ListaPersonalizada> atualizar(int id, ListaPersonalizadaInput input);

  Future<ListaPersonalizada> atualizarTitulo(int id, String? titulo);

  Future<ListaPersonalizada> adicionarItens(int id, List<int> referenciaIds);

  Future<ListaItensLoteResultado> adicionarPorFiltro(int id, ListaItensLote lote);

  Future<ListaPersonalizada> removerItens(int id, List<int> referenciaIds);

  Future<ListaPersonalizada> buscarPorId(int id);

  Future<String> buscarLink(int id);

  Future<ListaPersonalizada> enviarIcone(int id, Uint8List bytes, String fileName);

  Future<ListaPrevia> previa(int id, {int page = 1, int limit = 20});

  Future<PaginaListasPersonalizadas> listar({
    int page = 1,
    int limit = 20,
    ListaTipo? tipo,
  });
}
