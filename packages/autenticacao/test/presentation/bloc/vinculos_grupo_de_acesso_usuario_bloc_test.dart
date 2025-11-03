import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/vinculos_grupo_de_acesso_usuario_bloc/vinculos_grupo_de_acesso_usuario_bloc.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

final VincularUsuarioAoGrupoDeAcesso vincularUsuarioAoGrupoDeAcesso =
    MockVincularUsuarioAoGrupoDeAcesso();

final RecuperarVinculosGrupoDeAcessoDoUsuario
    recuperarVinculosGrupoDeAcessoDoUsuario =
    MockRecuperarVinculosGrupoDeAcessoDoUsuario();

final RecuperarEmpresas recuperarEmpresas = MockRecuperarEmpresas();
late VinculosGrupoDeAcessoUsuarioBloc bloc;

int idUsuario = 1;
var grupoDeAcesso = fakeGrupoDeAcesso(id: 1);
var grupoDeAcesso2 = fakeGrupoDeAcesso(id: 2);

var vinculo1 = fakeVinculoGrupoDeAcessoEUsuario(
  idUsuario: 1,
  grupoDeAcesso: grupoDeAcesso,
);
var vinculo2 = fakeVinculoGrupoDeAcessoEUsuario(
  idUsuario: 2,
  grupoDeAcesso: grupoDeAcesso2,
);

var vinculos = [vinculo1, vinculo2];
var empresa1 = fakeEmpresa(id: 1);
var empresa2 = fakeEmpresa(
  id: 2,
);
var empresas = [empresa1, empresa2];
void main() {
  setUp(() {
    _setupEmpresas();
    bloc = VinculosGrupoDeAcessoUsuarioBloc(
      recuperarVinculosGrupoDeAcessoDoUsuario,
      recuperarEmpresas,
      vincularUsuarioAoGrupoDeAcesso,
    );
  });

  blocTest<VinculosGrupoDeAcessoUsuarioBloc, VinculosGrupoDeAcessoUsuarioState>(
    'emite estado de sucesso após carregar vinculos do usuário',
    build: () => bloc,
    setUp: () {
      _setupRecuperarVinculosGrupoDeAcessoDoUsuarioSucesso(
        idUsuario: idUsuario,
        retorno: vinculos,
      );
    },
    act: (bloc) => bloc.add(
      VinculosGrupoDeAcessoIniciou(idUsuario: idUsuario),
    ),
    expect: () => [
      VinculosGrupoDeAcessoUsuarioCarregarEmProgresso(
        idUsuario: idUsuario,
      ),
      VinculosGrupoDeAcessoUsuarioCarregarSucesso(
        vinculos: vinculos,
        idUsuario: idUsuario,
        empresas: empresas,
      ),
    ],
  );
  blocTest<VinculosGrupoDeAcessoUsuarioBloc, VinculosGrupoDeAcessoUsuarioState>(
    'emite estado de sucesso após vincular o usuário a um grupo de acesso',
    build: () => bloc,
    seed: () => VinculosGrupoDeAcessoUsuarioCarregarSucesso(
      vinculos: vinculos,
      idUsuario: idUsuario,
      empresas: empresas,
    ),
    setUp: () {
      _setupRecuperarVinculosGrupoDeAcessoDoUsuarioSucesso(
        idUsuario: idUsuario,
        retorno: vinculos,
      );
      _setupVincularUsuarioAoGrupoDeAcessoSucesso(
          idEmpresa: empresa1.id,
          idGrupoDeAcesso: vinculo1.grupoDeAcesso!.id!,
          idUser: idUsuario,
          retorno: vinculo1);
    },
    act: (bloc) => bloc.add(
      VinculosGrupoDeAcessoVinculou(
        idGrupoDeAcesso: vinculo1.grupoDeAcesso!.id!,
        idEmpresa: empresa1.id,
      ),
    ),
    expect: () => [
      VinculosGrupoDeAcessoUsuarioVincularEmProgresso(
        idUsuario: idUsuario,
      ),
      VinculosGrupoDeAcessoUsuarioVincularSucesso(
        vinculos: vinculos,
        idUsuario: idUsuario,
      ),
    ],
  );
}

void _setupRecuperarVinculosGrupoDeAcessoDoUsuarioSucesso({
  required int idUsuario,
  required List<VinculoGrupoDeAcessoEUsuario> retorno,
}) {
  when(recuperarVinculosGrupoDeAcessoDoUsuario.call(
    idUsuario: idUsuario,
  )).thenAnswer((_) async => retorno);
}

void _setupVincularUsuarioAoGrupoDeAcessoSucesso({
  required int idUser,
  required int idGrupoDeAcesso,
  required int idEmpresa,
  required VinculoGrupoDeAcessoEUsuario retorno,
}) {
  when(vincularUsuarioAoGrupoDeAcesso.call(
    idUsuario: idUser,
    idGrupoDeAcesso: idGrupoDeAcesso,
    idEmpresa: idEmpresa,
  )).thenAnswer((_) async => retorno);
}

void _setupEmpresas() {
  when(recuperarEmpresas.call()).thenAnswer((_) async => empresas);
}
