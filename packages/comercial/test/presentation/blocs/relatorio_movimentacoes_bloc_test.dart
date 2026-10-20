import 'package:comercial/domain/models/relatorio_movimentacoes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_movimentacoes.dart';
import 'package:comercial/presentation/blocs/relatorio_movimentacoes_bloc/relatorio_movimentacoes_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fake implements GetRelatorioMovimentacoes {
  final chamadas = <Map<String, Object?>>[];

  @override
  Future<RelatorioMovimentacoes> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<String>? tipos,
    String? busca,
    int page = 1,
    int limit = 50,
  }) async {
    chamadas.add({'ini': dataInicial, 'fim': dataFinal, 'tipos': tipos, 'page': page});
    return RelatorioMovimentacoes(
      items: [MovimentacaoItem(id: '$page', tipo: 'venda')],
      meta: const MovimentacoesMeta(totalPages: 2),
      contagemPorTipo: const {'venda': 3},
    );
  }
}

void main() {
  late _Fake uc;
  late RelatorioMovimentacoesBloc bloc;

  setUp(() {
    uc = _Fake();
    bloc = RelatorioMovimentacoesBloc(uc,
        empresaId: () => 1, hoje: DateTime(2026, 10, 18));
  });
  tearDown(() => bloc.close());

  Future<RelatorioMovimentacoesState> aguarda() => bloc.stream.firstWhere(
      (s) => s.step != RelatorioMovimentacoesStep.carregando);

  test('carga: últimos 30 dias, contagem e mais páginas', () async {
    bloc.add(RelatorioMovimentacoesIniciou());
    final s = await aguarda();
    expect(uc.chamadas.single['ini'], '2026-09-19');
    expect(uc.chamadas.single['fim'], '2026-10-18');
    expect(s.contagemPorTipo['venda'], 3);
    bloc.add(RelatorioMovimentacoesMaisCarregou());
    final m = await bloc.stream.firstWhere((s) => !s.carregandoMais);
    expect(m.items.length, 2);
    expect(uc.chamadas.last['page'], 2);
  });

  test('tipos múltiplos e Todas limpa', () async {
    bloc.add(RelatorioMovimentacoesTipoAlternou('venda'));
    await aguarda();
    bloc.add(RelatorioMovimentacoesTipoAlternou('compra'));
    await aguarda();
    expect(uc.chamadas.last['tipos'], ['venda', 'compra']);
    bloc.add(RelatorioMovimentacoesTipoAlternou(null));
    await aguarda();
    expect(uc.chamadas.last['tipos'], isNull);
  });

  test('período > 93 dias não chama use case', () async {
    bloc.add(RelatorioMovimentacoesPeriodoAlterou(
        DateTime(2026, 1, 1), DateTime(2026, 10, 18)));
    final s = await aguarda();
    expect(s.step, RelatorioMovimentacoesStep.falha);
    expect(uc.chamadas, isEmpty);
  });
}
