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
  final CriarCategoriaDespesa _criarCategoria;
  final AtualizarCategoriaDespesa _atualizarCategoria;

  CategoriasDespesaBloc(
    this._recuperarCategorias,
    this._criarCategoria,
    this._atualizarCategoria,
  ) : super(const CategoriasDespesaInitial()) {
    on<CategoriasDespesaIniciou>(_onIniciou);
    on<CategoriasDespesaSalvou>(_onSalvou);
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

  FutureOr<void> _onSalvou(
    CategoriasDespesaSalvou event,
    Emitter<CategoriasDespesaState> emit,
  ) async {
    try {
      emit(CategoriasDespesaCarregarSucesso(categorias: state.categorias, salvando: true));

      final categoria = CategoriaDespesa(
        id: event.id,
        empresaId: event.empresaId,
        nome: event.nome,
        inativa: event.inativa,
      );

      if (event.id == null) {
        await _criarCategoria.call(categoria);
      } else {
        await _atualizarCategoria.call(categoria);
      }

      final categorias = await _recuperarCategorias.call(empresaId: event.empresaId);
      emit(CategoriasDespesaCarregarSucesso(categorias: categorias));
    } catch (e, s) {
      emit(CategoriasDespesaCarregarSucesso(categorias: state.categorias, erro: 'Falha ao salvar a categoria.'));
      addError(e, s);
    }
  }
}
