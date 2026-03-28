import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';
import 'package:precos/use_cases.dart';

class FakeRecuperarPrecosDasReferencias extends Fake
    implements RecuperarPrecosDasReferencias {
  Future<List<PrecoDaReferencia>> Function({required int tabelaDePrecoId})?
  handler;

  @override
  Future<List<PrecoDaReferencia>> call({required int tabelaDePrecoId}) {
    return handler!(tabelaDePrecoId: tabelaDePrecoId);
  }
}

class FakeRemoverPrecoDaReferencia extends Fake
    implements RemoverPrecoDaReferencia {
  Future<void> Function({
    required int tabelaDePrecoId,
    required int referenciaId,
  })?
  handler;
  int calls = 0;

  @override
  Future<void> call({required int tabelaDePrecoId, required int referenciaId}) {
    calls++;
    return handler!(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }
}

late PrecosDaTabelaBloc bloc;
late RecuperarPrecosDasReferencias recuperarPrecosDasReferencias;
late RemoverPrecoDaReferencia removerPrecoDaReferencia;

void main() {
  setUp(() {
    recuperarPrecosDasReferencias = FakeRecuperarPrecosDasReferencias();
    removerPrecoDaReferencia = FakeRemoverPrecoDaReferencia();

    bloc = PrecosDaTabelaBloc(
      recuperarPrecosDasReferencias,
      removerPrecoDaReferencia,
    );
  });

  final precoA = _fakePreco(
    referenciaId: 1,
    referenciaNome: 'Ref A',
    valor: 10,
  );
  final precoB = _fakePreco(
    referenciaId: 2,
    referenciaNome: 'Ref B',
    valor: 20,
  );

  group('PrecosDaTabelaIniciou -', () {
    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve carregar precos da tabela com sucesso',
      setUp: () {
        (recuperarPrecosDasReferencias as FakeRecuperarPrecosDasReferencias)
            .handler = ({required tabelaDePrecoId}) async => [
          precoB,
          precoA,
        ];
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PrecosDaTabelaIniciou(tabelaDePrecoId: 99)),
      expect: () => [
        const PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregando,
          tabelaDePrecoId: 99,
          precos: [],
        ),
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregado,
          tabelaDePrecoId: 99,
          precos: [precoB, precoA],
        ),
      ],
    );

    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve emitir falha quando ocorrer erro ao carregar',
      setUp: () {
        (recuperarPrecosDasReferencias as FakeRecuperarPrecosDasReferencias)
            .handler = ({required tabelaDePrecoId}) =>
            Future<List<PrecoDaReferencia>>.error(Exception('erro'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PrecosDaTabelaIniciou(tabelaDePrecoId: 99)),
      expect: () => [
        const PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregando,
          tabelaDePrecoId: 99,
          precos: [],
        ),
        const PrecosDaTabelaState(
          step: PrecosDaTabelaStep.falha,
          tabelaDePrecoId: 99,
          precos: [],
          erro: 'Erro ao carregar preços da tabela.',
        ),
      ],
    );
  });

  group('PrecoDaTabelaRemoverSolicitado -', () {
    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve remover preco por referenciaId',
      setUp: () {
        (removerPrecoDaReferencia as FakeRemoverPrecoDaReferencia).handler =
            ({required tabelaDePrecoId, required referenciaId}) async {};
      },
      build: () => bloc,
      seed: () => PrecosDaTabelaState(
        step: PrecosDaTabelaStep.carregado,
        tabelaDePrecoId: 99,
        precos: [precoA, precoB],
      ),
      act: (bloc) => bloc.add(PrecoDaTabelaRemoverSolicitado(referenciaId: 2)),
      expect: () => [
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.salvando,
          tabelaDePrecoId: 99,
          precos: [precoA, precoB],
        ),
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregado,
          tabelaDePrecoId: 99,
          precos: [precoA],
        ),
      ],
      verify: (_) {
        expect(
          (removerPrecoDaReferencia as FakeRemoverPrecoDaReferencia).calls,
          1,
        );
      },
    );
  });
}

PrecoDaReferencia _fakePreco({
  required int referenciaId,
  required String referenciaNome,
  required double valor,
}) {
  return PrecoDaReferencia.create(
    atualizadoEm: DateTime(2025, 1, 1),
    tabelaDePrecoId: 99,
    referenciaId: referenciaId,
    referenciaIdExterno: 'REF-$referenciaId',
    referenciaNome: referenciaNome,
    valor: valor,
    operadorId: 10,
  );
}
