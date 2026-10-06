import 'package:estoque/domain/models/parametros_giro.dart';

enum ClassificacaoGiro {
  excepcional('excepcional', 'Excepcional'),
  rapido('rapido', 'Rápido'),
  normal('normal', 'Normal'),
  lento('lento', 'Lento'),
  parado('parado', 'Parado'),
  semHistorico('semHistorico', 'Sem histórico');

  final String api;
  final String label;
  const ClassificacaoGiro(this.api, this.label);

  static ClassificacaoGiro fromApi(String? v) => values.firstWhere(
        (c) => c.api == v,
        orElse: () => ClassificacaoGiro.semHistorico,
      );
}

enum AbaGiro { ranking, reposicao, parado }

enum PeriodoGiro {
  hoje('hoje', 'Hoje'),
  sete('7', '7 dias'),
  trinta('30', '30 dias'),
  noventa('90', '90 dias'),
  personalizado('personalizado', 'Personalizado');

  final String api;
  final String label;
  const PeriodoGiro(this.api, this.label);
}

/// Filtros comuns à lista, ao resumo e às variações.
class FiltroGiroEstoque {
  final PeriodoGiro periodo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String visualizacao; // produto | variacao
  final Set<ClassificacaoGiro> classificacoes;
  final String? busca;
  final List<int> categoriaIds;
  final List<int> fornecedorIds;
  final List<int> marcaIds;
  final List<int> tamanhoIds;
  final List<int> corIds;
  final double? precoMin;
  final double? precoMax;

  /// Nomes legíveis dos filtros de lista (ex: `Categoria` → `A, B`), só para
  /// o cabeçalho das exportações; não vão para a query.
  final Map<String, String> rotulos;

  const FiltroGiroEstoque({
    this.periodo = PeriodoGiro.trinta,
    this.dataInicio,
    this.dataFim,
    this.visualizacao = 'produto',
    this.classificacoes = const {},
    this.busca,
    this.categoriaIds = const [],
    this.fornecedorIds = const [],
    this.marcaIds = const [],
    this.tamanhoIds = const [],
    this.corIds = const [],
    this.precoMin,
    this.precoMax,
    this.rotulos = const {},
  });

  /// Intervalo de datas de entrada que o filtro cobre.
  (DateTime, DateTime) intervalo([DateTime? agora]) {
    final h = agora ?? DateTime.now();
    final hoje = DateTime(h.year, h.month, h.day);
    if (periodo == PeriodoGiro.personalizado &&
        dataInicio != null &&
        dataFim != null) {
      return (dataInicio!, dataFim!);
    }
    final dias = switch (periodo) {
      PeriodoGiro.sete => 7,
      PeriodoGiro.trinta => 30,
      PeriodoGiro.noventa => 90,
      _ => 0,
    };
    return (hoje.subtract(Duration(days: dias)), hoje);
  }

  /// Linhas descritivas dos filtros ativos (período fica fora).
  List<String> get descricao => [
        if (visualizacao == 'variacao') 'Visão: Variação',
        if (classificacoes.isNotEmpty)
          'Classificação: ${classificacoes.map((c) => c.label).join(', ')}',
        if (busca != null && busca!.isNotEmpty) 'Busca: $busca',
        for (final e in rotulos.entries) '${e.key}: ${e.value}',
        if (precoMin != null || precoMax != null)
          'Preço: ${precoMin ?? '—'} a ${precoMax ?? '—'}',
      ];

  /// Quantidade de filtros "de formulário" ativos (exclui período/visão/classificação).
  int get totalAtivos =>
      [
        categoriaIds,
        fornecedorIds,
        marcaIds,
        tamanhoIds,
        corIds,
      ].where((l) => l.isNotEmpty).length +
      (precoMin != null || precoMax != null ? 1 : 0);

  FiltroGiroEstoque copyWith({
    PeriodoGiro? periodo,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? visualizacao,
    Set<ClassificacaoGiro>? classificacoes,
    String? busca,
    bool limparBusca = false,
    List<int>? categoriaIds,
    List<int>? fornecedorIds,
    List<int>? marcaIds,
    List<int>? tamanhoIds,
    List<int>? corIds,
    double? precoMin,
    double? precoMax,
    bool limparPreco = false,
    Map<String, String>? rotulos,
  }) =>
      FiltroGiroEstoque(
        periodo: periodo ?? this.periodo,
        dataInicio: dataInicio ?? this.dataInicio,
        dataFim: dataFim ?? this.dataFim,
        visualizacao: visualizacao ?? this.visualizacao,
        classificacoes: classificacoes ?? this.classificacoes,
        busca: limparBusca ? null : busca ?? this.busca,
        categoriaIds: categoriaIds ?? this.categoriaIds,
        fornecedorIds: fornecedorIds ?? this.fornecedorIds,
        marcaIds: marcaIds ?? this.marcaIds,
        tamanhoIds: tamanhoIds ?? this.tamanhoIds,
        corIds: corIds ?? this.corIds,
        precoMin: limparPreco ? null : precoMin ?? this.precoMin,
        precoMax: limparPreco ? null : precoMax ?? this.precoMax,
        rotulos: rotulos ?? this.rotulos,
      );
}

