import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:precos/models.dart';
import 'package:precos/use_cases.dart';

part 'tabelas_de_preco_event.dart';
part 'tabelas_de_preco_state.dart';

class TabelasDePrecoBloc
    extends Bloc<TabelasDePrecoEvent, TabelasDePrecoState> {
  final RecuperarTabelasDePreco _recuperarTabelasDePreco;
  final DesativarTabelaDePreco _desativarTabelaDePreco;

  TabelasDePrecoBloc(
    this._recuperarTabelasDePreco,
    this._desativarTabelaDePreco,
  ) : super(const TabelasDePrecoInitial()) {
    on<TabelasDePrecoIniciou>(_onTabelasDePrecoIniciou);
    on<TabelasDePrecoDesativar>(_onTabelasDePrecoDesativar);
  }

  FutureOr<void> _onTabelasDePrecoIniciou(
    TabelasDePrecoIniciou event,
    Emitter<TabelasDePrecoState> emit,
  ) async {
    try {
      emit(const TabelasDePrecoCarregarEmProgresso());
      final tabelas = await _recuperarTabelasDePreco.call(
        nome: event.busca,
        inativa: event.inativa,
      );
      emit(TabelasDePrecoCarregarSucesso(tabelas: tabelas.toList()));
    } catch (e, s) {
      emit(const TabelasDePrecoCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onTabelasDePrecoDesativar(
    TabelasDePrecoDesativar event,
    Emitter<TabelasDePrecoState> emit,
  ) async {
    try {
      emit(TabelasDePrecoDesativarEmProgresso(tabelas: state.tabelas));
      await _desativarTabelaDePreco.call(event.id);
      final tabelasFiltradas = state.tabelas
          .where((t) => t.id != event.id)
          .toList();
      emit(TabelasDePrecoDesativarSucesso(tabelas: tabelasFiltradas));
    } catch (e, s) {
      emit(TabelasDePrecoDesativarFalha(tabelas: state.tabelas));
      addError(e, s);
    }
  }
}
