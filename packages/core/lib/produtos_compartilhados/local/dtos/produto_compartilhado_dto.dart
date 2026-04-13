import 'package:core/isar_anotacoes.dart';

import '../../models/produto_compartilhado.dart';

part 'produto_compartilhado_dto.g.dart';

@Collection(ignore: {'props'})
class ProdutoCompartilhadoDto extends ProdutoCompartilhado
    with IsarDto<ProdutoCompartilhado> {
  @override
  Id get dataBaseId => fastHash(hash);

  @override
  @Index()
  // ignore: overridden_fields
  final String hashLista;

  ProdutoCompartilhado toModel() {
    return ProdutoCompartilhado(
        produtoId: produtoId,
        hashLista: hashLista,
        quantidade: quantidade,
        valorUnitario: valorUnitario,
        nome: nome,
        corNome: corNome,
        tamanhoNome: tamanhoNome,
        hash: hash);
  }

  factory ProdutoCompartilhadoDto.fromModel(ProdutoCompartilhado model) {
    return ProdutoCompartilhadoDto(
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

  const ProdutoCompartilhadoDto({
    required super.produtoId,
    required super.quantidade,
    required super.valorUnitario,
    required super.nome,
    required super.corNome,
    required super.tamanhoNome,
    required super.hash,
    required this.hashLista,
  }) : super(hashLista: hashLista);
}
