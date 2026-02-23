import 'package:autenticacao/models.dart';
import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/data/remote/dtos/vinculo_grupo_de_acesso_com_usuario.dart';
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

var vinculo1 = VinculoGrupoDeAcessoComUsuarioDto(
  grupoId: grupoDeAcesso.id!,
  grupo: grupoDeAcesso as GrupoDeAcessoDto,
  empresaId: 1,
  usuarioId: 1,
);
var vinculo2 = VinculoGrupoDeAcessoComUsuarioDto(
  grupoId: grupoDeAcesso2.id!,
  grupo: grupoDeAcesso2 as GrupoDeAcessoDto,
  empresaId: 2,
  usuarioId: 2,
);

var vinculos = [vinculo1, vinculo2];
var empresa1 = _EmpresaTest(id: 1, nome: 'Empresa 1');
var empresa2 = _EmpresaTest(id: 2, nome: 'Empresa 2');
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
        empresas: empresas,
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

class _EmpresaTest implements Empresa {
  @override
  final int id;

  @override
  final String nome;

  _EmpresaTest({required this.id, required this.nome});
}
