// Mocks generated by Mockito 5.4.4 from annotations
// in autenticacao/test/doubles/uses_cases.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart'
    as _i2;
import 'package:autenticacao/domain/models/token.dart' as _i5;
import 'package:autenticacao/domain/models/usuario.dart' as _i7;
import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart'
    as _i3;
import 'package:autenticacao/domain/usecases/recuperar_usuario.dart' as _i8;
import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart' as _i6;
import 'package:autenticacao/domain/usecases/salvar_usuario.dart' as _i9;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeIUsuariosRepository_0 extends _i1.SmartFake
    implements _i2.IUsuariosRepository {
  _FakeIUsuariosRepository_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [CriarTokenDeAutenticacao].
///
/// See the documentation for Mockito's code generation for more information.
class MockCriarTokenDeAutenticacao extends _i1.Mock
    implements _i3.CriarTokenDeAutenticacao {
  MockCriarTokenDeAutenticacao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i5.Token?> call({
    required String? usuario,
    required String? senha,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [],
          {
            #usuario: usuario,
            #senha: senha,
          },
        ),
        returnValue: _i4.Future<_i5.Token?>.value(),
      ) as _i4.Future<_i5.Token?>);
}

/// A class which mocks [RecuperarUsuarios].
///
/// See the documentation for Mockito's code generation for more information.
class MockRecuperarUsuarios extends _i1.Mock implements _i6.RecuperarUsuarios {
  MockRecuperarUsuarios() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<Iterable<_i7.Usuario>> call() => (super.noSuchMethod(
        Invocation.method(
          #call,
          [],
        ),
        returnValue: _i4.Future<Iterable<_i7.Usuario>>.value(<_i7.Usuario>[]),
      ) as _i4.Future<Iterable<_i7.Usuario>>);
}

/// A class which mocks [RecuperarUsuario].
///
/// See the documentation for Mockito's code generation for more information.
class MockRecuperarUsuario extends _i1.Mock implements _i8.RecuperarUsuario {
  MockRecuperarUsuario() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.IUsuariosRepository get usuariosRepository => (super.noSuchMethod(
        Invocation.getter(#usuariosRepository),
        returnValue: _FakeIUsuariosRepository_0(
          this,
          Invocation.getter(#usuariosRepository),
        ),
      ) as _i2.IUsuariosRepository);

  @override
  _i4.Future<_i7.Usuario?> call(int? id) => (super.noSuchMethod(
        Invocation.method(
          #call,
          [id],
        ),
        returnValue: _i4.Future<_i7.Usuario?>.value(),
      ) as _i4.Future<_i7.Usuario?>);
}

/// A class which mocks [SalvarUsuario].
///
/// See the documentation for Mockito's code generation for more information.
class MockSalvarUsuario extends _i1.Mock implements _i9.SalvarUsuario {
  MockSalvarUsuario() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.IUsuariosRepository get usuariosRepository => (super.noSuchMethod(
        Invocation.getter(#usuariosRepository),
        returnValue: _FakeIUsuariosRepository_0(
          this,
          Invocation.getter(#usuariosRepository),
        ),
      ) as _i2.IUsuariosRepository);
}
