import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'produtos_event.dart';
part 'produtos_state.dart';

class ProdutosBloc extends Bloc<ProdutosEvent, ProdutosState> {
  final RecuperarProdutos _recuperarProdutos;
  final ExcluirProduto _excluirProduto;

  ProdutosBloc(this._recuperarProdutos, this._excluirProduto)
    : super(const ProdutosInitial()) {
    on<ProdutosIniciou>(_onProdutosIniciou);
    on<ProdutosExcluiu>(_onProdutosExcluiu);
  }

  FutureOr<void> _onProdutosIniciou(
    ProdutosIniciou event,
    Emitter<ProdutosState> emit,
  ) async {
    try {
      emit(const ProdutosCarregarEmProgresso());
      final produtos = await _recuperarProdutos.call(
        idExterno: event.idExterno,
        referenciaId: event.referenciaId,
      );
      emit(ProdutosCarregarSucesso(produtos: produtos));
    } catch (e, s) {
      emit(const ProdutosCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onProdutosExcluiu(
    ProdutosExcluiu event,
    Emitter<ProdutosState> emit,
  ) async {
    try {
      emit(ProdutosExcluirEmProgresso(produtos: state.produtos));
      await _excluirProduto.call(event.id);
      final atualizados = state.produtos
          .where((produto) => produto.id != event.id)
          .toList();
      emit(ProdutosExcluirSucesso(produtos: atualizados));
    } catch (e, s) {
      emit(ProdutosExcluirFalha(produtos: state.produtos));
      addError(e, s);
    }
  }
}
