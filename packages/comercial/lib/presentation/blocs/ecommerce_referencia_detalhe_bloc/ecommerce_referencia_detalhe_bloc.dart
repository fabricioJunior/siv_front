import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'ecommerce_referencia_detalhe_event.dart';
part 'ecommerce_referencia_detalhe_state.dart';

class EcommerceReferenciaDetalheBloc extends Bloc<
    EcommerceReferenciaDetalheEvent, EcommerceReferenciaDetalheState> {
  final RecuperarProdutosDaReferenciaEcommerce
      _recuperarProdutosDaReferenciaEcommerce;
  final AtualizarDisponibilidadeProdutoEcommerce
      _atualizarDisponibilidadeProdutoEcommerce;
  final AtualizarReferenciaEcommerce _atualizarReferenciaEcommerce;

  EcommerceReferenciaDetalheBloc(
    this._recuperarProdutosDaReferenciaEcommerce,
    this._atualizarDisponibilidadeProdutoEcommerce,
    this._atualizarReferenciaEcommerce,
  ) : super(
          const EcommerceReferenciaDetalheState(
            step: EcommerceReferenciaDetalheStep.inicial,
          ),
        ) {
    on<EcommerceReferenciaDetalheIniciou>(_onIniciou);
    on<EcommerceProdutoDisponibilidadeAlterou>(_onDisponibilidadeAlterou);
    on<EcommercePublicacaoAlterou>(_onPublicacaoAlterou);
  }

  FutureOr<void> _onIniciou(
    EcommerceReferenciaDetalheIniciou event,
    Emitter<EcommerceReferenciaDetalheState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          step: EcommerceReferenciaDetalheStep.carregando,
          ecommerceId: event.ecommerceId,
          referenciaEcommerceId: event.referenciaEcommerceId,
          referenciaId: event.referenciaId,
          rascunho: event.rascunho,
        ),
      );
      final produtos = await _recuperarProdutosDaReferenciaEcommerce.call(
        event.ecommerceId,
        event.referenciaEcommerceId,
      );
      emit(
        state.copyWith(
          produtos: produtos,
          step: EcommerceReferenciaDetalheStep.carregado,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceReferenciaDetalheStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar produtos.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onDisponibilidadeAlterou(
    EcommerceProdutoDisponibilidadeAlterou event,
    Emitter<EcommerceReferenciaDetalheState> emit,
  ) async {
    if (state.ecommerceId == null || state.referenciaEcommerceId == null) {
      return;
    }

    try {
      await _atualizarDisponibilidadeProdutoEcommerce.call(
        state.ecommerceId!,
        state.referenciaEcommerceId!,
        event.produtoId,
        disponivel: event.disponivel,
      );
      final produtos = state.produtos
          .map(
            (produto) => produto.produtoId == event.produtoId
                ? EcommerceReferenciaProduto.create(
                    id: produto.id,
                    ecommerceReferenciaId: produto.ecommerceReferenciaId,
                    produtoId: produto.produtoId,
                    disponivel: event.disponivel,
                    corNome: produto.corNome,
                    tamanhoNome: produto.tamanhoNome,
                  )
                : produto,
          )
          .toList();
      emit(
        state.copyWith(
          produtos: produtos,
          step: EcommerceReferenciaDetalheStep.atualizado,
          erro: '',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceReferenciaDetalheStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao atualizar disponibilidade.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onPublicacaoAlterou(
    EcommercePublicacaoAlterou event,
    Emitter<EcommerceReferenciaDetalheState> emit,
  ) async {
    if (state.ecommerceId == null || state.referenciaEcommerceId == null) {
      return;
    }

    try {
      await _atualizarReferenciaEcommerce.call(
        state.ecommerceId!,
        state.referenciaEcommerceId!,
        rascunho: event.rascunho,
      );
      emit(
        state.copyWith(
          rascunho: event.rascunho,
          step: EcommerceReferenciaDetalheStep.atualizado,
          erro: '',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceReferenciaDetalheStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao publicar referência.'),
        ),
      );
      addError(e, s);
    }
  }
}
