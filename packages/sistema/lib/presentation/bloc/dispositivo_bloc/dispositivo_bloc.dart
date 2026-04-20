import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:sistema/domain/models/info_dispositivo.dart';
import 'package:sistema/domain/usecases/apagar_dados_locais.dart';
import 'package:sistema/domain/usecases/recuperar_info_dispositivo.dart';

part 'dispositivo_event.dart';
part 'dispositivo_state.dart';

class DispositivoBloc extends Bloc<DispositivoEvent, DispositivoState> {
  final RecuperarInfoDispositivo recuperarInfo;
  final ApagarDadosLocais apagarDados;

  DispositivoBloc({
    required this.recuperarInfo,
    required this.apagarDados,
  }) : super(const DispositivoState(step: DispositivoStep.inicial)) {
    on<DispositivoIniciou>(_onIniciou);
    on<DispositivoApagarDadosSolicitado>(_onApagarDadosSolicitado);
  }

  FutureOr<void> _onIniciou(
    DispositivoIniciou event,
    Emitter<DispositivoState> emit,
  ) async {
    emit(state.copyWith(step: DispositivoStep.carregando));
    try {
      final info = await recuperarInfo.call();
      emit(state.copyWith(step: DispositivoStep.carregado, info: info));
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: DispositivoStep.falha));
    }
  }

  FutureOr<void> _onApagarDadosSolicitado(
    DispositivoApagarDadosSolicitado event,
    Emitter<DispositivoState> emit,
  ) async {
    emit(state.copyWith(step: DispositivoStep.apagando));
    try {
      await apagarDados.call();
      emit(state.copyWith(step: DispositivoStep.apagado, info: null));
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: DispositivoStep.falha));
    }
  }
}
