import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/usuario_bloc/usuario_bloc.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

final RecuperarUsuario recuperarUsuario = MockRecuperarUsuario();

late UsuarioBloc usuarioBloc;
void main() {
  group('usuario bloc', () {
    var usuario = fakeUsuario();

    setUp(() {
      usuarioBloc = UsuarioBloc(
        recuperarUsuario,
      );
    });
    blocTest<UsuarioBloc, UsuarioState>(
      'emite estado de sucesso após carregar usuario',
      build: () {
        return usuarioBloc;
      },
      setUp: () {
        _setupRecuperarUsuario(usuario.id, usuario: usuario);
      },
      act: (bloc) => bloc.add(
        UsuarioIniciou(
          idUsuario: usuario.id,
        ),
      ),
      expect: () => [
        UsuarioCarregarEmProgresso(),
        UsuarioCarregarSucesso(usuario: usuario),
      ],
    );

    blocTest<UsuarioBloc, UsuarioState>(
      'emite estado de progresso para edição de dados do usuário',
      build: () {
        return usuarioBloc;
      },
      setUp: () {},
      seed: () => UsuarioCarregarSucesso(usuario: usuario),
      act: (bloc) => bloc.add(UsuarioEditou()),
      expect: () => [
        UsuarioEditarEmProgresso(usuario),
      ],
    );
    blocTest<UsuarioBloc, UsuarioState>(
      'emite estado de progresso para edição de dados do usuário',
      build: () {
        return usuarioBloc;
      },
      setUp: () {},
      seed: () => UsuarioNaoInicializado(),
      act: (bloc) => bloc.add(
        UsuarioIniciou(),
      ),
      expect: () => [
        UsuarioEditarEmProgresso.empty(),
      ],
    );
    blocTest<UsuarioBloc, UsuarioState>(
      'emite estado de progresso ao realizar edição de atributo do usuário',
      build: () {
        return usuarioBloc;
      },
      setUp: () {},
      seed: () => UsuarioEditarEmProgresso.empty(),
      act: (bloc) => bloc.add(UsuarioEditou(
          nome: 'nome editado',
          login: 'login editado',
          senha: 'senha editada')),
      expect: () => [
        UsuarioEditarEmProgresso.empty(
          nome: 'nome editado',
          login: 'login editado',
          senha: 'senha editada',
        ),
      ],
    );
  });
}

void _setupRecuperarUsuario(int? id, {required Usuario? usuario}) {
  when(recuperarUsuario.call(id)).thenAnswer((_) async => usuario);
}
