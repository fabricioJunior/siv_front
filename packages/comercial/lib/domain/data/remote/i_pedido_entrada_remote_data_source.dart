import 'package:comercial/domain/models/pedido_entrada.dart';

abstract class IPedidoEntradaRemoteDataSource {
  Future<EntradaResumo> importarNfe({
    required String filePath,
    required int tabelaPrecoId,
  });

  Future<EntradaResumo> criarPorContagem({
    required int pessoaId,
    required int tabelaPrecoId,
    String? observacao,
  });

  Future<EntradaResumo> obter(int pedidoId);

  Future<EntradaResumo> vincularReferencia(
    int pedidoId,
    int linhaId,
    int referenciaId,
  );

  Future<EntradaResumo> preCadastrar(
    int pedidoId,
    int linhaId, {
    required int categoriaId,
    String? nome,
  });

  Future<EntradaResumo> ignorar(int pedidoId, int linhaId, bool ignorar);

  Future<EntradaResumo> resolverDivergencia(
    int pedidoId,
    int linhaId,
    String? observacao,
  );

  Future<EntradaResumo> registrarContagem(
    int pedidoId,
    List<ItemContagem> itens,
  );

  Future<EntradaResumo> registrarContagemLivre(
    int pedidoId,
    List<ItemContagem> itens,
  );

  /// Informar [referenciaId] OU [categoriaId] (pré-cadastro com [nome]).
  Future<EntradaResumo> associarContagemLivre(
    int pedidoId,
    List<int> ids, {
    int? referenciaId,
    int? categoriaId,
    String? nome,
  });
}
