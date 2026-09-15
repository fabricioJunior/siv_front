/// Schema versionado dos object stores/índices do IndexedDB usado no web.
///
/// IndexedDB exige declarar stores e índices antecipadamente em
/// `onUpgradeNeeded` (diferente de Hive, que abre boxes sob demanda) --
/// este arquivo é o único lugar que lista todos os stores da app.
/// Adicionar um store/índice novo = adicionar uma entrada aqui e, só se for
/// mudar/remover algo em um store que já existia numa versão publicada,
/// subir [indexedDbSchemaVersion].
class IndexedDbStoreSpec {
  const IndexedDbStoreSpec({required this.storeName, this.indexes = const []});

  final String storeName;
  final List<String> indexes;
}

const indexedDbSchemaVersion = 1;

const indexedDbStores = <IndexedDbStoreSpec>[
  // core
  IndexedDbStoreSpec(storeName: 'core_ProdutoCompartilhadoHiveDto'),
  IndexedDbStoreSpec(storeName: 'core_ListaDeProdutosCompartilhadaHiveDto'),
  IndexedDbStoreSpec(storeName: 'core_PaginacaoHiveDto'),
  // precos
  IndexedDbStoreSpec(storeName: 'precos_TabelaDePrecoHiveDto'),
  IndexedDbStoreSpec(
    storeName: 'precos_PrecoDaReferenciaHiveDto',
    indexes: ['tabelaDePrecoId'],
  ),
  // produtos
  IndexedDbStoreSpec(
    storeName: 'produtos_CodigoHiveDto',
    indexes: ['produtoId'],
  ),
  // estoque
  IndexedDbStoreSpec(
    // 'idDoProduto', não 'produtoId': é o nome do campo em
    // `ProdutoEstoqueHiveDto.storageProperties` (o domínio expõe `produtoId`
    // como BigInt derivado de `idDoProduto`, mas quem fica gravado no
    // object store é o campo bruto do DTO).
    storeName: 'estoque_ProdutoEstoqueHiveDto',
    indexes: ['empresaId', 'referenciaId', 'idDoProduto'],
  ),
  // autenticacao
  IndexedDbStoreSpec(storeName: 'autenticacao_PermissaoDoUsuarioHiveDto'),
  IndexedDbStoreSpec(storeName: 'autenticacao_TokenHiveDto'),
  IndexedDbStoreSpec(storeName: 'autenticacao_CredenciaisHiveDto'),
  // sessão (app root)
  IndexedDbStoreSpec(storeName: 'common_data_EmpresaHiveDto'),
  IndexedDbStoreSpec(storeName: 'common_data_UsuarioHiveDto'),
  IndexedDbStoreSpec(storeName: 'common_data_LicenciadoHiveDto'),
  IndexedDbStoreSpec(storeName: 'common_data_TerminalDaSessaoHiveDto'),
  IndexedDbStoreSpec(storeName: 'common_data_RelatoriosMenuPrefsHiveDto'),
];
