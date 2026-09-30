import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/utils/resumo_de_despesas.dart';
import 'package:flutter_test/flutter_test.dart';

Despesa _d(double valor, int cat, DateTime data,
        {StatusDespesa status = StatusDespesa.pago, bool recorrente = false}) =>
    Despesa(
      descricao: 'x',
      valor: valor,
      categoriaId: cat,
      origemPagamentoId: 1,
      dataPagamento: data,
      status: status,
      recorrente: recorrente,
    );

void main() {
  final inicio = DateTime(2026, 9, 1);
  final fim = DateTime(2026, 9, 3);
  final lista = [
    _d(10, 1, DateTime(2026, 9, 1)),
    _d(20, 2, DateTime(2026, 9, 3, 15)),
    _d(5, 1, DateTime(2026, 9, 3)),
    _d(99, 1, DateTime(2026, 9, 2), status: StatusDespesa.cancelado),
    _d(99, 1, DateTime(2026, 9, 2), recorrente: true),
    _d(99, 1, DateTime(2026, 10, 1)),
  ];

  test('filtra período (dia inclusivo), cancelada e template', () {
    final r = despesasDoRelatorio(lista, inicio: inicio, fim: fim);
    expect(r.map((d) => d.valor), [20, 5, 10]);
  });

  test('filtra por categorias; vazio = todas', () {
    expect(despesasDoRelatorio(lista, inicio: inicio, fim: fim, categoriaIds: {2}).length, 1);
  });

  test('totais por dia zeram dias vazios e por categoria ordenam desc', () {
    final r = despesasDoRelatorio(lista, inicio: inicio, fim: fim);
    expect(totaisPorDia(r, inicio: inicio, fim: fim).map((e) => e.$2), [10, 0, 25]);
    expect(totaisPorCategoria(r), [(2, 20.0), (1, 15.0)]);
  });
}
