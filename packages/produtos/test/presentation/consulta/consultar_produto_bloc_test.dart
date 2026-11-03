import 'package:flutter_test/flutter_test.dart';

import 'consulta_fakes.dart';

Future<void> _espera() => Future.delayed(const Duration(milliseconds: 80));

void main() {
  late FakeConsultaRepo repo;
  late FakeGradeRepo grade;

  setUp(() {
    repo = FakeConsultaRepo();
    grade = FakeGradeRepo();
  });

  test('busca com menos de 2 caracteres e sem filtro não consulta', () async {
    final bloc = novoBloc(repo, grade)..add(ConsultarProdutoBuscaAlterada('a'));
    await _espera();
    expect(repo.chamadas, isEmpty);
    expect(bloc.state.itens, isEmpty);
  });

  test('debounce: digitação rápida gera uma única consulta', () async {
    final bloc = novoBloc(repo, grade)
      ..add(ConsultarProdutoBuscaAlterada('ca'))
      ..add(ConsultarProdutoBuscaAlterada('cal'))
      ..add(ConsultarProdutoBuscaAlterada('calça'));
    await _espera();
    expect(repo.chamadas.length, 1);
    expect(repo.chamadas.single['busca'], 'calça');
    expect(bloc.state.itens.length, 2);
  });

  test('filtro de estampa consulta mesmo sem texto', () async {
    final bloc = novoBloc(repo, grade)
      ..add(ConsultarProdutoFiltrosAlterados(estampas: [estampaFake(7)]));
    await _espera();
    expect(repo.chamadas.single['estampaIds'], [7]);
    expect(bloc.state.itens, isNotEmpty);
  });

  test('abrir referência e voltar preserva busca, filtros e resultados', () async {
    final bloc = novoBloc(repo, grade)..add(ConsultarProdutoBuscaAlterada('calça'));
    await _espera();
    bloc.add(ConsultarProdutoReferenciaSelecionada(100));
    await _espera();
    expect(bloc.state.referenciaAbertaId, 100);
    expect(bloc.state.grade?.nome, 'Calça Jeans');
    expect(bloc.state.busca, 'calça');
    expect(bloc.state.itens.length, 2);
  });

  test('código lido abre a referência, destaca variação e mantém busca', () async {
    final bloc = novoBloc(repo, grade)..add(ConsultarProdutoBuscaAlterada('calça'));
    await _espera();
    repo.resposta = (busca, page) => busca == '789'
        ? const ConsultaReferenciasPagina(items: [itemA], produtoIdLido: 12)
        : const ConsultaReferenciasPagina(items: [itemA, itemB]);
    bloc.add(ConsultarProdutoCodigoLido('789'));
    await _espera();
    final s = bloc.state;
    expect(s.leitura!.encontrada, isTrue);
    expect(s.produtoIdLido, 12);
    expect(s.referenciaAbertaId, 100);
    expect(s.busca, 'calça');
    expect(s.itens.length, 2);
  });

  test('código não encontrado só marca a leitura', () async {
    final bloc = novoBloc(repo, grade)..add(ConsultarProdutoBuscaAlterada('calça'));
    await _espera();
    repo.resposta = (_, _) => const ConsultaReferenciasPagina(items: []);
    bloc.add(ConsultarProdutoCodigoLido('000'));
    await _espera();
    expect(bloc.state.leitura!.encontrada, isFalse);
    expect(bloc.state.referenciaAbertaId, isNull);
    expect(bloc.state.itens.length, 2);
  });

  test('paginação acrescenta itens', () async {
    repo.resposta = (_, page) => ConsultaReferenciasPagina(
      items: [page == 1 ? itemA : itemB], page: page, totalPages: 2,
    );
    final bloc = novoBloc(repo, grade)..add(ConsultarProdutoBuscaAlterada('ca'));
    await _espera();
    bloc.add(ConsultarProdutoMaisCarregado());
    await _espera();
    expect(bloc.state.itens.map((i) => i.referenciaId), [100, 200]);
    expect(bloc.state.temMais, isFalse);
  });
}
