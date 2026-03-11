part of 'empresa_parametros_bloc.dart';

class EmpresaParametrosState extends Equatable {
  final int? empresaId;
  final List<EmpresaParametro> parametros;
  final List<EmpresaParametro> parametrosOriginais;
  final String? descricaoParametroInvalido;
  final EmpresaParametrosStep step;

  const EmpresaParametrosState({
    this.empresaId,
    this.parametros = const [],
    this.parametrosOriginais = const [],
    this.descricaoParametroInvalido,
    required this.step,
  });

  EmpresaParametrosState copyWith({
    int? empresaId,
    List<EmpresaParametro>? parametros,
    List<EmpresaParametro>? parametrosOriginais,
    String? descricaoParametroInvalido,
    EmpresaParametrosStep? step,
  }) {
    return EmpresaParametrosState(
      empresaId: empresaId ?? this.empresaId,
      parametros: parametros ?? this.parametros,
      parametrosOriginais: parametrosOriginais ?? this.parametrosOriginais,
      descricaoParametroInvalido:
          descricaoParametroInvalido ?? this.descricaoParametroInvalido,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        parametros,
        parametrosOriginais,
        descricaoParametroInvalido,
        step,
      ];
}

enum EmpresaParametrosStep {
  inicial,
  carregando,
  carregado,
  editando,
  validacaoInvalida,
  salvando,
  salvo,
  falha,
}
