import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/funcionario_vinculos_bloc/funcionario_vinculos_bloc.dart';
import 'package:pessoas/uses_cases.dart';

class _FakeRecuperarVinculosFuncionario
    implements RecuperarVinculosFuncionario {
  List<FuncionarioEmpresaVinculo> resposta = const [];
  Object? erro;

  @override
  Future<List<FuncionarioEmpresaVinculo>> call({
    required int idFuncionario,
  }) async {
    if (erro != null) throw erro!;
    return resposta;
  }
}

class _FakeVincularEmpresaFuncionario implements VincularEmpresaFuncionario {
  FuncionarioEmpresaVinculo Function(int idEmpresa)? resposta;
  Object? erro;

  @override
  Future<FuncionarioEmpresaVinculo> call({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    if (erro != null) throw erro!;
    return resposta!(idEmpresa);
  }
}

class _FakeDesativarVinculoFuncionario implements DesativarVinculoFuncionario {
  Object? erro;

  @override
  Future<void> call({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    if (erro != null) throw erro!;
  }
}

class _FakeReativarVinculoFuncionario implements ReativarVinculoFuncionario {
  Object? erro;

  @override
  Future<void> call({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    if (erro != null) throw erro!;
  }
}

void main() {
  const idFuncionario = 10;
  final vinculoAtivo = FuncionarioEmpresaVinculo(
    funcionarioId: idFuncionario,
    empresaId: 1,
    ativo: true,
  );

  late _FakeRecuperarVinculosFuncionario recuperarVinculos;
  late _FakeVincularEmpresaFuncionario vincularEmpresa;
  late _FakeDesativarVinculoFuncionario desativarVinculo;
  late _FakeReativarVinculoFuncionario reativarVinculo;

  FuncionarioVinculosBloc build() => FuncionarioVinculosBloc(
        recuperarVinculos,
        vincularEmpresa,
        desativarVinculo,
        reativarVinculo,
      );

  setUp(() {
    recuperarVinculos = _FakeRecuperarVinculosFuncionario();
    vincularEmpresa = _FakeVincularEmpresaFuncionario();
    desativarVinculo = _FakeDesativarVinculoFuncionario();
    reativarVinculo = _FakeReativarVinculoFuncionario();
  });

  blocTest<FuncionarioVinculosBloc, FuncionarioVinculosState>(
    'carrega os vínculos do funcionário',
    build: build,
    setUp: () => recuperarVinculos.resposta = [vinculoAtivo],
    act: (bloc) =>
        bloc.add(FuncionarioVinculosIniciou(idFuncionario: idFuncionario)),
    expect: () => [
      const FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregando,
        idFuncionario: idFuncionario,
      ),
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo],
      ),
    ],
  );

  blocTest<FuncionarioVinculosBloc, FuncionarioVinculosState>(
    'emite falha quando não consegue carregar os vínculos',
    build: build,
    setUp: () => recuperarVinculos.erro = Exception('falhou'),
    act: (bloc) =>
        bloc.add(FuncionarioVinculosIniciou(idFuncionario: idFuncionario)),
    expect: () => [
      const FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregando,
        idFuncionario: idFuncionario,
      ),
      const FuncionarioVinculosState(
        step: FuncionarioVinculosStep.falha,
        idFuncionario: idFuncionario,
        erro: 'Não foi possível carregar os vínculos do funcionário.',
      ),
    ],
  );

  blocTest<FuncionarioVinculosBloc, FuncionarioVinculosState>(
    'cria um novo vínculo com uma empresa',
    build: build,
    seed: () => FuncionarioVinculosState(
      step: FuncionarioVinculosStep.carregado,
      idFuncionario: idFuncionario,
      vinculos: [vinculoAtivo],
    ),
    setUp: () => vincularEmpresa.resposta = (idEmpresa) =>
        FuncionarioEmpresaVinculo(
          funcionarioId: idFuncionario,
          empresaId: idEmpresa,
          ativo: true,
        ),
    act: (bloc) =>
        bloc.add(FuncionarioVinculosEmpresaAdicionada(idEmpresa: 2)),
    expect: () => [
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo],
        processandoEmpresaId: 2,
      ),
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [
          vinculoAtivo,
          FuncionarioEmpresaVinculo(
            funcionarioId: idFuncionario,
            empresaId: 2,
            ativo: true,
          ),
        ],
      ),
    ],
  );

  blocTest<FuncionarioVinculosBloc, FuncionarioVinculosState>(
    'desativa um vínculo existente',
    build: build,
    seed: () => FuncionarioVinculosState(
      step: FuncionarioVinculosStep.carregado,
      idFuncionario: idFuncionario,
      vinculos: [vinculoAtivo],
    ),
    act: (bloc) => bloc.add(
      FuncionarioVinculosDesativarSolicitado(idEmpresa: vinculoAtivo.empresaId),
    ),
    expect: () => [
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo],
        processandoEmpresaId: vinculoAtivo.empresaId,
      ),
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo.copyWith(ativo: false)],
      ),
    ],
  );

  blocTest<FuncionarioVinculosBloc, FuncionarioVinculosState>(
    'reativa um vínculo desativado',
    build: build,
    seed: () => FuncionarioVinculosState(
      step: FuncionarioVinculosStep.carregado,
      idFuncionario: idFuncionario,
      vinculos: [vinculoAtivo.copyWith(ativo: false)],
    ),
    act: (bloc) => bloc.add(
      FuncionarioVinculosReativarSolicitado(idEmpresa: vinculoAtivo.empresaId),
    ),
    expect: () => [
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo.copyWith(ativo: false)],
        processandoEmpresaId: vinculoAtivo.empresaId,
      ),
      FuncionarioVinculosState(
        step: FuncionarioVinculosStep.carregado,
        idFuncionario: idFuncionario,
        vinculos: [vinculoAtivo],
      ),
    ],
  );
}
