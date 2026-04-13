import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/use_cases.dart';

part 'terminais_event.dart';
part 'terminais_state.dart';

class TerminaisBloc extends Bloc<TerminaisEvent, TerminaisState> {
  final RecuperarTerminais _recuperarTerminais;
  final DesativarTerminal _desativarTerminal;

  TerminaisBloc(this._recuperarTerminais, this._desativarTerminal)
    : super(const TerminaisInitial()) {
    on<TerminaisIniciou>(_onTerminaisIniciou);
    on<TerminaisDesativar>(_onTerminaisDesativar);
  }

  FutureOr<void> _onTerminaisIniciou(
    TerminaisIniciou event,
    Emitter<TerminaisState> emit,
  ) async {
    try {
      emit(const TerminaisCarregarEmProgresso());
      final terminais = await _recuperarTerminais.call(
        empresaId: event.empresaId,
        nome: event.busca,
        inativo: event.inativo,
      );
      emit(TerminaisCarregarSucesso(terminais: terminais.toList()));
    } catch (e, s) {
      emit(const TerminaisCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onTerminaisDesativar(
    TerminaisDesativar event,
    Emitter<TerminaisState> emit,
  ) async {
    try {
      emit(TerminaisDesativarEmProgresso(terminais: state.terminais));
      await _desativarTerminal.call(empresaId: event.empresaId, id: event.id);
      final terminaisFiltrados = state.terminais
          .where((terminal) => terminal.id != event.id)
          .toList();
      emit(TerminaisDesativarSucesso(terminais: terminaisFiltrados));
    } catch (e, s) {
      emit(TerminaisDesativarFalha(terminais: state.terminais));
      addError(e, s);
    }
  }
}
