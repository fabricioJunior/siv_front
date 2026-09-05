import 'package:comercial/data.dart';
import 'package:comercial/domain/data/remote/i_ecommerce_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:flutter_test/flutter_test.dart';

class _DataSourceSemEndpointDeLote implements IEcommerceRemoteDataSource {
  final List<int> patchesIndividuais = [];

  @override
  Future<EcommerceLoteResultado> publicarReferenciasEmLote(
    int ecommerceId, {
    required List<int> ids,
    required bool rascunho,
  }) async {
    throw HttpException('Não encontrado', statusCode: 404);
  }

  @override
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  }) async {
    patchesIndividuais.add(id);
    if (id == 91) throw HttpException('Falhou', statusCode: 500);
    return EcommerceReferencia.create(
      ecommerceId: ecommerceId,
      referenciaId: id,
      rascunho: rascunho ?? true,
    );
  }

  @override
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false}) =>
      throw UnimplementedError();
  @override
  Future<Ecommerce> recuperarEcommerce(int id) => throw UnimplementedError();
  @override
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce) =>
      throw UnimplementedError();
  @override
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce) =>
      throw UnimplementedError();
  @override
  Future<void> excluirEcommerce(int id) => throw UnimplementedError();
  @override
  Future<void> restaurarEcommerce(int id) => throw UnimplementedError();
  @override
  Future<EcommerceReferenciasPagina> recuperarReferencias(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  }) =>
      throw UnimplementedError();
  @override
  Future<EcommerceReferencia> adicionarReferencia(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  }) =>
      throw UnimplementedError();
  @override
  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  ) =>
      throw UnimplementedError();
  @override
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> atualizarDisponibilidadeProdutosEmLote(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
  }) =>
      throw UnimplementedError();
}

void main() {
  test(
    'publicarReferenciasEmLote cai no laço individual quando endpoint responde 404',
    () async {
      final dataSource = _DataSourceSemEndpointDeLote();
      final repository = EcommerceRepository(remoteDataSource: dataSource);

      final progresso = <int>[];
      final resultado = await repository.publicarReferenciasEmLote(
        1,
        ids: [12, 44, 91],
        rascunho: false,
        onProgresso: (atual, total) => progresso.add(atual),
      );

      expect(dataSource.patchesIndividuais, [12, 44, 91]);
      expect(resultado.atualizados, 2);
      expect(resultado.falharam.map((f) => f.id), [91]);
      expect(progresso, [1, 2, 3]);
    },
  );
}
