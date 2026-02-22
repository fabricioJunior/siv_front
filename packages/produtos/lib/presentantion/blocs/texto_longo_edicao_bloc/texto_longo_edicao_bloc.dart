import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'texto_longo_edicao_event.dart';
part 'texto_longo_edicao_state.dart';

class TextoLongoEdicaoBloc
    extends Bloc<TextoLongoEdicaoEvent, TextoLongoEdicaoState> {
  TextoLongoEdicaoBloc() : super(const TextoLongoEdicaoState()) {
    on<TextoLongoEdicaoIniciou>(_onIniciou);
    on<TextoLongoEdicaoTextoAlterado>(_onTextoAlterado);
    on<TextoLongoEdicaoLimparSolicitado>(_onLimparSolicitado);
  }

  FutureOr<void> _onIniciou(
    TextoLongoEdicaoIniciou event,
    Emitter<TextoLongoEdicaoState> emit,
  ) async {
    emit(
      state.copyWith(
        titulo: event.titulo,
        hintText: event.hintText,
        texto: event.textoInicial,
      ),
    );
  }

  FutureOr<void> _onTextoAlterado(
    TextoLongoEdicaoTextoAlterado event,
    Emitter<TextoLongoEdicaoState> emit,
  ) async {
    emit(state.copyWith(texto: event.texto));
  }

  FutureOr<void> _onLimparSolicitado(
    TextoLongoEdicaoLimparSolicitado event,
    Emitter<TextoLongoEdicaoState> emit,
  ) async {
    emit(state.copyWith(texto: ''));
  }
}
