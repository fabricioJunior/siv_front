part of 'empresa_parametros_bloc.dart';

abstract class EmpresaParametrosEvent {}

class EmpresaParametrosIniciou extends EmpresaParametrosEvent {
  final int empresaId;

  EmpresaParametrosIniciou(this.empresaId);
}

class EmpresaParametroTextoAlterado extends EmpresaParametrosEvent {
  final int parametroId;
  final String valor;

  EmpresaParametroTextoAlterado({
    required this.parametroId,
    required this.valor,
  });
}

class EmpresaParametroCheckboxAlterado extends EmpresaParametrosEvent {
  final int parametroId;
  final bool valor;

  EmpresaParametroCheckboxAlterado({
    required this.parametroId,
    required this.valor,
  });
}

class EmpresaParametrosSalvou extends EmpresaParametrosEvent {}
