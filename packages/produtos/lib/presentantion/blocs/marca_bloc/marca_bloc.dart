import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'marca_state.dart';
part 'marca_event.dart';

class MarcaBloc extends Bloc<MarcaEvent, MarcaState> {
  final RecuperarMarca _recuperarMarca;
  final CriarMarca _criarMarca;
  final AtualizarMarca _atualizarMarca;

  MarcaBloc(this._recuperarMarca, this._criarMarca, this._atualizarMarca)
    : super(const MarcaState(marcaStep: MarcaStep.inicial)) {
    on<MarcaIniciou>(_onMarcaIniciou);
    on<MarcaEditou>(_onMarcaEditou);
    on<MarcaSalvou>(_onMarcaSalvou);
  }

  FutureOr<void> _onMarcaIniciou(
    MarcaIniciou event,
    Emitter<MarcaState> emit,
  ) async {
    try {
      emit(state.copyWith(marcaStep: MarcaStep.carregando));

      if (event.idMarca != null) {
        var marca = await _recuperarMarca.call(event.idMarca!);
        if (marca != null) {
          emit(MarcaState.fromModel(marca));
        } else {
          emit(state.copyWith(marcaStep: MarcaStep.falha));
        }
      } else {
        emit(const MarcaState(marcaStep: MarcaStep.editando, inativa: false));
      }
    } catch (e, s) {
      emit(state.copyWith(marcaStep: MarcaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onMarcaEditou(
    MarcaEditou event,
    Emitter<MarcaState> emit,
  ) async {
    emit(state.copyWith(marcaStep: MarcaStep.editando, nome: event.nome));
  }

  FutureOr<void> _onMarcaSalvou(
    MarcaSalvou event,
    Emitter<MarcaState> emit,
  ) async {
    try {
      emit(state.copyWith(marcaStep: MarcaStep.carregando));

      if (state.id != null) {
        var marca = await _atualizarMarca.call(state.id!, state.nome!);
        emit(MarcaState.fromModel(marca, step: MarcaStep.salvo));
      } else {
        var marca = await _criarMarca.call(state.nome!);
        emit(MarcaState.fromModel(marca, step: MarcaStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(marcaStep: MarcaStep.falha));
      addError(e, s);
    }
  }
}
