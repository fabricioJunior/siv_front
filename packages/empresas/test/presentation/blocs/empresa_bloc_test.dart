import 'package:core/bloc_test.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresa_bloc/empresa_bloc.dart';
import 'package:empresas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/use_cases.mocks.dart';

final CriarEmpresa criarEmpresa = MockCriarEmpresa();
final RecuperarEmpresa recuperarEmpresa = MockRecuperarEmpresa();
final SalvarEmpresa salvarEmpresa = MockSalvarEmpresa();
late EmpresaBloc empresaBloc;

void main() {
  setUp(() {
    empresaBloc = EmpresaBloc(criarEmpresa, recuperarEmpresa, salvarEmpresa);
  });

  var empresa = fakeEmpresa();
  var empresa2 = empresa.copyWith(email: 'email 22');

  blocTest<EmpresaBloc, EmpresaState>(
    'emite estado de progresso quando inicia edição da empresa',
    build: () => empresaBloc,
    act: (bloc) => bloc.add(
      EmpresaEditou(),
    ),
    expect: () => [
      EmpresaEditarEmProgresso(),
    ],
  );
  blocTest<EmpresaBloc, EmpresaState>(
    'emite estado de progresso enquanto edita empresa',
    build: () => empresaBloc,
    seed: () => EmpresaEditarEmProgresso(),
    act: (bloc) => bloc.add(
      EmpresaEditou(
        email: empresa.email,
        inscricaoEstadual: empresa.inscricaoEstadual,
        cnpj: empresa.cnpj,
        codigoDeAtividade: empresa.codigoDeAtividade,
        codigoDeNaturezaJuridica: empresa.codigoDeNaturezaJuridica,
        telefone: empresa.telefone,
        uf: empresa.uf,
        registroMunicipal: empresa.registroMunicipal,
        nome: empresa.nome,
        nomeFantasia: empresa.nomeFantasia,
        regime: empresa.regime,
        substituicaoTributaria: empresa.substituicaoTributaria,
      ),
    ),
    expect: () => [
      EmpresaEditarEmProgresso.fromEmpresa(
        empresa,
      ),
    ],
  );
  blocTest<EmpresaBloc, EmpresaState>(
    'emite estado de sucesso ao salvar empresa',
    build: () => empresaBloc,
    seed: () => EmpresaEditarEmProgresso(
      email: empresa.email!,
      inscricaoEstadual: empresa.inscricaoEstadual!,
      cnpj: empresa.cnpj,
      codigoDeAtividade: empresa.codigoDeAtividade!,
      codigoDeNaturezaJuridica: empresa.codigoDeNaturezaJuridica!,
      telefone: empresa.telefone!,
      uf: empresa.uf!,
      registroMunicipal: empresa.registroMunicipal!,
      nome: empresa.nome,
      nomeFantasia: empresa.nomeFantasia,
      regime: empresa.regime!,
      substituicaoTributaria: empresa.substituicaoTributaria!,
    ),
    setUp: () {
      _setupCriarEmpresa(
        email: empresa.email!,
        inscricaoEstadual: empresa.inscricaoEstadual!,
        cnpj: empresa.cnpj,
        codigoDeAtividade: empresa.codigoDeAtividade!,
        codigoDeNaturezaJuridica: empresa.codigoDeNaturezaJuridica!,
        telefone: empresa.telefone!,
        uf: empresa.uf!,
        registroMunicipal: empresa.registroMunicipal!,
        nome: empresa.nome,
        nomeFantasia: empresa.nomeFantasia,
        regime: empresa.regime!,
        substituicaoTributaria: empresa.substituicaoTributaria!,
        response: empresa,
      );
    },
    act: (bloc) => bloc.add(EmpresaSalvou()),
    expect: () => [
      EmpresaSalvarEmProgresso(),
      EmpresaSalvarSucesso(empresa: empresa),
    ],
    verify: (bloc) {
      criarEmpresa.call(
        email: empresa.email!,
        inscricaoEstadual: empresa.inscricaoEstadual!,
        cnpj: empresa.cnpj,
        codigoDeAtividade: empresa.codigoDeAtividade!,
        codigoDeNaturezaJuridica: empresa.codigoDeNaturezaJuridica!,
        telefone: empresa.telefone!,
        uf: empresa.uf!,
        registroMunicipal: empresa.registroMunicipal!,
        nome: empresa.nome,
        nomeFantasia: empresa.nomeFantasia,
        regime: empresa.regime!,
        substituicaoTributaria: empresa.substituicaoTributaria!,
      );
    },
  );
  blocTest<EmpresaBloc, EmpresaState>(
    'emite estado apos carregar empresa',
    build: () => empresaBloc,
    setUp: () {
      _setupRecuperaEmpresa(empresa.id!, empresa);
    },
    act: (bloc) => bloc.add(EmpresaIniciou(idEmpresa: empresa.id!)),
    expect: () => [
      EmpresaCarregarEmProgresso(),
      EmpresaCarregarSucesso(empresa: empresa)
    ],
  );
  blocTest<EmpresaBloc, EmpresaState>(
    'emite estado apos salvar empresa',
    build: () => empresaBloc,
    seed: () => EmpresaEditarEmProgresso.fromEmpresa(empresa),
    setUp: () {
      _setupSalvarEmpresa(empresa, empresa2);
    },
    act: (bloc) => bloc.add(EmpresaSalvou()),
    expect: () => [
      EmpresaSalvarEmProgresso(),
      EmpresaSalvarSucesso(empresa: empresa2),
    ],
  );
}

void _setupCriarEmpresa({
  required String cnpj,
  required String codigoDeAtividade,
  required String codigoDeNaturezaJuridica,
  required String email,
  required String inscricaoEstadual,
  required String nome,
  required String nomeFantasia,
  required TipoRegimeEmpresa regime,
  required String registroMunicipal,
  required TipoDeSubstituicaoTributaria substituicaoTributaria,
  required String telefone,
  required String uf,
  required Empresa response,
}) {
  when(
    criarEmpresa.call(
      cnpj: cnpj,
      codigoDeAtividade: codigoDeAtividade,
      codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
      email: email,
      inscricaoEstadual: inscricaoEstadual,
      nome: nome,
      nomeFantasia: nomeFantasia,
      regime: regime,
      registroMunicipal: registroMunicipal,
      substituicaoTributaria: substituicaoTributaria,
      telefone: telefone,
      uf: uf,
    ),
  ).thenAnswer((_) async => response);
}

void _setupRecuperaEmpresa(int id, Empresa? response) {
  when(recuperarEmpresa.call(id)).thenAnswer((_) async => response);
}

void _setupSalvarEmpresa(Empresa empresa, Empresa response) {
  when(salvarEmpresa.call(empresa: empresa)).thenAnswer((_) async => response);
}
