import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'categorias_despesa_event.dart';
part 'categorias_despesa_state.dart';

class CategoriasDespesaBloc
    extends Bloc<CategoriasDespesaEvent, CategoriasDespesaState> {
  final RecuperarCategoriasDespesa _recuperarCategorias;

  CategoriasDespesaBloc(this._recuperarCategorias)
      : super(const CategoriasDespesaInitial()) {
    on<CategoriasDespesaIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    CategoriasDespesaIniciou event,
    Emitter<CategoriasDespesaState> emit,
  ) async {
    try {
      emit(CategoriasDespesaCarregarEmProgresso(categorias: state.categorias));

      final categorias = await _recuperarCategorias.call(
        empresaId: event.empresaId,
        filtro: event.busca,
      );

      emit(CategoriasDespesaCarregarSucesso(categorias: categorias));
    } catch (e, s) {
      emit(CategoriasDespesaCarregarFalha(categorias: state.categorias));
      addError(e, s);
    }
  }
}
