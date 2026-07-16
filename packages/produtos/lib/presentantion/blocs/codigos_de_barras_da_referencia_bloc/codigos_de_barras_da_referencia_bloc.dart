import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/use_cases/recuperar_codigos_de_barras_da_referencia.dart';
import 'package:produtos/domain/use_cases/recuperar_produtos.dart';
import 'package:produtos/models.dart';

part 'codigos_de_barras_da_referencia_event.dart';
part 'codigos_de_barras_da_referencia_state.dart';

class CodigosDeBarrasDaReferenciaBloc extends Bloc<
    CodigosDeBarrasDaReferenciaEvent, CodigosDeBarrasDaReferenciaState> {
  final RecuperarCodigosDeBarrasDaReferencia _recuperarCodigos;
  final RecuperarProdutos _recuperarProdutos;

  CodigosDeBarrasDaReferenciaBloc(
    this._recuperarCodigos,
    this._recuperarProdutos,
  ) : super(const CodigosDeBarrasDaReferenciaState()) {
    on<CodigosDeBarrasDaReferenciaIniciou>(_onIniciou);
    on<CodigosDeBarrasDaReferenciaCarregarMaisSolicitado>(
      _onCarregarMaisSolicitado,
    );
  }

  Future<void> _onIniciou(
    CodigosDeBarrasDaReferenciaIniciou event,
    Emitter<CodigosDeBarrasDaReferenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        step: CodigosDeBarrasDaReferenciaStep.carregando,
        itens: const [],
        mapaProdutos: const {},
        referenciaId: event.referenciaId,
        page: 1,
        erro: null,
      ),
    );

    try {
      final produtosFuture = _recuperarProdutos.call(
        referenciaId: event.referenciaId,
      );
      final paginaFuture = _recuperarCodigos.call(
        referenciaId: event.referenciaId,
        page: 1,
      );

      final produtos = await produtosFuture;
      final pagina = await paginaFuture;

      final mapaProdutos = <int, Produto>{
        for (final produto in produtos)
          if (produto.id != null) produto.id!: produto,
      };

      emit(
        state.copyWith(
          step: CodigosDeBarrasDaReferenciaStep.carregado,
          itens: pagina.items,
          mapaProdutos: mapaProdutos,
          page: 1,
          totalPages: pagina.meta.totalPages,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: CodigosDeBarrasDaReferenciaStep.falha,
          erro: mensagemDeErroApi(
            e,
            'Erro ao carregar códigos de barras da referência.',
          ),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCarregarMaisSolicitado(
    CodigosDeBarrasDaReferenciaCarregarMaisSolicitado event,
    Emitter<CodigosDeBarrasDaReferenciaState> emit,
  ) async {
    if (state.step == CodigosDeBarrasDaReferenciaStep.carregandoMais) return;
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.page + 1;

    emit(
      state.copyWith(
        step: CodigosDeBarrasDaReferenciaStep.carregandoMais,
        erro: null,
      ),
    );

    try {
      final pagina = await _recuperarCodigos.call(
        referenciaId: state.referenciaId,
        page: proximaPagina,
      );

      emit(
        state.copyWith(
          step: CodigosDeBarrasDaReferenciaStep.carregado,
          itens: [...state.itens, ...pagina.items],
          page: proximaPagina,
          totalPages: pagina.meta.totalPages,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: CodigosDeBarrasDaReferenciaStep.carregado,
          erro: mensagemDeErroApi(
            e,
            'Erro ao carregar próxima página dos códigos de barras.',
          ),
        ),
      );
      addError(e, s);
    }
  }
}
