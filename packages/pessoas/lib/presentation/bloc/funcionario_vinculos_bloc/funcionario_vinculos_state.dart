part of 'funcionario_vinculos_bloc.dart';

enum FuncionarioVinculosStep {
  inicial,
  carregando,
  carregado,
  falha,
}

class FuncionarioVinculosState extends Equatable {
  final FuncionarioVinculosStep step;
  final int? idFuncionario;
  final List<FuncionarioEmpresaVinculo> vinculos;
  final int? processandoEmpresaId;
  final String? erro;

  const FuncionarioVinculosState({
    required this.step,
    this.idFuncionario,
    this.vinculos = const [],
    this.processandoEmpresaId,
    this.erro,
  });

  FuncionarioVinculosState copyWith({
    FuncionarioVinculosStep? step,
    int? idFuncionario,
    List<FuncionarioEmpresaVinculo>? vinculos,
    int? processandoEmpresaId,
    bool limparProcessandoEmpresaId = false,
    String? erro,
    bool limparErro = false,
  }) {
    return FuncionarioVinculosState(
      step: step ?? this.step,
      idFuncionario: idFuncionario ?? this.idFuncionario,
      vinculos: vinculos ?? this.vinculos,
      processandoEmpresaId: limparProcessandoEmpresaId
          ? null
          : (processandoEmpresaId ?? this.processandoEmpresaId),
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }

  @override
  List<Object?> get props =>
      [step, idFuncionario, vinculos, processandoEmpresaId, erro];
}
