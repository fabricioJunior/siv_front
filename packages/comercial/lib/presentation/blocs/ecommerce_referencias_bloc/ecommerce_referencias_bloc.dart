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

  EcommerceReferenciasBloc(
    this._recuperarReferenciasEcommerce,
    this._adicionarReferenciaEcommerce,
  ) : super(const EcommerceReferenciasInitial()) {
    on<EcommerceReferenciasIniciou>(_onIniciou);
    on<EcommerceReferenciaAdicionou>(_onAdicionou);
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
}
