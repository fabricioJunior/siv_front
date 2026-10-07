import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/acoes_do_grupo_bloc/acoes_do_grupo_bloc.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:flutter_test/flutter_test.dart';

AcaoDoGrupo _acao(String id, EstadoAcaoDoGrupo e, [List<String> requer = const []]) =>
    AcaoDoGrupo(
      id: id,
      nome: id,
      descricao: '',
      requer: requer,
      componentes: const [],
      estado: e,
      faltando: const [],
    );

AcoesDoGrupo _grupo(List<AcaoDoGrupo> acoes) => AcoesDoGrupo(
      grupoId: 1,
      fluxos: [FluxoDoGrupo(id: 'f', nome: 'f', descricao: '', acoes: acoes)],
      componentesAvulsos: const [],
    );

const _off = EstadoAcaoDoGrupo.desligada;
const _on = EstadoAcaoDoGrupo.ligada;

class _FakeRepo implements IPermissoesRepository {
  AcoesDoGrupo servidor;
  Object? erro;
  final chamadas = <({List<String> ativar, List<String> desativar})>[];
  AcoesDoGrupo aposSalvar;

  _FakeRepo(this.servidor, {AcoesDoGrupo? aposSalvar})
      : aposSalvar = aposSalvar ?? servidor;

  @override
  Future<AcoesDoGrupo> recuperarAcoesDoGrupoDeAcesso(int id) async => servidor;

  @override
  Future<AcoesDoGrupo> aplicarAcoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
    List<String> ativar = const [],
    List<String> desativar = const [],
  }) async {
    chamadas.add((ativar: ativar, desativar: desativar));
    if (erro != null) throw erro!;
    return servidor = aposSalvar;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<AcoesDoGrupoBloc> _bloc(_FakeRepo repo) async {
  final b = AcoesDoGrupoBloc(
    RecuperarAcoesDoGrupoDeAcesso(repository: repo),
    AplicarAcoesDoGrupoDeAcesso(repository: repo),
  )..add(AcoesDoGrupoCarregou(1));
  await b.stream.firstWhere((s) => s.status == AcoesDoGrupoStatus.pronto);
  return b;
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeRepo repo;
  setUp(() {
    repo = _FakeRepo(_grupo([
      _acao('a', _off),
      _acao('b', _off, ['a']),
      _acao('c', _on),
    ]));
  });

  test('alternar não chama o servidor; duas vezes remove a pendência', () async {
    final b = await _bloc(repo);
    b.add(AcoesDoGrupoAlternou('c', ligar: false));
    await _flush();
    expect(b.state.pendentes, {'c': false});
    expect(repo.chamadas, isEmpty);
    b.add(AcoesDoGrupoAlternou('c', ligar: true));
    await _flush();
    expect(b.state.pendentes, isEmpty);
  });

  test('ligar liga requeridas; desligar a requerida desliga dependentes', () async {
    final b = await _bloc(repo);
    b.add(AcoesDoGrupoAlternou('b', ligar: true));
    await _flush();
    expect(b.state.pendentes, {'b': true, 'a': true});
    b.add(AcoesDoGrupoAlternou('a', ligar: false));
    await _flush();
    expect(b.state.pendentes, isEmpty);
  });

  test('salvar envia uma chamada sem repetição e adota o estado retornado', () async {
    repo.aposSalvar = _grupo([
      _acao('a', _on),
      _acao('b', _on, ['a']),
      _acao('c', _off),
    ]);
    final b = await _bloc(repo);
    b.add(AcoesDoGrupoAlternou('b', ligar: true));
    b.add(AcoesDoGrupoAlternou('c', ligar: false));
    await _flush();
    b.add(AcoesDoGrupoSalvou());
    await b.stream.firstWhere((s) => s.aplicacoes == 1);
    expect(repo.chamadas, hasLength(1));
    expect(repo.chamadas.single.ativar.toSet(), {'a', 'b'});
    expect(repo.chamadas.single.desativar, ['c']);
    expect(b.state.pendentes, isEmpty);
    expect(b.state.acoes, repo.aposSalvar);
  });

  test('erro mantém pendências e expõe mensagem', () async {
    repo.erro = Exception('x');
    final b = await _bloc(repo);
    b.add(AcoesDoGrupoAlternou('a', ligar: true));
    await _flush();
    b.add(AcoesDoGrupoSalvou());
    await b.stream.firstWhere((s) => s.status == AcoesDoGrupoStatus.falha);
    expect(b.state.pendentes, {'a': true});
    expect(b.state.mensagemDeErro, isNotNull);
  });

  test('descartar volta ao estado do servidor', () async {
    final b = await _bloc(repo);
    b.add(AcoesDoGrupoAlternou('a', ligar: true));
    await _flush();
    b.add(AcoesDoGrupoDescartou());
    await _flush();
    expect(b.state.pendentes, isEmpty);
    expect(repo.chamadas, isEmpty);
  });
}
