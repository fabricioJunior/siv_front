import 'package:core/hive_anotacoes.dart';
import 'package:estoque/estoque.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class ProdutoEstoqueHiveDto implements ProdutoDoEstoque, HiveDto, StorageEntity {
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
  BigInt get produtoId => BigInt.from(idDoProduto);

  final int idDoProduto;

  @override
  final String? produtoIdExterno;

  // Sempre false: itens apagados nunca são upsertados localmente (o
  // repositório de sync os apaga em vez de salvar, ver EstoqueRepository.syncEstoque).
  @override
  bool get produtoApagado => false;

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

  ProdutoEstoqueHiveDto({
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
  int get dataBaseId => idDoProduto;

  @override
  Map<String, dynamic> get storageProperties => {
    'idDoProduto': idDoProduto,
    'produtoIdExterno': produtoIdExterno,
    'nome': nome,
    'corId': corId,
    'corNome': corNome,
    'empresaId': empresaId,
    'referenciaId': referenciaId,
    'referenciaIdExterno': referenciaIdExterno,
    'saldo': saldo,
    'tamanhoId': tamanhoId,
    'tamanhoNome': tamanhoNome,
    'unidadeMedida': unidadeMedida,
    'atualizadoEm': atualizadoEm,
  };

  static ProdutoEstoqueHiveDto fromStorage(Map<String, dynamic> props) {
    return ProdutoEstoqueHiveDto(
      idDoProduto: props['idDoProduto'] as int,
      produtoIdExterno: props['produtoIdExterno'] as String?,
      nome: props['nome'] as String,
      corId: props['corId'] as int,
      corNome: props['corNome'] as String,
      empresaId: props['empresaId'] as int,
      referenciaId: props['referenciaId'] as int,
      referenciaIdExterno: props['referenciaIdExterno'] as String?,
      saldo: props['saldo'] as double,
      tamanhoId: props['tamanhoId'] as int,
      tamanhoNome: props['tamanhoNome'] as String,
      unidadeMedida: props['unidadeMedida'] as String?,
      atualizadoEm: props['atualizadoEm'] as DateTime?,
    );
  }
}
