import 'package:core/data_sourcers.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';

import 'dtos/produto_compartilhado_dto.dart';
import '../models/produto_compartilhado.dart';

class ProdutosCompartilhadosLocalDataSource extends IsarLocalDataSourceBase<
    ProdutoCompartilhadoDto,
    ProdutoCompartilhado> implements IProdutosCompartilhadosLocalDataSource {
  ProdutosCompartilhadosLocalDataSource({required super.getIsar});

  @override
  Future<void> deletarPorHash(String hash) {
    return deleteById(fastHash(hash));
  }

  @override
  Future<void> limpar() {
    return deleteAll();
  }

  @override
  Future<Iterable<ProdutoCompartilhado>> recuperarPorLista(String hashLista) {
    return fetchWhere(FindProdutoCompartilhado(hashLista: hashLista));
  }

  @override
  Future<void> removerPorLista(String hashLista) {
    return deleteWhere(FindProdutoCompartilhado(hashLista: hashLista));
  }

  @override
  Future<void> salvarProdutos(List<ProdutoCompartilhado> produtos) {
    return putAll(produtos);
  }

  @override
  ProdutoCompartilhadoDto toDto(ProdutoCompartilhado entity) {
    return ProdutoCompartilhadoDto.fromModel(entity);
  }

  @override
  Future<ProdutoCompartilhado?> recuperarProduto(String produtoHash) {
    return fetchById(fastHash(produtoHash));
  }

  @override
  Future<void> salvarProduto(ProdutoCompartilhado produto) {
    return put(produto);
  }
}

class FindProdutoCompartilhado extends IsarFind<ProdutoCompartilhadoDto> {
  final String? hashLista;

  FindProdutoCompartilhado({this.hashLista});
  @override
  Future<Iterable<ProdutoCompartilhadoDto>> call(
      IsarCollection<ProdutoCompartilhadoDto> t) async {
    return t
        .filter()
        .optional(
          hashLista != null,
          (q) => q.hashListaEqualTo(hashLista!),
        )
        .findAll();
  }
}
