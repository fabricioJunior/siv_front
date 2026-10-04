import 'package:comercial/domain/models/pedido_entrada.dart';

abstract class IPedidoEntradaRemoteDataSource {
  Future<EntradaResumo> importarNfe({
    required String filePath,
    required int tabelaPrecoId,
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
}
