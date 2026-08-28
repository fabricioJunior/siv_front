import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'estampa_state.dart';
part 'estampa_event.dart';

class EstampaBloc extends Bloc<EstampaEvent, EstampaState> {
  final RecuperarEstampa _recuperarEstampa;
  final CriarEstampa _criarEstampa;
  final AtualizarEstampa _atualizarEstampa;

  EstampaBloc(
    this._recuperarEstampa,
    this._criarEstampa,
    this._atualizarEstampa,
  ) : super(const EstampaState(estampaStep: EstampaStep.inicial)) {
    on<EstampaIniciou>(_onEstampaIniciou);
    on<EstampaEditou>(_onEstampaEditou);
    on<EstampaSalvou>(_onEstampaSalvou);
  }

  FutureOr<void> _onEstampaIniciou(
    EstampaIniciou event,
    Emitter<EstampaState> emit,
  ) async {
    try {
      emit(state.copyWith(estampaStep: EstampaStep.carregando));

      if (event.idEstampa != null) {
        var estampa = await _recuperarEstampa.call(event.idEstampa!);
        if (estampa != null) {
          emit(EstampaState.fromModel(estampa));
        } else {
          emit(state.copyWith(estampaStep: EstampaStep.falha));
        }
      } else {
        emit(
          const EstampaState(estampaStep: EstampaStep.editando, inativo: false),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(estampaStep: EstampaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onEstampaEditou(
    EstampaEditou event,
    Emitter<EstampaState> emit,
  ) async {
    emit(state.copyWith(estampaStep: EstampaStep.editando, nome: event.nome));
  }

  FutureOr<void> _onEstampaSalvou(
    EstampaSalvou event,
    Emitter<EstampaState> emit,
  ) async {
    try {
      emit(state.copyWith(estampaStep: EstampaStep.carregando));

      if (state.id != null) {
        var estampa = await _atualizarEstampa.call(state.id!, state.nome!);
        emit(EstampaState.fromModel(estampa, step: EstampaStep.salvo));
      } else {
        var estampa = await _criarEstampa.call(state.nome!);
        emit(EstampaState.fromModel(estampa, step: EstampaStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(estampaStep: EstampaStep.falha));
      addError(e, s);
    }
  }
}