class GiroEstoqueLinha {
  final int referenciaId;
  final int? produtoId;
  final String nome;
  final String ref;
  final String? sku;
  final String categoria;
  final String fornecedor;
  final String? variacaoLabel;
  final DateTime? dataEntrada;
  final int loteOrdem;
  final DateTime? loteAnteriorEsgotadoEm;
  final int? inicial;
  final int vendido;
  final int estoque;
  final double? pctVendido;
  final int? diasGiro;
  final int diasEmEstoque;
  final double? velocidade;
  final int? diasParaEsgotar;
  final ClassificacaoGiro classificacao;
  final double? score;
  final int? sugestaoReposicao;
  final bool semHistorico;
  final double precoVenda;
  final double? custo;
  final double valorVendido;
  final double? valorEstoque;
  final double potencial;
  final double? valorParado;
  final int? rank;
  final bool temVariacoes;

  const GiroEstoqueLinha({
    required this.referenciaId,
    this.produtoId,
    required this.nome,
    this.ref = '',
    this.sku,
    this.categoria = '',
    this.fornecedor = '',
    this.variacaoLabel,
    this.dataEntrada,
    this.loteOrdem = 1,
    this.loteAnteriorEsgotadoEm,
    this.inicial,
    this.vendido = 0,
    this.estoque = 0,
    this.pctVendido,
    this.diasGiro,
    this.diasEmEstoque = 0,
    this.velocidade,
    this.diasParaEsgotar,
    required this.classificacao,
    this.score,
    this.sugestaoReposicao,
    this.semHistorico = false,
    this.precoVenda = 0,
    this.custo,
    this.valorVendido = 0,
    this.valorEstoque,
    this.potencial = 0,
    this.valorParado,
    this.rank,
    this.temVariacoes = false,
  });

  /// Chave da linha na lista (em visão variação, o produto é único).
  int get chave => produtoId ?? referenciaId;
}

class GiroEstoqueMeta {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;
  const GiroEstoqueMeta({
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.itemsPerPage = 20,
  });
}

class PaginaGiroEstoque {
  final List<GiroEstoqueLinha> items;
  final GiroEstoqueMeta meta;
  const PaginaGiroEstoque({required this.items, required this.meta});
}

class GiroEstoqueTop {
  final int rank;
  final String nome;
  final double pctVendido;
  final int? diasGiro;
  final double? velocidade;
  final ClassificacaoGiro classificacao;
  const GiroEstoqueTop({
    required this.rank,
    required this.nome,
    required this.pctVendido,
    this.diasGiro,
    this.velocidade,
    required this.classificacao,
  });
}

class GiroEstoqueResumo {
  final int analisados;
  final int semHistorico;
  final Map<ClassificacaoGiro, int> contagens;
  final double? mediaDiasGiro;
  final double? mediaPctVendido;
  final double valorVendido;
  final double valorEstoque;
  final double potencial;
  final double valorImobilizadoLentoParado;
  final double pctImobilizado;
  final List<GiroEstoqueTop> top;
  final Map<AbaGiro, int> totaisAbas;
  final ParametrosGiro parametros;

  const GiroEstoqueResumo({
    this.analisados = 0,
    this.semHistorico = 0,
    this.contagens = const {},
    this.mediaDiasGiro,
    this.mediaPctVendido,
    this.valorVendido = 0,
    this.valorEstoque = 0,
    this.potencial = 0,
    this.valorImobilizadoLentoParado = 0,
    this.pctImobilizado = 0,
    this.top = const [],
    this.totaisAbas = const {},
    this.parametros = const ParametrosGiro(),
  });
}

class GiroVariacaoDestaque {
  final String variacaoLabel;
  final double pctVendido;
  final int? diasGiro;
  const GiroVariacaoDestaque({
    required this.variacaoLabel,
    required this.pctVendido,
    this.diasGiro,
  });
}

class GiroEstoqueVariacoes {
  final List<GiroEstoqueLinha> items;
  final GiroVariacaoDestaque? melhor;
  final GiroVariacaoDestaque? pior;
  const GiroEstoqueVariacoes({required this.items, this.melhor, this.pior});
}
