import 'package:comercial/domain/data/remote/i_ecommerce_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class EcommerceRepository implements IEcommerceRepository {
  final IEcommerceRemoteDataSource remoteDataSource;

  EcommerceRepository({required this.remoteDataSource});

  @override
  Future<List<Ecommerce>> recuperarEcommerces() {
    return remoteDataSource.recuperarEcommerces();
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
  Future<List<EcommerceReferencia>> recuperarReferencias(int ecommerceId) {
    return remoteDataSource.recuperarReferencias(ecommerceId);
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
}
