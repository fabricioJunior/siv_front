import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/use_cases.dart';

import '../../../domain/entities/empresa.dart';

part 'empresas_state.dart';
part 'empresas_event.dart';

class EmpresasBloc extends Bloc<EmpresasEvent, EmpresasState> {
  final RecuperarEmpresas _recuperarEmpresas;
  EmpresasBloc(
    this._recuperarEmpresas,
  ) : super(EmpresasNaoInicializado()) {
    on<EmpresasIniciou>(_empresasIniciou);
  }

  Future<void> _empresasIniciou(
    EmpresasIniciou event,
    Emitter<EmpresasState> emit,
  ) async {
    try {
      emit(EmpresasCarregarEmProgresso());
      var empresas = await _recuperarEmpresas.call();
      emit(EmpresasCarregarSucesso(empresas: empresas));
    } catch (e, s) {
      emit(EmpresasCarregarFalha());
      addError(e, s);
    }
  }
}
