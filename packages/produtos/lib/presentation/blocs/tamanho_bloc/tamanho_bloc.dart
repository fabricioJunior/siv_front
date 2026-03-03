import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'tamanho_state.dart';
part 'tamanho_event.dart';

class TamanhoBloc extends Bloc<TamanhoEvent, TamanhoState> {
  final RecuperarTamanho _recuperarTamanho;
  final CriarTamanho _criarTamanho;
  final AtualizarTamanho _atualizarTamanho;

  TamanhoBloc(
    this._recuperarTamanho,
    this._criarTamanho,
    this._atualizarTamanho,
  ) : super(const TamanhoState(tamanhoStep: TamanhoStep.inicial)) {
    on<TamanhoIniciou>(_onTamanhoIniciou);
    on<TamanhoEditou>(_onTamanhoEditou);
    on<TamanhoSalvou>(_onTamanhoSalvou);
  }

  FutureOr<void> _onTamanhoIniciou(
    TamanhoIniciou event,
    Emitter<TamanhoState> emit,
  ) async {
    try {
      emit(state.copyWith(tamanhoStep: TamanhoStep.carregando));

      if (event.idTamanho != null) {
        var tamanho = await _recuperarTamanho.call(event.idTamanho!);
        if (tamanho != null) {
          emit(TamanhoState.fromModel(tamanho));
        } else {
          emit(state.copyWith(tamanhoStep: TamanhoStep.falha));
        }
      } else {
        emit(
          const TamanhoState(tamanhoStep: TamanhoStep.editando, inativo: false),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(tamanhoStep: TamanhoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onTamanhoEditou(
    TamanhoEditou event,
    Emitter<TamanhoState> emit,
  ) async {
    emit(state.copyWith(tamanhoStep: TamanhoStep.editando, nome: event.nome));
  }

  FutureOr<void> _onTamanhoSalvou(
    TamanhoSalvou event,
    Emitter<TamanhoState> emit,
  ) async {
    try {
      emit(state.copyWith(tamanhoStep: TamanhoStep.carregando));

      if (state.id != null) {
        var tamanho = await _atualizarTamanho.call(state.id!, state.nome!);
        emit(TamanhoState.fromModel(tamanho, step: TamanhoStep.salvo));
      } else {
        var tamanho = await _criarTamanho.call(state.nome!);
        emit(TamanhoState.fromModel(tamanho, step: TamanhoStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(tamanhoStep: TamanhoStep.falha));
      addError(e, s);
    }
  }
}
