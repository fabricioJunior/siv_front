import 'package:core/hive_anotacoes.dart';

import '../../models/produto_compartilhado.dart';

class ProdutoCompartilhadoHiveDto extends ProdutoCompartilhado
    with HiveDto<ProdutoCompartilhado>, StorageEntity {
  ProdutoCompartilhadoHiveDto({
    required super.produtoId,
    required super.hashLista,
    required super.quantidade,
    required super.valorUnitario,
    required super.nome,
    required super.corNome,
    required super.tamanhoNome,
    required super.hash,
  });

  @override
  int get dataBaseId => hiveHash(hash);

  @override
  Map<String, dynamic> get storageProperties => {
    'produtoId': produtoId,
    'hashLista': hashLista,
    'quantidade': quantidade,
    'valorUnitario': valorUnitario,
    'nome': nome,
    'corNome': corNome,
    'tamanhoNome': tamanhoNome,
    'hash': hash,
  };

  static ProdutoCompartilhadoHiveDto fromStorage(Map<String, dynamic> props) {
    return ProdutoCompartilhadoHiveDto(
      produtoId: props['produtoId'] as int,
      hashLista: props['hashLista'] as String,
      quantidade: props['quantidade'] as int,
      valorUnitario: props['valorUnitario'] as double,
      nome: props['nome'] as String,
      corNome: props['corNome'] as String,
      tamanhoNome: props['tamanhoNome'] as String,
      hash: props['hash'] as String,
    );
  }

  ProdutoCompartilhado toModel() {
    return ProdutoCompartilhado(
      produtoId: produtoId,
      hashLista: hashLista,
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      nome: nome,
      corNome: corNome,
      tamanhoNome: tamanhoNome,
      hash: hash,
    );
  }

  factory ProdutoCompartilhadoHiveDto.fromModel(ProdutoCompartilhado model) {
    return ProdutoCompartilhadoHiveDto(
      produtoId: model.produtoId,
      hashLista: model.hashLista,
      quantidade: model.quantidade,
      valorUnitario: model.valorUnitario,
      nome: model.nome,
      corNome: model.corNome,
      tamanhoNome: model.tamanhoNome,
      hash: model.hash,
    );
  }
}
