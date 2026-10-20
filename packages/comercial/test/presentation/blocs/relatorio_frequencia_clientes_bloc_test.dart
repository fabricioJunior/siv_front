import 'package:comercial/data/fake/relatorio_frequencia_clientes_repository_fake.dart';
import 'package:comercial/domain/use_cases/get_relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

RelatorioFrequenciaClientesBloc _novo() => RelatorioFrequenciaClientesBloc(
  GetRelatorioFrequenciaClientes(FrequenciaClientesRepositoryFake()),
  empresaId: () => 1,
  hoje: () => DateTime(2026, 4, 30),
);

Future<RelatorioFrequenciaClientesState> _depois(
  RelatorioFrequenciaClientesBloc b,
  RelatorioFrequenciaClientesEvent e,
) async {
  b.add(e);
  return b.stream.firstWhere(
    (s) => !s.carregandoLista && s.status != FrequenciaStatus.carregando,
  );
}

void main() {
  late RelatorioFrequenciaClientesBloc bloc;

  setUp(() async {
    bloc = _novo();
    await _depois(bloc, const FrequenciaIniciou());
  });
  tearDown(() => bloc.close());

  test('carga inicial: 12 meses, página 1', () {
    expect(bloc.state.status, FrequenciaStatus.sucesso);
    expect(bloc.state.periodo, FrequenciaPeriodo.meses12);
    expect(bloc.state.inicio, DateTime(2025, 4, 30));
    expect(bloc.state.items.length, 20);
    expect(bloc.state.page, 1);
  });

  test('período e filtros de base resetam página e fecham linhas', () async {
    await _depois(bloc, const FrequenciaMudouPagina(2));
    bloc.add(const FrequenciaAlternouLinha(50));
    await bloc.stream.first;
    expect(bloc.state.page, 2);
    expect(bloc.state.linhasAbertas, {50});

    var s = await _depois(bloc, const FrequenciaMudouPeriodo(FrequenciaPeriodo.meses6));
    expect(s.page, 1);
    expect(s.linhasAbertas, isEmpty);
    expect(s.inicio, DateTime(2025, 10, 30));

    await _depois(bloc, const FrequenciaMudouPagina(2));
    bloc.add(const FrequenciaAlternouLinha(60));
    await bloc.stream.first;
    s = await _depois(bloc, const FrequenciaMudouFiltrosBase(funcionarioIds: [3]));
    expect(s.page, 1);
    expect(s.linhasAbertas, isEmpty);
    expect(s.funcionarioIds, [3]);
  });

  test('classe (toggle) e atrasados combinam; filtram só a lista', () async {
    final base = bloc.state.resumo.clientes;
    var s = await _depois(bloc, const FrequenciaMudouClasse('A'));
    expect(s.classe, 'A');
    expect(s.items.every((e) => e.classe == 'A'), isTrue);
    s = await _depois(bloc, const FrequenciaAlternouAtrasados());
    expect(s.classe, 'A');
    expect(s.atrasados, isTrue);
    expect(s.items.every((e) => e.classe == 'A' && e.atrasado), isTrue);
    expect(s.resumo.clientes, base);
    s = await _depois(bloc, const FrequenciaMudouClasse('A'));
    expect(s.classe, isNull);
    expect(s.atrasados, isTrue);
  });

  test('ordenação: primeiro clique asc/desc conforme coluna, segundo inverte', () async {
    var s = await _depois(bloc, const FrequenciaMudouOrdenacao('nome'));
    expect((s.ordenarPor, s.ordem), ('nome', 'asc'));
    s = await _depois(bloc, const FrequenciaMudouOrdenacao('nome'));
    expect(s.ordem, 'desc');
    s = await _depois(bloc, const FrequenciaMudouOrdenacao('valor'));
    expect((s.ordenarPor, s.ordem), ('valor', 'desc'));
    s = await _depois(bloc, const FrequenciaMudouOrdenacao('valor'));
    expect(s.ordem, 'asc');
  });

  test('modo acumulado anexa páginas', () async {
    final b = _novo();
    addTearDown(b.close);
    await _depois(b, const FrequenciaIniciou(acumulando: true));
    b.add(const FrequenciaCarregouMais());
    final s = await b.stream.firstWhere((s) => s.page == 2 && !s.carregandoMais);
    expect(s.items.length, 40);
  });

  test('personalizado > 24 meses é ignorado', () async {
    bloc.add(FrequenciaMudouPeriodo(
      FrequenciaPeriodo.personalizado,
      inicio: DateTime(2020),
      fim: DateTime(2026),
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.periodo, FrequenciaPeriodo.meses12);
  });
}
