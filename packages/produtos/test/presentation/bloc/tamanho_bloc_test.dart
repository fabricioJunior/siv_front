import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

import '../../doubles/fakes.dart';
import '../../doubles/usecases.mocks.dart';

late TamanhoBloc tamanhoBloc;

final RecuperarTamanho recuperarTamanho = MockRecuperarTamanho();
final CriarTamanho criarTamanho = MockCriarTamanho();
final AtualizarTamanho atualizarTamanho = MockAtualizarTamanho();

void main() {
  setUp(() {
    tamanhoBloc = TamanhoBloc(recuperarTamanho, criarTamanho, atualizarTamanho);
  });

  final tamanho = fakeTamanho(id: 1, nome: 'P', inativo: false);

  group('TamanhoIniciou -', () {
    blocTest<TamanhoBloc, TamanhoState>(
      'deve carregar tamanho existente quando idTamanho é fornecido',
      setUp: () {
        _setupRecuperarTamanho(id: tamanho.id!, response: tamanho);
      },
      build: () => tamanhoBloc,
      act: (bloc) => bloc.add(TamanhoIniciou(idTamanho: tamanho.id)),
      expect: () => [
        const TamanhoState(tamanhoStep: TamanhoStep.carregando),
        TamanhoState.fromModel(tamanho),
      ],
    );

    blocTest<TamanhoBloc, TamanhoState>(
      'deve iniciar novo tamanho quando idTamanho é null',
      build: () => tamanhoBloc,
      act: (bloc) => bloc.add(TamanhoIniciou()),
      expect: () => [
        const TamanhoState(tamanhoStep: TamanhoStep.carregando),
        const TamanhoState(tamanhoStep: TamanhoStep.editando, inativo: false),
      ],
    );

    blocTest<TamanhoBloc, TamanhoState>(
      'deve emitir falha quando tamanho não é encontrado',
      setUp: () {
        _setupRecuperarTamanho(id: 999, response: null);
      },
      build: () => tamanhoBloc,
      act: (bloc) => bloc.add(TamanhoIniciou(idTamanho: 999)),
      expect: () => [
        const TamanhoState(tamanhoStep: TamanhoStep.carregando),
        const TamanhoState(tamanhoStep: TamanhoStep.falha),
      ],
    );
  });

  group('TamanhoEditou -', () {
    blocTest<TamanhoBloc, TamanhoState>(
      'deve atualizar nome do tamanho',
      build: () => tamanhoBloc,
      seed: () =>
          const TamanhoState(tamanhoStep: TamanhoStep.editando, inativo: false),
      act: (bloc) => bloc.add(TamanhoEditou(nome: 'M')),
      expect: () => [
        const TamanhoState(
          tamanhoStep: TamanhoStep.editando,
          nome: 'M',
          inativo: false,
        ),
      ],
    );
  });

  group('TamanhoSalvou -', () {
    blocTest<TamanhoBloc, TamanhoState>(
      'deve criar novo tamanho quando id é null',
      setUp: () {
        _setupCriarTamanho(
          nome: 'G',
          response: fakeTamanho(id: 2, nome: 'G'),
        );
      },
      build: () => tamanhoBloc,
      seed: () => const TamanhoState(
        tamanhoStep: TamanhoStep.editando,
        nome: 'G',
        inativo: false,
      ),
      act: (bloc) => bloc.add(TamanhoSalvou()),
      expect: () => [
        const TamanhoState(
          tamanhoStep: TamanhoStep.carregando,
          nome: 'G',
          inativo: false,
        ),
        TamanhoState.fromModel(
          fakeTamanho(id: 2, nome: 'G'),
          step: TamanhoStep.criado,
        ),
      ],
      verify: (_) {
        verify(criarTamanho.call('G')).called(1);
      },
    );

    blocTest<TamanhoBloc, TamanhoState>(
      'deve salvar tamanho existente quando id não é null',
      setUp: () {
        _setupAtualizarTamanho(
          id: 1,
          nome: 'P Atualizado',
          response: fakeTamanho(id: 1, nome: 'P Atualizado'),
        );
      },
      build: () => tamanhoBloc,
      seed: () => TamanhoState(
        id: 1,
        tamanhoStep: TamanhoStep.editando,
        nome: 'P Atualizado',
        inativo: false,
        tamanho: tamanho,
      ),
      act: (bloc) => bloc.add(TamanhoSalvou()),
      expect: () => [
        TamanhoState(
          id: 1,
          tamanhoStep: TamanhoStep.carregando,
          nome: 'P Atualizado',
          inativo: false,
          tamanho: tamanho,
        ),
        TamanhoState.fromModel(
          fakeTamanho(id: 1, nome: 'P Atualizado'),
          step: TamanhoStep.salvo,
        ),
      ],
      verify: (_) {
        verify(atualizarTamanho.call(1, 'P Atualizado')).called(1);
      },
    );

    blocTest<TamanhoBloc, TamanhoState>(
      'deve emitir falha quando ocorre erro ao salvar',
      setUp: () {
        when(
          criarTamanho.call('XL'),
        ).thenThrow(Exception('Erro ao criar tamanho'));
      },
      build: () => tamanhoBloc,
      seed: () => const TamanhoState(
        tamanhoStep: TamanhoStep.editando,
        nome: 'XL',
        inativo: false,
      ),
      act: (bloc) => bloc.add(TamanhoSalvou()),
      expect: () => [
        const TamanhoState(
          tamanhoStep: TamanhoStep.carregando,
          nome: 'XL',
          inativo: false,
        ),
        const TamanhoState(
          tamanhoStep: TamanhoStep.falha,
          nome: 'XL',
          inativo: false,
        ),
      ],
    );
  });
}

void _setupRecuperarTamanho({required int id, required Tamanho? response}) {
  when(recuperarTamanho.call(id)).thenAnswer((_) async => response);
}

void _setupCriarTamanho({required String nome, required Tamanho response}) {
  when(criarTamanho.call(nome)).thenAnswer((_) async => response);
}

void _setupAtualizarTamanho({
  required int id,
  required String nome,
  required Tamanho response,
}) {
  when(atualizarTamanho.call(id, nome)).thenAnswer((_) async => response);
}
