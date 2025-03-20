import 'package:autenticacao/domain/models/usuario.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart';
import 'package:autenticacao/presentation/bloc/usuarios_bloc/usuarios_bloc.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

final RecuperarUsuarios recuperarUsuarios = MockRecuperarUsuarios();
late UsuariosBloc usuariosBloc;

var estadoInicial = const UsuariosNaoInicializados(usuarios: []);
void main() {
  setUp(() {
    usuariosBloc = UsuariosBloc(recuperarUsuarios);
  });

  var user1 = fakeUsuario(id: 1);
  var user2 = fakeUsuario(id: 2);
  var usuarios = [user1, user2];

  blocTest(
    'emite estado de sucesso após carregar usuarios',
    build: () => usuariosBloc,
    act: (bloc) => bloc.add(UsuariosIniciou()),
    setUp: () {
      _setupRecuperarUsuarios(usuarios: usuarios);
    },
    expect: () {
      var estadoDeCarregamento = UsuariosCarregarEmProgresso(estadoInicial);
      var estadoDeSucesso = UsuariosCarregarSucesso.fromLastState(
          estadoDeCarregamento,
          usuarios: usuarios);
      return [
        estadoDeCarregamento,
        estadoDeSucesso,
      ];
    },
  );
}

void _setupRecuperarUsuarios({
  required List<Usuario> usuarios,
}) {
  when(recuperarUsuarios.call()).thenAnswer((_) async => usuarios);
}
