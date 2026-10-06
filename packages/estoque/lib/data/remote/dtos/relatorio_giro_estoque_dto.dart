import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse('$v');
double? _d(dynamic v) => (v as num?)?.toDouble();
int? _i(dynamic v) => (v as num?)?.toInt();

GiroEstoqueLinha giroLinhaFromJson(Map<String, dynamic> j) => GiroEstoqueLinha(
      referenciaId: _i(j['referenciaId']) ?? 0,
      produtoId: _i(j['produtoId']),
      nome: j['nome'] as String? ?? '',
      ref: j['ref'] as String? ?? '',
      sku: j['sku'] as String?,
      categoria: j['categoria'] as String? ?? '',
      fornecedor: j['fornecedor'] as String? ?? '',
      variacaoLabel: j['variacaoLabel'] as String?,
      dataEntrada: _data(j['dataEntrada']),
      loteOrdem: _i(j['loteOrdem']) ?? 1,
      loteAnteriorEsgotadoEm: _data(j['loteAnteriorEsgotadoEm']),
      inicial: _i(j['inicial']),
      vendido: _i(j['vendido']) ?? 0,
      estoque: _i(j['estoque']) ?? 0,
      pctVendido: _d(j['pctVendido']),
      diasGiro: _i(j['diasGiro']),
      diasEmEstoque: _i(j['diasEmEstoque']) ?? 0,
      velocidade: _d(j['velocidade']),
      diasParaEsgotar: _i(j['diasParaEsgotar']),
      classificacao: ClassificacaoGiro.fromApi(j['classificacao'] as String?),
      score: _d(j['score']),
      sugestaoReposicao: _i(j['sugestaoReposicao']),
      semHistorico: j['semHistorico'] as bool? ?? false,
      precoVenda: _d(j['precoVenda']) ?? 0,
      custo: _d(j['custo']),
      valorVendido: _d(j['valorVendido']) ?? 0,
      valorEstoque: _d(j['valorEstoque']),
      potencial: _d(j['potencial']) ?? 0,
      valorParado: _d(j['valorParado']),
      rank: _i(j['rank']),
      temVariacoes: j['temVariacoes'] as bool? ?? false,
    );

List<GiroEstoqueLinha> _linhas(dynamic v) => (v as List<dynamic>? ?? [])
    .map((e) => giroLinhaFromJson(e as Map<String, dynamic>))
    .toList();

PaginaGiroEstoque paginaGiroFromJson(Map<String, dynamic> j) {
  final m = j['meta'] as Map<String, dynamic>? ?? const {};
  return PaginaGiroEstoque(
    items: _linhas(j['items']),
    meta: GiroEstoqueMeta(
      totalItems: _i(m['totalItems']) ?? 0,
      totalPages: _i(m['totalPages']) ?? 1,
      currentPage: _i(m['currentPage']) ?? 1,
      itemsPerPage: _i(m['itemsPerPage']) ?? 20,
    ),
  );
}

GiroEstoqueResumo giroResumoFromJson(Map<String, dynamic> j) {
  final c = j['contagens'] as Map<String, dynamic>? ?? const {};
  final t = j['totaisAbas'] as Map<String, dynamic>? ?? const {};
  return GiroEstoqueResumo(
    analisados: _i(j['analisados']) ?? 0,
    semHistorico: _i(j['semHistorico']) ?? 0,
    contagens: {
      for (final k in ClassificacaoGiro.values)
        if (c[k.api] != null) k: _i(c[k.api])!,
    },
    mediaDiasGiro: _d(j['mediaDiasGiro']),
    mediaPctVendido: _d(j['mediaPctVendido']),
    valorVendido: _d(j['valorVendido']) ?? 0,
    valorEstoque: _d(j['valorEstoque']) ?? 0,
    potencial: _d(j['potencial']) ?? 0,
    valorImobilizadoLentoParado: _d(j['valorImobilizadoLentoParado']) ?? 0,
    pctImobilizado: _d(j['pctImobilizado']) ?? 0,
    top: (j['top'] as List<dynamic>? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return GiroEstoqueTop(
        rank: _i(m['rank']) ?? 0,
        nome: m['nome'] as String? ?? '',
        pctVendido: _d(m['pctVendido']) ?? 0,
        diasGiro: _i(m['diasGiro']),
        velocidade: _d(m['velocidade']),
        classificacao: ClassificacaoGiro.fromApi(m['classificacao'] as String?),
      );
    }).toList(),
    totaisAbas: {
      for (final a in AbaGiro.values) a: _i(t[a.name]) ?? 0,
    },
    parametros:
        ParametrosGiro.fromJson(j['parametros'] as Map<String, dynamic>?),
  );
}

GiroVariacaoDestaque? _destaque(dynamic v) {
  if (v is! Map<String, dynamic>) return null;
  return GiroVariacaoDestaque(
    variacaoLabel: v['variacaoLabel'] as String? ?? '',
    pctVendido: _d(v['pctVendido']) ?? 0,
    diasGiro: _i(v['diasGiro']),
  );
}

GiroEstoqueVariacoes giroVariacoesFromJson(Map<String, dynamic> j) =>
    GiroEstoqueVariacoes(
      items: _linhas(j['items']),
      melhor: _destaque(j['melhor']),
      pior: _destaque(j['pior']),
    );
