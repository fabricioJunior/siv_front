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
  }

  FutureOr<void> _onIniciou(
    EcommerceReferenciasIniciou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    try {
      emit(const EcommerceReferenciasCarregarEmProgresso());
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
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
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
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

  // Publica direto da lista (card), sem passar pela tela de detalhe -- mesmo use case usado lá.
  FutureOr<void> _onPublicar(
    EcommerceReferenciaPublicarSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    emit(
      EcommerceReferenciasCarregarSucesso(
        ecommerceId: event.ecommerceId,
        referencias: state.referencias,
        processandoLote: true,
      ),
    );

    try {
      await _atualizarReferenciaEcommerce.call(
        event.ecommerceId,
        event.referenciaEcommerceId,
        rascunho: false,
      );
      final referencias = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
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
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: referencias,
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
}
