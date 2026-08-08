import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/use_cases.dart';

part 'promocoes_event.dart';
part 'promocoes_state.dart';

class PromocoesBloc extends Bloc<PromocoesEvent, PromocoesState> {
  final RecuperarPromocoes _recuperarPromocoes;

  PromocoesBloc(this._recuperarPromocoes) : super(const PromocoesInitial()) {
    on<PromocoesIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    PromocoesIniciou event,
    Emitter<PromocoesState> emit,
  ) async {
    try {
      emit(PromocoesCarregarEmProgresso(promocoes: state.promocoes));

      final promocoes = await _recuperarPromocoes.call(nome: event.busca);

      emit(PromocoesCarregarSucesso(promocoes: promocoes));
    } catch (e, s) {
      emit(PromocoesCarregarFalha(promocoes: state.promocoes));
      addError(e, s);
    }
  }
}
