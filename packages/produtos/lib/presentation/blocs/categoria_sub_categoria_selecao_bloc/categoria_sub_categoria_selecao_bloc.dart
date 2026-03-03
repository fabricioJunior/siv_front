import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'categoria_sub_categoria_selecao_event.dart';
part 'categoria_sub_categoria_selecao_state.dart';

class CategoriaSubCategoriaSelecaoBloc
    extends
        Bloc<
          CategoriaSubCategoriaSelecaoEvent,
          CategoriaSubCategoriaSelecaoState
        > {
  final RecuperarCategorias _recuperarCategorias;
  final RecuperarSubCategorias _recuperarSubCategorias;

  CategoriaSubCategoriaSelecaoBloc(
    this._recuperarCategorias,
    this._recuperarSubCategorias,
  ) : super(const CategoriaSubCategoriaSelecaoState()) {
    on<CategoriaSubCategoriaSelecaoIniciou>(_onIniciou);
    on<CategoriaSubCategoriaCategoriaSelecionada>(_onCategoriaSelecionada);
    on<CategoriaSubCategoriaSubCategoriaSelecionada>(
      _onSubCategoriaSelecionada,
    );
    on<CategoriaSubCategoriaEtapaAvancou>(_onEtapaAvancou);
    on<CategoriaSubCategoriaEtapaVoltou>(_onEtapaVoltou);
  }

  FutureOr<void> _onIniciou(
    CategoriaSubCategoriaSelecaoIniciou event,
    Emitter<CategoriaSubCategoriaSelecaoState> emit,
  ) async {
    try {
      emit(state.copyWith(carregandoCategorias: true, mensagem: null));

      final categorias = await _recuperarCategorias.call(inativa: false);
      categorias.sort((a, b) => a.nome.compareTo(b.nome));

      if (categorias.isEmpty) {
        emit(
          state.copyWith(
            carregandoCategorias: false,
            categorias: categorias,
            categoriaSelecionada: null,
            subCategorias: const [],
            subCategoriaSelecionada: null,
            mensagem: 'Nenhuma categoria disponível.',
          ),
        );
        return;
      }

      Categoria categoriaSelecionada = _selecionarCategoriaInicial(
        categorias,
        event.categoriaAtualId,
      );

      emit(
        state.copyWith(
          carregandoCategorias: false,
          categorias: categorias,
          categoriaSelecionada: categoriaSelecionada,
          subCategoriaSelecionada: null,
          step: CategoriaSubCategoriaSelecaoStep.categoria,
          mensagem: null,
        ),
      );

      await _carregarSubCategorias(
        emit: emit,
        categoria: categoriaSelecionada,
        subCategoriaAtualId: event.subCategoriaAtualId,
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoCategorias: false,
          carregandoSubCategorias: false,
          mensagem: 'Falha ao carregar categorias e sub-categorias.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onCategoriaSelecionada(
    CategoriaSubCategoriaCategoriaSelecionada event,
    Emitter<CategoriaSubCategoriaSelecaoState> emit,
  ) async {
    emit(
      state.copyWith(
        categoriaSelecionada: event.categoria,
        subCategoriaSelecionada: null,
        step: CategoriaSubCategoriaSelecaoStep.categoria,
        mensagem: null,
      ),
    );

    await _carregarSubCategorias(emit: emit, categoria: event.categoria);
  }

  FutureOr<void> _onSubCategoriaSelecionada(
    CategoriaSubCategoriaSubCategoriaSelecionada event,
    Emitter<CategoriaSubCategoriaSelecaoState> emit,
  ) async {
    emit(state.copyWith(subCategoriaSelecionada: event.subCategoria));
  }

  FutureOr<void> _onEtapaAvancou(
    CategoriaSubCategoriaEtapaAvancou event,
    Emitter<CategoriaSubCategoriaSelecaoState> emit,
  ) async {
    if (state.subCategorias.isEmpty) {
      return;
    }

    emit(state.copyWith(step: CategoriaSubCategoriaSelecaoStep.subCategoria));
  }

  FutureOr<void> _onEtapaVoltou(
    CategoriaSubCategoriaEtapaVoltou event,
    Emitter<CategoriaSubCategoriaSelecaoState> emit,
  ) async {
    emit(state.copyWith(step: CategoriaSubCategoriaSelecaoStep.categoria));
  }

  Future<void> _carregarSubCategorias({
    required Emitter<CategoriaSubCategoriaSelecaoState> emit,
    required Categoria categoria,
    int? subCategoriaAtualId,
  }) async {
    final categoriaId = categoria.id;
    if (categoriaId == null) {
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          subCategorias: const [],
          subCategoriaSelecionada: null,
          mensagem: 'Categoria inválida.',
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          carregandoSubCategorias: true,
          subCategorias: const [],
          subCategoriaSelecionada: null,
          mensagem: null,
        ),
      );

      final subCategorias = await _recuperarSubCategorias.call(
        categoriaId,
        inativa: false,
      );
      subCategorias.sort((a, b) => a.nome.compareTo(b.nome));

      SubCategoria? subCategoriaSelecionada;
      if (subCategoriaAtualId != null) {
        for (final subCategoria in subCategorias) {
          if (subCategoria.id == subCategoriaAtualId) {
            subCategoriaSelecionada = subCategoria;
            break;
          }
        }
      }

      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          subCategorias: subCategorias,
          subCategoriaSelecionada: subCategoriaSelecionada,
          mensagem: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          mensagem: 'Falha ao carregar sub-categorias.',
        ),
      );
      addError(e, s);
    }
  }

  Categoria _selecionarCategoriaInicial(
    List<Categoria> categorias,
    int? categoriaAtualId,
  ) {
    if (categoriaAtualId != null) {
      for (final categoria in categorias) {
        if (categoria.id == categoriaAtualId) {
          return categoria;
        }
      }
    }

    return categorias.first;
  }
}
