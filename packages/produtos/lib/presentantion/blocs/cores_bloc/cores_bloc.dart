import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'cores_event.dart';
part 'cores_state.dart';

class CoresBloc extends Bloc<CoresEvent, CoresState> {
  final RecuperarCores _recuperarCores;
  final DesativarCor _desativarCor;

  CoresBloc(this._recuperarCores, this._desativarCor)
    : super(const CoresInitial()) {
    on<CoresIniciou>(_onCoresIniciou);
    on<CoresDesativar>(_onCoresDesativar);
  }

  FutureOr<void> _onCoresIniciou(
    CoresIniciou event,
    Emitter<CoresState> emit,
  ) async {
    try {
      emit(const CoresCarregarEmProgresso());
      var cores = await _recuperarCores.call(
        nome: event.busca,
        inativo: event.inativo,
      );
      emit(CoresCarregarSucesso(cores: cores.toList()));
    } catch (e, s) {
      emit(const CoresCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onCoresDesativar(
    CoresDesativar event,
    Emitter<CoresState> emit,
  ) async {
    try {
      emit(CoresDesativarEmProgresso(cores: state.cores));
      await _desativarCor.call(event.id);
      final coresFiltradas = state.cores
          .where((cor) => cor.id != event.id)
          .toList();
      emit(CoresDesativarSucesso(cores: coresFiltradas));
    } catch (e, s) {
      emit(CoresDesativarFalha(cores: state.cores));
      addError(e, s);
    }
  }
}
