import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'estampas_event.dart';
part 'estampas_state.dart';

class EstampasBloc extends Bloc<EstampasEvent, EstampasState> {
  final RecuperarEstampas _recuperarEstampas;
  final DesativarEstampa _desativarEstampa;

  EstampasBloc(this._recuperarEstampas, this._desativarEstampa)
    : super(const EstampasInitial()) {
    on<EstampasIniciou>(_onEstampasIniciou);
    on<EstampasDesativar>(_onEstampasDesativar);
  }

  FutureOr<void> _onEstampasIniciou(
    EstampasIniciou event,
    Emitter<EstampasState> emit,
  ) async {
    try {
      emit(const EstampasCarregarEmProgresso());
      var estampas = await _recuperarEstampas.call(
        nome: event.busca,
        inativo: event.inativo,
      );
      emit(EstampasCarregarSucesso(estampas: estampas.toList()));
    } catch (e, s) {
      emit(const EstampasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onEstampasDesativar(
    EstampasDesativar event,
    Emitter<EstampasState> emit,
  ) async {
    try {
      emit(EstampasDesativarEmProgresso(estampas: state.estampas));
      await _desativarEstampa.call(event.id);
      final estampasFiltradas = state.estampas
          .where((estampa) => estampa.id != event.id)
          .toList();
      emit(EstampasDesativarSucesso(estampas: estampasFiltradas));
    } catch (e, s) {
      emit(EstampasDesativarFalha(estampas: state.estampas));
      addError(e, s);
    }
  }
}
