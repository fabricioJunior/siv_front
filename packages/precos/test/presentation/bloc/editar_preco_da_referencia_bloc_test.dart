import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';
import 'package:precos/use_cases.dart';

class FakeAtualizarPrecoDaReferencia extends Fake
    implements AtualizarPrecoDaReferencia {
  Future<PrecoDaReferencia> Function({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  })?
  handler;
  int calls = 0;

  @override
  Future<PrecoDaReferencia> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) {
    calls++;
    return handler!(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
    );
  }
}

late EditarPrecoDaReferenciaBloc bloc;
late AtualizarPrecoDaReferencia atualizarPrecoDaReferencia;

void main() {
  setUp(() {
    atualizarPrecoDaReferencia = FakeAtualizarPrecoDaReferencia();
    bloc = EditarPrecoDaReferenciaBloc(atualizarPrecoDaReferencia);
  });

  group('EditarPrecoDaReferenciaSalvou -', () {
    blocTest<EditarPrecoDaReferenciaBloc, EditarPrecoDaReferenciaState>(
      'deve atualizar preço com sucesso',
      setUp: () {
        (atualizarPrecoDaReferencia as FakeAtualizarPrecoDaReferencia).handler =
            ({
              required tabelaDePrecoId,
              required referenciaId,
              required valor,
            }) async => _fakePreco(
              referenciaId: referenciaId,
              referenciaNome: 'Ref B',
              valor: valor,
            );
      },
      build: () => bloc,
      act: (bloc) => bloc.add(
        EditarPrecoDaReferenciaSalvou(
          tabelaDePrecoId: 99,
          referenciaId: 2,
          valor: 29.99,
        ),
      ),
      expect: () => [
        const EditarPrecoDaReferenciaState(
          step: EditarPrecoDaReferenciaStep.salvando,
        ),
        const EditarPrecoDaReferenciaState(
          step: EditarPrecoDaReferenciaStep.sucesso,
        ),
      ],
      verify: (_) {
        expect(
          (atualizarPrecoDaReferencia as FakeAtualizarPrecoDaReferencia).calls,
          1,
        );
      },
    );

    blocTest<EditarPrecoDaReferenciaBloc, EditarPrecoDaReferenciaState>(
      'deve emitir falha quando ocorrer erro ao atualizar',
      setUp: () {
        (atualizarPrecoDaReferencia as FakeAtualizarPrecoDaReferencia).handler =
            ({
              required tabelaDePrecoId,
              required referenciaId,
              required valor,
            }) => Future<PrecoDaReferencia>.error(Exception('erro'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(
        EditarPrecoDaReferenciaSalvou(
          tabelaDePrecoId: 99,
          referenciaId: 2,
          valor: 29.99,
        ),
      ),
      expect: () => [
        const EditarPrecoDaReferenciaState(
          step: EditarPrecoDaReferenciaStep.salvando,
        ),
        const EditarPrecoDaReferenciaState(
          step: EditarPrecoDaReferenciaStep.falha,
          erro: 'Erro ao atualizar preço da referência.',
        ),
      ],
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
