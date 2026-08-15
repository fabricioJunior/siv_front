import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'ecommerces_event.dart';
part 'ecommerces_state.dart';

class EcommercesBloc extends Bloc<EcommercesEvent, EcommercesState> {
  final RecuperarEcommerces _recuperarEcommerces;
  final ExcluirEcommerce _excluirEcommerce;
  final RestaurarEcommerce _restaurarEcommerce;

  EcommercesBloc(
    this._recuperarEcommerces,
    this._excluirEcommerce,
    this._restaurarEcommerce,
  ) : super(const EcommercesState()) {
    on<EcommercesCarregarSolicitado>(_onCarregarSolicitado);
    on<EcommercesExcluirSolicitado>(_onExcluirSolicitado);
    on<EcommercesRestaurarSolicitado>(_onRestaurarSolicitado);
  }

  FutureOr<void> _onCarregarSolicitado(
    EcommercesCarregarSolicitado event,
    Emitter<EcommercesState> emit,
  ) async {
    final incluirApagados =
        event.incluirApagados ?? state.incluirApagados;
    emit(
      state.copyWith(
        status: EcommercesStatus.carregando,
        incluirApagados: incluirApagados,
        erro: null,
      ),
    );
    try {
      final ecommerces = await _recuperarEcommerces(
        incluirApagados: incluirApagados,
      );
      emit(
        state.copyWith(
          status: EcommercesStatus.carregado,
          ecommerces: ecommerces,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: EcommercesStatus.erro,
          erro: 'Falha ao carregar os e-commerces.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onExcluirSolicitado(
    EcommercesExcluirSolicitado event,
    Emitter<EcommercesState> emit,
  ) async {
    try {
      await _excluirEcommerce(event.id);
      add(EcommercesCarregarSolicitado(incluirApagados: state.incluirApagados));
    } catch (e, s) {
      emit(state.copyWith(erro: 'Falha ao excluir o e-commerce.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onRestaurarSolicitado(
    EcommercesRestaurarSolicitado event,
    Emitter<EcommercesState> emit,
  ) async {
    try {
      await _restaurarEcommerce(event.id);
      add(EcommercesCarregarSolicitado(incluirApagados: state.incluirApagados));
    } catch (e, s) {
      emit(state.copyWith(erro: 'Falha ao restaurar o e-commerce.'));
      addError(e, s);
    }
  }
}
