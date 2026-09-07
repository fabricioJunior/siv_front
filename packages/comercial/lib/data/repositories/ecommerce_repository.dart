import 'package:comercial/domain/data/remote/i_ecommerce_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart' show HttpException;

class EcommerceRepository implements IEcommerceRepository {
  final IEcommerceRemoteDataSource remoteDataSource;

  EcommerceRepository({required this.remoteDataSource});

  @override
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false}) {
    return remoteDataSource.recuperarEcommerces(
      incluirApagados: incluirApagados,
    );
  }

  @override
  Future<Ecommerce> recuperarEcommerce(int id) {
    return remoteDataSource.recuperarEcommerce(id);
  }

  @override
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce) {
    return remoteDataSource.criarEcommerce(ecommerce);
  }

  @override
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce) {
    return remoteDataSource.atualizarEcommerce(ecommerce);
  }

  @override
  Future<void> excluirEcommerce(int id) {
    return remoteDataSource.excluirEcommerce(id);
  }

  @override
  Future<void> restaurarEcommerce(int id) {
    return remoteDataSource.restaurarEcommerce(id);
  }

  @override
  Future<EcommerceReferenciasPagina> recuperarReferencias(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  }) {
    return remoteDataSource.recuperarReferencias(
      ecommerceId,
      busca: busca,
      categoriaIds: categoriaIds,
      rascunho: rascunho,
      publicavel: publicavel,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<EcommerceLoteResultado> publicarReferenciasEmLote(
    int ecommerceId, {
    required List<int> ids,
    required bool rascunho,
    void Function(int atual, int total)? onProgresso,
  }) async {
    try {
      return await remoteDataSource.publicarReferenciasEmLote(
        ecommerceId,
        ids: ids,
        rascunho: rascunho,
      );
    } on HttpException catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
    }

    // ponytail: sem endpoint de lote, cai no laço sequencial de sempre --
    // um PATCH por vez pra não trombar no rate limiter da API.
    var atualizados = 0;
    final falharam = <EcommerceLoteFalha>[];
    for (var i = 0; i < ids.length; i++) {
      onProgresso?.call(i + 1, ids.length);
      try {
        await remoteDataSource.atualizarReferencia(
          ecommerceId,
          ids[i],
          rascunho: rascunho,
        );
        atualizados++;
      } catch (_) {
        falharam.add(EcommerceLoteFalha(id: ids[i]));
      }
    }
    return EcommerceLoteResultado(atualizados: atualizados, falharam: falharam);
  }

  @override
  Future<EcommerceReferencia> adicionarReferencia(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  }) {
    return remoteDataSource.adicionarReferencia(
      ecommerceId,
      referenciaId: referenciaId,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }

  @override
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  }) {
    return remoteDataSource.atualizarReferencia(
      ecommerceId,
      id,
      rascunho: rascunho,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }

  @override
  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  ) {
    return remoteDataSource.recuperarProdutosDaReferencia(
      ecommerceId,
      referenciaId,
    );
  }

  @override
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  }) {
    return remoteDataSource.atualizarDisponibilidadeProduto(
      ecommerceId,
      referenciaId,
      produtoId,
      disponivel: disponivel,
    );
  }

  @override
  Future<void> atualizarDisponibilidadeProdutosEmLote(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
    void Function(int atual, int total)? onProgresso,
  }) async {
    try {
      await remoteDataSource.atualizarDisponibilidadeProdutosEmLote(
        ecommerceId,
        referenciaId,
        produtoIds: produtoIds,
        disponivel: disponivel,
      );
      return;
    } on HttpException catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
    }

    for (var i = 0; i < produtoIds.length; i++) {
      onProgresso?.call(i + 1, produtoIds.length);
      await remoteDataSource.atualizarDisponibilidadeProduto(
        ecommerceId,
        referenciaId,
        produtoIds[i],
        disponivel: disponivel,
      );
    }
  }
}
