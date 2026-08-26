import 'package:core/data_sourcers.dart';
import 'package:core/local_data_sourcers/hive/hive_hash.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';

import 'dtos/produto_compartilhado_hive_dto.dart';
import '../models/produto_compartilhado.dart';

class ProdutosCompartilhadosHiveDataSource extends HiveLocalDataSourceBase<
    ProdutoCompartilhadoHiveDto,
    ProdutoCompartilhado> implements IProdutosCompartilhadosLocalDataSource {
  ProdutosCompartilhadosHiveDataSource({required super.getBox});

  @override
  Future<void> deletarPorHash(String hash) {
    return deleteById(hiveHash(hash));
  }

  @override
  Future<void> limpar() {
    return deleteAll();
  }

  @override
  Future<Iterable<ProdutoCompartilhado>> recuperarPorLista(String hashLista) {
    return fetchWhere((dto) => dto.hashLista == hashLista);
  }

  @override
  Future<void> removerPorLista(String hashLista) {
    return deleteWhere((dto) => dto.hashLista == hashLista);
  }

  @override
  Future<void> salvarProdutos(List<ProdutoCompartilhado> produtos) {
    return putAll(produtos);
  }

  @override
  ProdutoCompartilhadoHiveDto toDto(ProdutoCompartilhado entity) {
    return ProdutoCompartilhadoHiveDto.fromModel(entity);
  }

  @override
  Future<ProdutoCompartilhado?> recuperarProduto(String produtoHash) {
    return fetchById(hiveHash(produtoHash));
  }

  @override
  Future<void> salvarProduto(ProdutoCompartilhado produto) {
    return put(produto);
  }
}
