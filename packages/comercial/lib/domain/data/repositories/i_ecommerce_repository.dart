import 'package:comercial/models.dart';

abstract class IEcommerceRepository {
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false});
  Future<Ecommerce> recuperarEcommerce(int id);
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce);
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce);
  Future<void> excluirEcommerce(int id);
  Future<void> restaurarEcommerce(int id);

  Future<EcommerceReferenciasPagina> recuperarReferencias(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  });
  Future<EcommerceReferencia> adicionarReferencia(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  });
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  });

  /// Usa `PATCH .../referencias/lote` quando existir; se o backend responder
  /// 404/405, cai no laço de PATCH individual em série chamando [onProgresso]
  /// a cada item.
  Future<EcommerceLoteResultado> publicarReferenciasEmLote(
    int ecommerceId, {
    required List<int> ids,
    required bool rascunho,
    void Function(int atual, int total)? onProgresso,
  });

  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  );
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  });

  /// Mesmo esquema de fallback de [publicarReferenciasEmLote], para
  /// `PUT .../produtos/lote`.
  Future<void> atualizarDisponibilidadeProdutosEmLote(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
    void Function(int atual, int total)? onProgresso,
  });
}
