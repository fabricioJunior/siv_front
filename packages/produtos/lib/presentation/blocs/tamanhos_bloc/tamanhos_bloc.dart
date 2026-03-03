import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'tamanhos_event.dart';
part 'tamanhos_state.dart';

class TamanhosBloc extends Bloc<TamanhosEvent, TamanhosState> {
  final RecuperarTamanhos _recuperarTamanhos;
  final DesativarTamanho _desativarTamanho;

  TamanhosBloc(this._recuperarTamanhos, this._desativarTamanho)
    : super(const TamanhosInitial()) {
    on<TamanhosIniciou>(_onTamanhosIniciou);
    on<TamanhosDesativar>(_onTamanhosDesativar);
  }

  FutureOr<void> _onTamanhosIniciou(
    TamanhosIniciou event,
    Emitter<TamanhosState> emit,
  ) async {
    try {
      emit(const TamanhosCarregarEmProgresso());
      var tamanhos = await _recuperarTamanhos.call(
        nome: event.busca,
        inativo: event.inativo,
      );
      emit(TamanhosCarregarSucesso(tamanhos: tamanhos.toList()));
    } catch (e, s) {
      emit(const TamanhosCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onTamanhosDesativar(
    TamanhosDesativar event,
    Emitter<TamanhosState> emit,
  ) async {
    try {
      emit(TamanhosDesativarEmProgresso(tamanhos: state.tamanhos));
      await _desativarTamanho.call(event.id);
      final tamanhosFiltrados = state.tamanhos
          .where((tamanho) => tamanho.id != event.id)
          .toList();
      emit(TamanhosDesativarSucesso(tamanhos: tamanhosFiltrados));
    } catch (e, s) {
      emit(TamanhosDesativarFalha(tamanhos: state.tamanhos));
      addError(e, s);
    }
  }
}
