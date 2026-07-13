import 'package:autenticacao/domain/models/permissao.dart';

/// Agrupa componentes de permissão por FLUXO DE NEGÓCIO (não pelo módulo
/// do backend, que é só o prefixo de 3 letras do código -- ex: PRD, ROM,
/// FCX). Construído a partir de como as telas do app realmente usam cada
/// código (ver lib/routes.dart, mapa `_componentesDaRota`), preenchendo os
/// códigos que não aparecem lá com o fluxo mais próximo pela descrição do
/// componente.
///
/// Um código pode aparecer em mais de um fluxo quando é usado por mais de
/// uma tela -- ex: ROMFP001 ("Lançamento de romaneios") é exigido tanto
/// por Vendas quanto por Romaneios e por Gerência de estoque. Isso reflete
/// a granularidade real das permissões no backend, mais grossa que as
/// telas do app.
const Map<String, List<String>> componentesPorFluxo = {
  'Vendas': ['PEDFC001', 'ROMFP001', 'ROMFP002', 'ROMFP003'],
  'Romaneios': ['ROMFP001', 'ROMFP002', 'ROMFP003'],
  'Caixa': [
    'FCXFM001',
    'FCXFP008',
    'FCXFP006',
    'FCXFP001',
    'FCXFP009',
    'FCXFP002',
    'FCXFP003',
    'FCXFP004',
    'FCXFM003',
    'FCXFP005',
    'FCXFL001',
    'FCXFM004',
    'FCXFP007',
    'FCXFM002',
  ],
  'Consignações': [
    'CONFC001',
    'CONFC002',
    'CONFC003',
    'CONFP001',
    'CONFP002',
    'CONFP003',
    'CONFP004',
    'CONFP005',
  ],
  'Fiscal': ['FISFM001'],
  'Relatórios': ['RELFC001', 'RELFC002', 'RELFC003', 'RELFC004'],
  'Pedidos': [
    'PEDFC001',
    'PEDFC002',
    'PEDFC003',
    'PEDFM001',
    'PEDFM002',
    'PEDFM003',
    'PEDFM004',
    'PEDFM005',
    'PEDFM006',
    'PEDFM007',
    'PEDFM008',
  ],
  'Estoque': ['PRDFL001'],
  'Balanço de estoque': [
    'PRDFL001',
    'BALFP001',
    'BALFP002',
    'BALFP003',
    'BALFP004',
  ],
  'Pessoas': [
    'PESFM001',
    'PESFM002',
    'PESFM003',
    'PESFC001',
    'PESFC002',
    'PESFC003',
    'PESFL001',
  ],
  'Produtos': [
    'PRDFM001',
    'PRDFM002',
    'PRDFM003',
    'PRDFM004',
    'PRDFM005',
    'PRDFM006',
    'PRDFM007',
    'PRDFM008',
    'PRDFM009',
  ],
  'Etiquetas': ['PRDFM003', 'PRDFM012'],
  'Financeiro': ['GERFM001', 'FCXFP001', 'PRDFM010', 'PAGFM001'],
  'Formas de pagamento': ['GERFM001', 'ADMFM008'],
  'Tabelas de preço': ['PRDFM010', 'PRDFM011'],
  'Pagamentos avulsos': ['PAGFM001', 'PAGFP005', 'PAGFP006'],
  'Administração': [
    'ADMFL001',
    'ADMFM001',
    'ADMFM002',
    'ADMFM003',
    'ADMFM004',
    'ADMFM005',
    'ADMFM006',
    'ADMFM007',
    'ADMFM008',
    'ADMFM009',
    'ADMFP005',
    'ADMFP006',
    'SYSFM001',
  ],
  'Funcionários': ['FUNFM001'],
  'E-commerce': ['ECOFM001', 'ECOFM002'],
  'Contas a receber': ['FCRFM001', 'FCRFM002'],
  'Importações': [
    'IMPFP001',
    'IMPFP002',
    'IMPFP003',
    'IMPFP004',
    'IMPFP005',
    'IMPFP006',
  ],
};

/// Ordem de exibição dos fluxos nas telas de permissão. "Outros" fica
/// sempre por último -- é o fallback pra componentes novos que ainda não
/// foram classificados em [componentesPorFluxo].
const List<String> ordemFluxos = [
  'Vendas',
  'Romaneios',
  'Caixa',
  'Consignações',
  'Pedidos',
  'Estoque',
  'Balanço de estoque',
  'Produtos',
  'Etiquetas',
  'Tabelas de preço',
  'Formas de pagamento',
  'Financeiro',
  'Pagamentos avulsos',
  'Contas a receber',
  'Fiscal',
  'Relatórios',
  'Pessoas',
  'Funcionários',
  'E-commerce',
  'Administração',
  'Outros',
];

/// Agrupa [permissoes] pelos fluxos de negócio que as usam, na ordem
/// definida em [ordemFluxos] (fluxos sem nenhuma permissão em [permissoes]
/// não aparecem no resultado). Uma permissão usada por mais de um fluxo
/// aparece repetida em cada grupo correspondente -- reflete a realidade de
/// que um único código pode gatear mais de uma tela. Códigos sem fluxo
/// mapeado caem em "Outros".
Map<String, List<Permissao>> agruparPermissoesPorFluxo(
  List<Permissao> permissoes,
) {
  final grupos = <String, List<Permissao>>{};

  for (final fluxo in ordemFluxos) {
    if (fluxo == 'Outros') continue;
    final codigos = componentesPorFluxo[fluxo] ?? const [];
    final itens = permissoes.where((p) => codigos.contains(p.id)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (itens.isNotEmpty) {
      grupos[fluxo] = itens;
    }
  }

  final codificados = componentesPorFluxo.values.expand((c) => c).toSet();
  final orfaos = permissoes.where((p) => !codificados.contains(p.id)).toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  if (orfaos.isNotEmpty) {
    grupos['Outros'] = orfaos;
  }

  return grupos;
}

/// Templates de cargo pra começar um grupo de acesso novo já com um
/// conjunto de permissões coerente, em vez de montar item por item.
/// Definidos como combinação de fluxos (reaproveita [componentesPorFluxo])
/// -- mais fácil de manter que listar código por código de novo.
const Map<String, List<String>> _fluxosPorCargo = {
  'Vendedor': ['Vendas', 'Estoque', 'Pessoas'],
  'Caixa': ['Vendas', 'Caixa', 'Estoque', 'Pessoas'],
  'Gerente': [
    'Vendas',
    'Romaneios',
    'Caixa',
    'Consignações',
    'Pedidos',
    'Estoque',
    'Balanço de estoque',
    'Produtos',
    'Etiquetas',
    'Tabelas de preço',
    'Formas de pagamento',
    'Financeiro',
    'Pagamentos avulsos',
    'Contas a receber',
    'Relatórios',
    'Pessoas',
    'Funcionários',
  ],
};

/// Nomes dos cargos predefinidos, na ordem de exibição.
const List<String> cargosPredefinidos = ['Vendedor', 'Caixa', 'Gerente'];

/// Códigos de componente que compõem o [cargo] (um dos [cargosPredefinidos]).
/// Lista vazia se o nome não corresponder a nenhum template conhecido.
List<String> componentesDoCargo(String cargo) {
  final fluxos = _fluxosPorCargo[cargo] ?? const [];
  final codigos = <String>{};
  for (final fluxo in fluxos) {
    codigos.addAll(componentesPorFluxo[fluxo] ?? const []);
  }
  return codigos.toList();
}
