import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/domain/usecases/recuperar_permissoes.dart';
import 'package:autenticacao/presentation/bloc/permissoes_bloc/permissoes_bloc.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

// Mock do caso de uso
late RecuperarPermissoes recuperarPermissoes;

void main() {
  late List<Permissao> permissoesFake;

  setUp(() {
    recuperarPermissoes = MockRecuperarPermissoes();
    permissoesFake = _permissoesFake();
  });

  group('PermissoesBloc', () {
    blocTest<PermissoesBloc, PermissoesState>(
      'emite [PermissoesCarregarEmProgesso, PermissoesCarregarSucesso] ao carregar permissões com sucesso',
      build: () {
        _setupRecuperarPermissoes(permissoesFake);
        return PermissoesBloc(recuperarPermissoes: recuperarPermissoes);
      },
      act: (bloc) => bloc.add(PermissoesIniciou()),
      expect: () => [
        PermissoesCarregarEmProgesso(),
        PermissoesCarregarSucesso(permissoes: permissoesFake),
      ],
    );

    blocTest<PermissoesBloc, PermissoesState>(
      'emite [PermissoesCarregarEmProgesso, PermissoesCarregarFalha] ao falhar ao carregar permissões',
      build: () {
        _setupFalhaRecuperarPermissoes();
        return PermissoesBloc(recuperarPermissoes: recuperarPermissoes);
      },
      act: (bloc) => bloc.add(PermissoesIniciou()),
      expect: () => [
        PermissoesCarregarEmProgesso(),
        const PermissoesCarregarFalha(mensagem: 'Erro desconhecido'),
      ],
    );
  });
}

void _setupFalhaRecuperarPermissoes() {
  when(recuperarPermissoes.call())
      .thenThrow(Exception('Erro ao carregar permissões'));
}

void _setupRecuperarPermissoes(List<Permissao> permissoesFake) {
  when(recuperarPermissoes.call()).thenAnswer((_) async => permissoesFake);
}

List<Permissao> _permissoesFake() {
  return [
    fakePermissao(
      id: 1,
      nome: "Componente A",
      descontinuado: false,
    ),
    fakePermissao(
      id: 2,
      nome: "Componente B",
      descontinuado: true,
    ),
    fakePermissao(
      id: 3,
      nome: "Componente C",
      descontinuado: false,
    ),
    fakePermissao(
      id: 4,
      nome: "Componente D",
      descontinuado: true,
    ),
  ];
}
