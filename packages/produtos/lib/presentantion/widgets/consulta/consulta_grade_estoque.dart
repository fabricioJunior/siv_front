import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

/// Grade de estoque: linhas "cor · estampa", colunas tamanho. Destaca as células que
/// batem com o filtro e, com mais força, a variação lida pelo código de barras.
class ConsultaGradeEstoque extends StatelessWidget {
  final List<ProdutoDaGrade> produtos;
  final Set<int> corIds;
  final Set<int> tamanhoIds;
  final Set<int> estampaIds;
  final int? produtoIdLido;

  const ConsultaGradeEstoque({
    super.key,
    required this.produtos,
    this.corIds = const {},
    this.tamanhoIds = const {},
    this.estampaIds = const {},
    this.produtoIdLido,
  });

  bool get _filtrando => corIds.isNotEmpty || tamanhoIds.isNotEmpty || estampaIds.isNotEmpty;

  bool _bate(ProdutoDaGrade p) =>
      _filtrando &&
      (corIds.isEmpty || corIds.contains(p.corId)) &&
      (tamanhoIds.isEmpty || tamanhoIds.contains(p.tamanhoId)) &&
      (estampaIds.isEmpty || estampaIds.contains(p.estampaId));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String linha(ProdutoDaGrade p) => '${p.corNome} · ${p.estampaNome ?? 'Liso'}';
    final linhas = <String>[];
    final tamanhos = <String>[];
    final celulas = <String, Map<String, ProdutoDaGrade>>{};
    for (final p in produtos) {
      final l = linha(p);
      final t = p.tamanhoNome.trim().isEmpty ? '-' : p.tamanhoNome.trim();
      if (!linhas.contains(l)) linhas.add(l);
      if (!tamanhos.contains(t)) tamanhos.add(t);
      celulas.putIfAbsent(l, () => {})[t] = p;
    }

    Widget celula(ProdutoDaGrade? p) {
      if (p == null) {
        return const Padding(padding: EdgeInsets.all(8), child: Center(child: Text('–')));
      }
      final lido = p.produtoId == produtoIdLido;
      final destaque = _bate(p);
      return Container(
        key: ValueKey('celula-${p.produtoId}'),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lido
              ? cs.primary
              : destaque
              ? cs.primaryContainer
              : null,
        ),
        child: Center(
          child: Text(
            '${p.saldo}',
            style: TextStyle(
              fontWeight: lido || destaque ? FontWeight.bold : null,
              color: lido
                  ? cs.onPrimary
                  : destaque
                  ? cs.onPrimaryContainer
                  : null,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: cs.outlineVariant, width: 0.8),
        children: [
          TableRow(
            decoration: BoxDecoration(color: cs.surfaceContainerHighest),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Cor · Estampa', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              for (final t in tamanhos)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600))),
                ),
            ],
          ),
          for (final l in linhas)
            TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8), child: Text(l)),
                for (final t in tamanhos) celula(celulas[l]?[t]),
              ],
            ),
        ],
      ),
    );
  }
}
