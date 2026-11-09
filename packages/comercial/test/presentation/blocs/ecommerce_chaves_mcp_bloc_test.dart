import 'dart:async';

import 'package:comercial/domain/data/repositories/i_ecommerce_chaves_mcp_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

EcommerceChaveMcp _chave(int id, {DateTime? revogadaEm}) => EcommerceChaveMcp(
      id: id,
      nome: 'chave $id',
      chaveMascarada: 'ch-abc...$id',
      escopos: const ['catalogo'],
      revogadaEm: revogadaEm,
    );

class _Repo implements IEcommerceChavesMcpRepository {
  List<EcommerceChaveMcp> chaves;
  Object? falha;

  _Repo(this.chaves);

  @override
  Future<List<EcommerceChaveMcp>> recuperarChaves(int ecommerceId) async {
    if (falha != null) throw falha!;
    return chaves;
  }

  @override
  Future<CriarChaveMcpResultado> criarChave(
    int ecommerceId, {
    required String nome,
    required List<String> escopos,
    DateTime? expiraEm,
  }) async {
    if (falha != null) throw falha!;
    return CriarChaveMcpResultado(registro: _chave(9), chave: 'ch-segredo');
  }

  @override
  Future<EcommerceChaveMcp> revogarChave(int ecommerceId, int chaveId) async {
    if (falha != null) throw falha!;
    return _chave(chaveId, revogadaEm: DateTime(2026, 11, 9));
  }
}

EcommerceChavesMcpBloc _bloc(_Repo r) => EcommerceChavesMcpBloc(
      RecuperarChavesMcp(repository: r),
      CriarChaveMcp(repository: r),
      RevogarChaveMcp(repository: r),
    );

Future<EcommerceChavesMcpBloc> _iniciado(_Repo r) async {
  final bloc = _bloc(r)..add(const EcommerceChavesMcpIniciou(ecommerceId: 3));
  await bloc.stream.firstWhere((s) => s.step != EcommerceChavesMcpStep.carregando);
  return bloc;
}

void main() {
  test('carregar: carregado com as chaves', () async {
    final bloc = await _iniciado(_Repo([_chave(1), _chave(2)]));
    expect(bloc.state.step, EcommerceChavesMcpStep.carregado);
    expect(bloc.state.chaves.length, 2);
    expect(bloc.state.ativas, 2);
  });

  test('carregar: lista vazia', () async {
    final bloc = await _iniciado(_Repo([]));
    expect(bloc.state.step, EcommerceChavesMcpStep.vazio);
  });

  test('carregar: erro', () async {
    final bloc = _bloc(_Repo([])..falha = Exception('x'))
      ..add(const EcommerceChavesMcpIniciou(ecommerceId: 3));
    await bloc.stream.firstWhere((s) => s.step == EcommerceChavesMcpStep.erro);
    expect(bloc.state.chaves, isEmpty);
  });

  test('criar: chave em claro só no retorno; registro entra no topo da lista', () async {
    final bloc = await _iniciado(_Repo([_chave(1)]));
    final resposta = Completer<CriarChaveMcpResultado>();
    bloc.add(EcommerceChaveMcpCriou(nome: 'n', escopos: const ['catalogo'], resposta: resposta));
    final r = await resposta.future;
    expect(r.chave, 'ch-segredo');
    expect(bloc.state.chaves.map((c) => c.id), [9, 1]);
    expect(bloc.state.toString().contains('ch-segredo'), isFalse);
  });

  test('criar: falha devolve a mensagem e mantém a lista', () async {
    final repo = _Repo([_chave(1)]);
    final bloc = await _iniciado(repo);
    repo.falha = Exception('x');
    final resposta = Completer<CriarChaveMcpResultado>();
    bloc.add(EcommerceChaveMcpCriou(nome: 'n', escopos: const ['catalogo'], resposta: resposta));
    await expectLater(resposta.future, throwsA(isA<String>()));
    expect(bloc.state.chaves.length, 1);
  });

  test('revogar: atualiza a linha com o retorno do DELETE', () async {
    final bloc = await _iniciado(_Repo([_chave(1), _chave(2)]));
    final resposta = Completer<EcommerceChaveMcp>();
    bloc.add(EcommerceChaveMcpRevogou(chaveId: 2, resposta: resposta));
    await resposta.future;
    expect(bloc.state.chaves[1].situacao, SituacaoChaveMcp.revogada);
    expect(bloc.state.chaves[0].situacao, SituacaoChaveMcp.ativa);
    expect(bloc.state.ativas, 1);
  });
}
