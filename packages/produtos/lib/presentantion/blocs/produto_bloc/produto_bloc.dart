import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'produto_event.dart';
part 'produto_state.dart';

class ProdutoBloc extends Bloc<ProdutoEvent, ProdutoState> {
  final RecuperarCores _recuperarCores;
  final RecuperarTamanhos _recuperarTamanhos;
  final CriarProduto _criarProduto;
  final AtualizarProduto _atualizarProduto;

  ProdutoBloc(
    this._recuperarCores,
    this._recuperarTamanhos,
    this._criarProduto,
    this._atualizarProduto,
  ) : super(const ProdutoState(produtoStep: ProdutoStep.inicial)) {
    on<ProdutoIniciou>(_onProdutoIniciou);
    on<ProdutoEditou>(_onProdutoEditou);
    on<ProdutoSalvou>(_onProdutoSalvou);
  }

  FutureOr<void> _onProdutoIniciou(
    ProdutoIniciou event,
    Emitter<ProdutoState> emit,
  ) async {
    try {
      emit(state.copyWith(produtoStep: ProdutoStep.carregando));

      final cores = await _recuperarCores.call(inativo: false);
      final tamanhos = await _recuperarTamanhos.call(inativo: false);

      final produto = event.produto;

      if (produto != null) {
        emit(
          ProdutoState.fromModel(
            produto,
            step: ProdutoStep.carregado,
            cores: cores,
            tamanhos: tamanhos,
          ),
        );
      } else {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.editando,
            id: null,
            referenciaId: null,
            idExterno: '',
            corId: null,
            tamanhoId: null,
            cores: cores,
            tamanhos: tamanhos,
            erroMensagem: null,
          ),
        );
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          produtoStep: ProdutoStep.falha,
          erroMensagem: 'Falha ao carregar cores e tamanhos.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onProdutoEditou(
    ProdutoEditou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        produtoStep: ProdutoStep.editando,
        referenciaId: event.referenciaId,
        idExterno: event.idExterno,
        corId: event.corId,
        tamanhoId: event.tamanhoId,
      ),
    );
  }

  FutureOr<void> _onProdutoSalvou(
    ProdutoSalvou event,
    Emitter<ProdutoState> emit,
  ) async {
    try {
      final referenciaId = state.referenciaId;
      final idExterno = state.idExterno.trim();
      final corId = state.corId;
      final tamanhoId = state.tamanhoId;

      if (referenciaId == null ||
          idExterno.isEmpty ||
          corId == null ||
          tamanhoId == null) {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.falha,
            erroMensagem: 'Preencha todos os campos obrigatórios.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(produtoStep: ProdutoStep.carregando, erroMensagem: null),
      );

      if (state.id == null) {
        final criado = await _criarProduto.call(
          referenciaId: referenciaId,
          idExterno: idExterno,
          corId: corId,
          tamanhoId: tamanhoId,
        );

        emit(
          ProdutoState.fromModel(
            criado,
            step: ProdutoStep.criado,
            cores: state.cores,
            tamanhos: state.tamanhos,
          ),
        );
      } else {
        final salvo = await _atualizarProduto.call(
          id: state.id!,
          referenciaId: referenciaId,
          idExterno: idExterno,
          corId: corId,
          tamanhoId: tamanhoId,
        );

        emit(
          ProdutoState.fromModel(
            salvo,
            step: ProdutoStep.salvo,
            cores: state.cores,
            tamanhos: state.tamanhos,
          ),
        );
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          produtoStep: ProdutoStep.falha,
          erroMensagem: 'Falha ao salvar produto.',
        ),
      );
      addError(e, s);
    }
  }
}
