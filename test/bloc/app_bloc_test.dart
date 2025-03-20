import 'package:autenticacao/uses_cases.dart';
import 'package:autenticacao/models.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siv_front/bloc/app_bloc.dart';

import '../doubles/doubles.dart';
import '../doubles/use_cases.mocks.dart';

final OnAutenticado onAutenticado = MockOnAutenticado();
final EstaAutenticado estaAutenticado = MockEstaAutenticado();
final Deslogar deslogar = MockDeslogar();
final RecuperarUsuarioDaSessao recuperarUsuarioDaSessao =
    MockRecuperarUsuarioDaSessao();

late AppBloc appBloc;

var usuario = fakeUsuario();
void main() {
  setUp(() {
    _setupRecuperarUsuarioDaSessao(usuario);
  });
  blocTest(
    'emite estado com informações salvas de autenticacao',
    setUp: () {
      _setupOnTokenCriado(
        null,
      );
      _setupEstaAutenticado(true);
    },
    build: () {
      return AppBloc(
        estaAutenticado,
        onAutenticado,
        deslogar,
        recuperarUsuarioDaSessao,
      );
    },
    act: (bloc) => bloc.add(AppIniciou()),
    expect: () => [
      AppState(
          statusAutenticacao: StatusAutenticacao.autenticado,
          usuarioDaSessao: usuario),
    ],
  );
  blocTest(
    'emite estado status de autenticado quando recebe evento de autenticado com informações da sessão',
    setUp: () {
      _setupOnTokenCriado(
        Token(
          jwtToken: '',
          dataDeCriacao: DateTime.now(),
          dataDeExpiracao: DateTime.now(),
        ),
      );
    },
    build: () {
      return AppBloc(
        estaAutenticado,
        onAutenticado,
        deslogar,
        recuperarUsuarioDaSessao,
      );
    },
    expect: () => [
      AppState(
        statusAutenticacao: StatusAutenticacao.autenticado,
        usuarioDaSessao: usuario,
      ),
    ],
  );
  blocTest(
    'emite estado status de desautenticado quando recebe evento de desautenticacao',
    setUp: () {
      _setupOnTokenCriado(null);
    },
    build: () {
      return AppBloc(
          estaAutenticado, onAutenticado, deslogar, recuperarUsuarioDaSessao);
    },
    expect: () => [
      const AppState(statusAutenticacao: StatusAutenticacao.naoAutenticao),
    ],
  );
}

void _setupOnTokenCriado(Token? token) {
  if (token == null) {
    when(onAutenticado.call()).thenAnswer((_) => Stream.fromIterable([]));
  } else {
    when(onAutenticado.call()).thenAnswer((_) => Stream.value(token));
  }
}

void _setupEstaAutenticado(bool autenticacao) {
  when(estaAutenticado.call()).thenAnswer((_) async => autenticacao);
}

void _setupRecuperarUsuarioDaSessao(Usuario usuario) {
  when(recuperarUsuarioDaSessao.call()).thenAnswer((_) async => usuario);
}
