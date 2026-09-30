import 'package:financeiro/domain/models/despesa.dart';

/// Despesas que entram no relatório: fora as canceladas e os templates
/// recorrentes (que não são gasto, só geram as ocorrências).
List<Despesa> despesasDoRelatorio(
  List<Despesa> despesas, {
  required DateTime inicio,
  required DateTime fim,
  Set<int> categoriaIds = const {},
}) {
  final dia0 = DateTime(inicio.year, inicio.month, inicio.day);
  final dia1 = DateTime(fim.year, fim.month, fim.day);
  return despesas.where((d) {
    final data = d.dataPagamento;
    if (data == null || d.recorrente || d.status == StatusDespesa.cancelado) {
      return false;
    }
    final dia = DateTime(data.year, data.month, data.day);
    if (dia.isBefore(dia0) || dia.isAfter(dia1)) return false;
    return categoriaIds.isEmpty || categoriaIds.contains(d.categoriaId);
  }).toList()
    ..sort((a, b) => b.dataPagamento!.compareTo(a.dataPagamento!));
}

/// Total por dia, com os dias sem gasto zerados (o gráfico precisa de todos).
List<(DateTime, double)> totaisPorDia(
  List<Despesa> despesas, {
  required DateTime inicio,
  required DateTime fim,
}) {
  final porDia = <DateTime, double>{};
  for (final d in despesas) {
    final data = d.dataPagamento!;
    final dia = DateTime(data.year, data.month, data.day);
    porDia[dia] = (porDia[dia] ?? 0) + d.valor;
  }
  final resultado = <(DateTime, double)>[];
  var dia = DateTime(inicio.year, inicio.month, inicio.day);
  final ultimo = DateTime(fim.year, fim.month, fim.day);
  while (!dia.isAfter(ultimo)) {
    resultado.add((dia, porDia[dia] ?? 0));
    dia = DateTime(dia.year, dia.month, dia.day + 1);
  }
  return resultado;
}

/// Total por categoria, do maior pro menor.
List<(int, double)> totaisPorCategoria(List<Despesa> despesas) {
  final porCategoria = <int, double>{};
  for (final d in despesas) {
    porCategoria[d.categoriaId] = (porCategoria[d.categoriaId] ?? 0) + d.valor;
  }
  return porCategoria.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
}
