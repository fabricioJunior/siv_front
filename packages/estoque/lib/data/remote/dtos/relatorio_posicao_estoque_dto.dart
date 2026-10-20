import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';

double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

RelatorioPosicaoEstoque posicaoEstoqueFromJson(Map<String, dynamic> j) {
  final r = j['resumo'] as Map<String, dynamic>? ?? const {};
  return RelatorioPosicaoEstoque(
    dataReferencia: DateTime.tryParse('${j['dataReferencia']}'),
    baseValor: j['baseValor'] as String?,
    resumo: PosicaoEstoqueResumo(
      valorEstoque: _d(r['valorEstoque']),
      pecas: _i(r['pecas']),
      skusAtivos: _i(r['skusAtivos']),
      emRuptura: _i(r['emRuptura']),
    ),
    items: (j['items'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .map((e) => PosicaoEstoqueCategoria(
              categoriaId: (e['categoriaId'] as num?)?.toInt(),
              categoriaNome: e['categoriaNome'] as String? ?? 'Sem categoria',
              pecas: _i(e['pecas']),
              valor: _d(e['valor']),
              percentual: _d(e['percentual']),
              emRuptura: _i(e['emRuptura']),
            ))
        .toList(),
  );
}
