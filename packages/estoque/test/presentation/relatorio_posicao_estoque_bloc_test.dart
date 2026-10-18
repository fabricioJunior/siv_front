import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_posicao_estoque.dart';
import 'package:estoque/presentation/blocs/relatorio_posicao_estoque_bloc/relatorio_posicao_estoque_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Repo implements IRelatorioEstoqueRepository {
  final chamadas = <({String? situacao, String ordenarPor, String ordem})>[];

  @override
  Future<RelatorioPosicaoEstoque> posicaoEstoque({
    required List<int> empresaIds,
    String? dataReferencia,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    String? situacao,
    String ordenarPor = 'valor',
    String ordem = 'desc',
  }) async {
    chamadas.add((situacao: situacao, ordenarPor: ordenarPor, ordem: ordem));
    return const RelatorioPosicaoEstoque(
      items: [PosicaoEstoqueCategoria(categoriaNome: 'Calça', pecas: 2)],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _Repo repo;
  late RelatorioPosicaoEstoqueBloc bloc;

  setUp(() {
    if (sl.isRegistered<IAcessoGlobalSessao>()) sl.unregister<IAcessoGlobalSessao>();
    sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
    repo = _Repo();
    bloc = RelatorioPosicaoEstoqueBloc(
        GetRelatorioPosicaoEstoque(repository: repo));
  });
  tearDown(() => bloc.close());

  Future<void> espera() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('carga inicial: valor desc, sem situação', () async {
    bloc.add(const PosicaoEstoqueIniciou());
    await espera();
    expect(repo.chamadas.single,
        (situacao: null, ordenarPor: 'valor', ordem: 'desc'));
    expect(bloc.state.step, PosicaoEstoqueStep.sucesso);
    expect(bloc.state.dados!.items, hasLength(1));
  });

  test('toggle ruptura liga e desliga situacao', () async {
    bloc.add(const PosicaoEstoqueRupturaAlternada());
    await espera();
    expect(repo.chamadas.last.situacao, 'ruptura');
    bloc.add(const PosicaoEstoqueRupturaAlternada());
    await espera();
    expect(repo.chamadas.last.situacao, isNull);
  });

  test('ordenação: nova coluna desc (categoria asc), repetir inverte', () async {
    bloc.add(const PosicaoEstoqueOrdenou('pecas'));
    await espera();
    expect(repo.chamadas.last.ordenarPor, 'pecas');
    expect(repo.chamadas.last.ordem, 'desc');
    bloc.add(const PosicaoEstoqueOrdenou('pecas'));
    await espera();
    expect(repo.chamadas.last.ordem, 'asc');
    bloc.add(const PosicaoEstoqueOrdenou('categoria'));
    await espera();
    expect(repo.chamadas.last.ordem, 'asc');
  });
}
