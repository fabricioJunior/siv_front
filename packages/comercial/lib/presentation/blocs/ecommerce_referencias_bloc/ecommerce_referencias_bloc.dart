import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'ecommerce_referencias_event.dart';
part 'ecommerce_referencias_state.dart';

class EcommerceReferenciasBloc
    extends Bloc<EcommerceReferenciasEvent, EcommerceReferenciasState> {
  final RecuperarReferenciasEcommerce _recuperarReferenciasEcommerce;
  final AdicionarReferenciaEcommerce _adicionarReferenciaEcommerce;
  final AtualizarReferenciaEcommerce _atualizarReferenciaEcommerce;

  EcommerceReferenciasBloc(
    this._recuperarReferenciasEcommerce,
    this._adicionarReferenciaEcommerce,
    this._atualizarReferenciaEcommerce,
  ) : super(const EcommerceReferenciasInitial()) {
    on<EcommerceReferenciasIniciou>(_onIniciou);
    on<EcommerceReferenciaAdicionou>(_onAdicionou);
    on<EcommerceReferenciaPublicarSolicitou>(_onPublicar);
    on<EcommerceReferenciasDespublicarTodasSolicitou>(_onDespublicarTodas);
    on<EcommerceReferenciasPublicarEmLoteSolicitou>(_onPublicarEmLote);
  }

  FutureOr<void> _onIniciou(
    EcommerceReferenciasIniciou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    try {
      emit(const EcommerceReferenciasCarregarEmProgresso());
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: event.busca,
        categoriaIds: event.categoriaIds,
        rascunho: event.rascunhoFiltro,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
          busca: event.busca,
          categoriaIds: event.categoriaIds,
          rascunhoFiltro: event.rascunhoFiltro,
        ),
      );
    } catch (e, s) {
      emit(const EcommerceReferenciasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onAdicionou(
    EcommerceReferenciaAdicionou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    try {
      await _adicionarReferenciaEcommerce.call(
        event.ecommerceId,
        referenciaId: event.referenciaId,
        tabelaDePrecoId: event.tabelaDePrecoId,
      );
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunho: state.rascunhoFiltro,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
        ),
      );
    } catch (e, s) {
      emit(
        EcommerceReferenciasAdicionarFalha(
          ecommerceId: event.ecommerceId,
          referencias: state.referencias,
        ),
      );
      addError(e, s);
    }
  }

  // Publica direto da lista (card), sem passar pela tela de detalhe -- mesmo
  // use case usado lá. Update otimista (R5): só troca o item no state local,
  // sem reload completo nem processandoLote global. Reverte se o PATCH falhar.
  FutureOr<void> _onPublicar(
    EcommerceReferenciaPublicarSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final referenciasOriginais = state.referencias;
    final index = referenciasOriginais
        .indexWhere((referencia) => referencia.id == event.referenciaEcommerceId);
    if (index == -1) return;

    final referenciasOtimistas =
        List<EcommerceReferencia>.from(referenciasOriginais);
    referenciasOtimistas[index] = _comRascunho(
      referenciasOtimistas[index],
      event.rascunho,
    );

    emit(
      EcommerceReferenciasCarregarSucesso(
        ecommerceId: event.ecommerceId,
        referencias: referenciasOtimistas,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunhoFiltro: state.rascunhoFiltro,
      ),
    );

    try {
      await _atualizarReferenciaEcommerce.call(
        event.ecommerceId,
        event.referenciaEcommerceId,
        rascunho: event.rascunho,
      );
    } catch (e, s) {
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referenciasOriginais,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onDespublicarTodas(
    EcommerceReferenciasDespublicarTodasSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final publicadas =
        state.referencias.where((referencia) => !referencia.rascunho);
    if (publicadas.isEmpty) return;

    emit(
      EcommerceReferenciasCarregarSucesso(
        ecommerceId: event.ecommerceId,
        referencias: state.referencias,
        processandoLote: true,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunhoFiltro: state.rascunhoFiltro,
      ),
    );

    try {
      // Sequencial, não Future.wait: um PUT por referência em paralelo tromba
      // no rate limiter da API (50 req/s por IP) quando o site tem muitas
      // referências publicadas.
      for (final referencia in publicadas) {
        await _atualizarReferenciaEcommerce.call(
          event.ecommerceId,
          referencia.id!,
          rascunho: true,
        );
      }
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunho: state.rascunhoFiltro,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
        ),
      );
    } catch (e, s) {
      emit(
        EcommerceReferenciasDespublicarTodasFalha(
          ecommerceId: event.ecommerceId,
          referencias: state.referencias,
        ),
      );
      addError(e, s);
    }
  }

  // Lote de verdade (R4): loop sequencial (mesmo motivo do
  // _onDespublicarTodas), acumula falhas sem abortar e só recarrega a lista
  // uma vez no fim.
  FutureOr<void> _onPublicarEmLote(
    EcommerceReferenciasPublicarEmLoteSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final ids = event.referenciaEcommerceIds;
    if (ids.isEmpty) return;

    var publicados = 0;
    var falharam = 0;

    for (var i = 0; i < ids.length; i++) {
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: state.referencias,
          processandoLote: true,
          loteAtual: i + 1,
          loteTotal: ids.length,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
        ),
      );
      try {
        await _atualizarReferenciaEcommerce.call(
          event.ecommerceId,
          ids[i],
          rascunho: event.rascunho,
        );
        publicados++;
      } catch (e, s) {
        falharam++;
        addError(e, s);
      }
    }

    try {
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunho: state.rascunhoFiltro,
      );
      emit(
        EcommerceReferenciasLoteConcluiu(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
          publicados: publicados,
          falharam: falharam,
        ),
      );
    } catch (e, s) {
      emit(const EcommerceReferenciasCarregarFalha());
      addError(e, s);
    }
  }

  EcommerceReferencia _comRascunho(EcommerceReferencia referencia, bool rascunho) {
    return EcommerceReferencia.create(
      id: referencia.id,
      ecommerceId: referencia.ecommerceId,
      referenciaId: referencia.referenciaId,
      tabelaDePrecoId: referencia.tabelaDePrecoId,
      rascunho: rascunho,
      referenciaNome: referencia.referenciaNome,
      valor: referencia.valor,
      descricao: referencia.descricao,
      unidadeMedida: referencia.unidadeMedida,
      imagemUrl: referencia.imagemUrl,
      saldo: referencia.saldo,
    );
  }
}
