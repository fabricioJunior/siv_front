import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'romaneios_event.dart';
part 'romaneios_state.dart';

class RomaneiosBloc extends Bloc<RomaneiosEvent, RomaneiosState> {
  final RecuperarRomaneios _recuperarRomaneios;

  RomaneiosBloc(this._recuperarRomaneios)
      : super(const RomaneiosState.initial()) {
    on<RomaneiosIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    RomaneiosIniciou event,
    Emitter<RomaneiosState> emit,
  ) async {
    try {
      emit(state.copyWith(step: RomaneiosStep.carregando, erro: null));

      final romaneios = await _recuperarRomaneios.call(page: 1, limit: 100);

      emit(
        state.copyWith(
          romaneios: romaneios,
          step: RomaneiosStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneiosStep.falha, erro: 'Falha ao carregar romaneios.'));
      addError(e, s);
    }
  }
}
