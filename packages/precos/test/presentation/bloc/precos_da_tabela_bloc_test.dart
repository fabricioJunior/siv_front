import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';
import 'package:precos/use_cases.dart';

class MockRecuperarPrecosDasReferencias extends Mock
    implements RecuperarPrecosDasReferencias {}

class MockCriarPrecoDaReferencia extends Mock
    implements CriarPrecoDaReferencia {}

class MockAtualizarPrecoDaReferencia extends Mock
    implements AtualizarPrecoDaReferencia {}

class MockRemoverPrecoDaReferencia extends Mock
    implements RemoverPrecoDaReferencia {}

late PrecosDaTabelaBloc bloc;
late RecuperarPrecosDasReferencias recuperarPrecosDasReferencias;
late CriarPrecoDaReferencia criarPrecoDaReferencia;
late AtualizarPrecoDaReferencia atualizarPrecoDaReferencia;
late RemoverPrecoDaReferencia removerPrecoDaReferencia;

void main() {
  setUp(() {
    recuperarPrecosDasReferencias = MockRecuperarPrecosDasReferencias();
    criarPrecoDaReferencia = MockCriarPrecoDaReferencia();
    atualizarPrecoDaReferencia = MockAtualizarPrecoDaReferencia();
    removerPrecoDaReferencia = MockRemoverPrecoDaReferencia();

    bloc = PrecosDaTabelaBloc(
      recuperarPrecosDasReferencias,
      criarPrecoDaReferencia,
      atualizarPrecoDaReferencia,
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
        when(
          recuperarPrecosDasReferencias.call(tabelaDePrecoId: 99),
        ).thenAnswer((_) async => [precoB, precoA]);
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
        when(
          recuperarPrecosDasReferencias.call(tabelaDePrecoId: 99),
        ).thenThrow(Exception('erro'));
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

  group('PrecoDaTabelaCriarSolicitado -', () {
    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve criar preco e ordenar por referenciaNome',
      setUp: () {
        when(
          criarPrecoDaReferencia.call(
            tabelaDePrecoId: 99,
            referenciaId: 3,
            valor: 33.5,
          ),
        ).thenAnswer(
          (_) async =>
              _fakePreco(referenciaId: 3, referenciaNome: 'Ref C', valor: 33.5),
        );
      },
      build: () => bloc,
      seed: () => PrecosDaTabelaState(
        step: PrecosDaTabelaStep.carregado,
        tabelaDePrecoId: 99,
        precos: [precoB, precoA],
      ),
      act: (bloc) =>
          bloc.add(PrecoDaTabelaCriarSolicitado(referenciaId: 3, valor: 33.5)),
      expect: () => [
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.salvando,
          tabelaDePrecoId: 99,
          precos: [precoB, precoA],
        ),
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregado,
          tabelaDePrecoId: 99,
          precos: [
            precoA,
            precoB,
            _fakePreco(referenciaId: 3, referenciaNome: 'Ref C', valor: 33.5),
          ],
        ),
      ],
      verify: (_) {
        verify(
          criarPrecoDaReferencia.call(
            tabelaDePrecoId: 99,
            referenciaId: 3,
            valor: 33.5,
          ),
        ).called(1);
      },
    );

    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve bloquear duplicidade de referencia na mesma tabela',
      build: () => bloc,
      seed: () => PrecosDaTabelaState(
        step: PrecosDaTabelaStep.carregado,
        tabelaDePrecoId: 99,
        precos: [precoA],
      ),
      act: (bloc) =>
          bloc.add(PrecoDaTabelaCriarSolicitado(referenciaId: 1, valor: 12)),
      expect: () => [
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.falha,
          tabelaDePrecoId: 99,
          precos: [precoA],
          erro: 'Já existe preço para esta referência nesta tabela.',
        ),
      ],
      verify: (_) {
        verifyNever(
          criarPrecoDaReferencia.call(
            tabelaDePrecoId: 99,
            referenciaId: 1,
            valor: 12,
          ),
        );
      },
    );
  });

  group('PrecoDaTabelaAtualizarSolicitado -', () {
    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve atualizar preco de referencia existente',
      setUp: () {
        when(
          atualizarPrecoDaReferencia.call(
            tabelaDePrecoId: 99,
            referenciaId: 2,
            valor: 29.99,
          ),
        ).thenAnswer(
          (_) async => _fakePreco(
            referenciaId: 2,
            referenciaNome: 'Ref B',
            valor: 29.99,
          ),
        );
      },
      build: () => bloc,
      seed: () => PrecosDaTabelaState(
        step: PrecosDaTabelaStep.carregado,
        tabelaDePrecoId: 99,
        precos: [precoB, precoA],
      ),
      act: (bloc) => bloc.add(
        PrecoDaTabelaAtualizarSolicitado(referenciaId: 2, valor: 29.99),
      ),
      expect: () => [
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.salvando,
          tabelaDePrecoId: 99,
          precos: [precoB, precoA],
        ),
        PrecosDaTabelaState(
          step: PrecosDaTabelaStep.carregado,
          tabelaDePrecoId: 99,
          precos: [
            precoA,
            _fakePreco(referenciaId: 2, referenciaNome: 'Ref B', valor: 29.99),
          ],
        ),
      ],
      verify: (_) {
        verify(
          atualizarPrecoDaReferencia.call(
            tabelaDePrecoId: 99,
            referenciaId: 2,
            valor: 29.99,
          ),
        ).called(1);
      },
    );
  });

  group('PrecoDaTabelaRemoverSolicitado -', () {
    blocTest<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      'deve remover preco por referenciaId',
      setUp: () {
        when(
          removerPrecoDaReferencia.call(tabelaDePrecoId: 99, referenciaId: 2),
        ).thenAnswer((_) async {});
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
        verify(
          removerPrecoDaReferencia.call(tabelaDePrecoId: 99, referenciaId: 2),
        ).called(1);
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
    criadoEm: DateTime(2025, 1, 1),
    atualizadoEm: DateTime(2025, 1, 1),
    tabelaDePrecoId: 99,
    referenciaId: referenciaId,
    referenciaIdExterno: 'REF-$referenciaId',
    referenciaNome: referenciaNome,
    valor: valor,
    operadorId: 10,
  );
}
