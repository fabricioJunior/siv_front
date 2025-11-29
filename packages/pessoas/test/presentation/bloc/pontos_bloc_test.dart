import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pontos_bloc/pontos_bloc.dart';
import 'package:pessoas/uses_cases.dart';

import '../../doubles/fakes.dart';
import '../../doubles/use_cases.mocks.dart';
import 'pessoas_bloc_test.dart';

late PontosBloc pontosBloc;

final RecuperarPontosDaPessoa recuperarPontosDaPessoa =
    MockRecuperarPontosDaPessoa();

final CriarPontos criarPontos = MockCriarPontos();

final RecuperarPessoa recuperarPessoa = MockRecuperarPessoa();

final CancelarPonto cancelarPonto = MockCancelarPonto();

void main() {
  final pessoa = fakePessoa();
  final ponto1 = fakePonto(valor: 1, id: 1);
  final ponto2 = fakePonto(valor: 2, id: 2);
  final ponto3 = fakePonto(id: 3, valor: 3);
  final pontos = [ponto1, ponto2];
  final pontos2 = [ponto1, ponto2, ponto3];

  var carregarEmProgresso = PontosCarregarEmProgresso(
    idPessoa: pessoa.id,
  );
  var carregarSucesso = PontosCarregarSucesso.fromLastState(
    carregarEmProgresso,
    pontos: pontos,
    pessoa: pessoa,
  );

  var criarPontoEmProgresso = PontosCriarPontoEmProgresso.fromLastState(
    carregarSucesso,
  );
  var criarPontosSucesso = PontosCriarPontoSucesso.fromLastState(
    criarPontoEmProgresso,
    pontos: pontos2,
  );

  var pontosCancelarEmProgresso = PontosExcluirPontoEmProgresso.fromLastState(
    criarPontosSucesso,
  );
  var pontosCancelarSucesso = PontosExcluirPontoSucesso.fromLastState(
    pontosCancelarEmProgresso,
    pontos: pontos,
  );
  setUp(() {
    _setupRecuperarPessoa();
    pontosBloc = PontosBloc(
      recuperarPontosDaPessoa,
      criarPontos,
      recuperarPessoa,
      cancelarPonto,
    );
  });

  blocTest<PontosBloc, PontosState>(
    'emite estado de sucesso quando carregar pontos da pessoa',
    build: () => pontosBloc,
    setUp: () {
      _setupRecuperarPontosDaPessoa(
        idPessoa: pessoa.id!,
        response: pontos,
      );
    },
    act: (bloc) => bloc.add(
      PontosIniciou(
        idPessoa: pessoa.id!,
      ),
    ),
    expect: () {
      return [
        carregarEmProgresso,
        carregarSucesso,
      ];
    },
  );

  blocTest<PontosBloc, PontosState>(
    'emite estado de sucesso quando cria novo ponto',
    build: () => pontosBloc,
    seed: () => carregarSucesso,
    act: (bloc) {
      bloc.add(
        PontosCriouNovoPonto(
          valor: ponto3.valor,
          descricao: ponto3.descricao,
        ),
      );
    },
    setUp: () {
      _setupCriarPontos(
        idPessoa: pessoa.id!,
        valor: ponto3.valor,
        descricao: ponto3.descricao,
        response: ponto3,
      );
    },
    expect: () {
      return [
        criarPontoEmProgresso,
        criarPontosSucesso,
      ];
    },
  );
  blocTest<PontosBloc, PontosState>(
    'emite estado de sucesso quando cancelar ponto',
    build: () => pontosBloc,
    seed: () => criarPontosSucesso,
    act: (bloc) {
      bloc.add(
        PontosCancelouPonto(
          idPonto: ponto3.id,
        ),
      );
    },
    setUp: () {},
    expect: () {
      return [
        pontosCancelarEmProgresso,
        pontosCancelarSucesso,
      ];
    },
    verify: (bloc) {
      verify(cancelarPonto.call(
        idPonto: ponto3.id,
        idPessoa: pessoa.id!,
      )).called(1);
    },
  );
}

void _setupRecuperarPontosDaPessoa({
  required int idPessoa,
  required List<Ponto> response,
}) {
  when(recuperarPontosDaPessoa.call(idPessoa: idPessoa)).thenAnswer(
    (_) async => response,
  );
}

void _setupCriarPontos({
  required int idPessoa,
  required int valor,
  required String descricao,
  required Ponto response,
}) {
  when(criarPontos.call(idPessoa: idPessoa, valor: valor, descricao: descricao))
      .thenAnswer(
    (_) async => response,
  );
}

void _setupRecuperarPessoa() {
  when(recuperarPessoa.call(idPessoa: pessoa.id!)).thenAnswer(
    (_) async => pessoa,
  );
}
