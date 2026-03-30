import 'package:core/isar_anotacoes.dart';
import 'package:estoque/estoque.dart';

part 'produto_estoque_dto.g.dart';

@Collection(ignore: {'produtoId', 'props', 'stringify'})
class ProdutoEstoqueDto implements ProdutoDoEstoque, IsarDto {
  @override
  final DateTime? atualizadoEm;

  @override
  final int corId;

  @override
  final String corNome;

  @override
  final int empresaId;

  @override
  final String nome;

  @override
  @ignore
  BigInt get produtoId => BigInt.from(idDoProduto);

  final int idDoProduto;

  @override
  final String? produtoIdExterno;

  @override
  List<Object?> get props => [
    empresaId,
    referenciaId,
    referenciaIdExterno,
    produtoId,
    produtoIdExterno,
    nome,
    corId,
    corNome,
    tamanhoId,
    tamanhoNome,
    unidadeMedida,
    saldo,
    atualizadoEm,
  ];

  @override
  final int referenciaId;

  @override
  final String? referenciaIdExterno;

  @override
  final double saldo;

  @override
  bool? get stringify => true;

  @override
  final int tamanhoId;

  @override
  final String tamanhoNome;

  @override
  final String? unidadeMedida;

  ProdutoEstoqueDto({
    required this.empresaId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.produtoIdExterno,
    required this.nome,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.unidadeMedida,
    required this.saldo,
    required this.idDoProduto,
    this.atualizadoEm,
  });

  @override
  Id get dataBaseId => idDoProduto;
}
