import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:precos/models.dart';
import 'package:precos/use_cases.dart';

part 'tabela_de_preco_event.dart';
part 'tabela_de_preco_state.dart';

class TabelaDePrecoBloc
    extends Bloc<TabelaDePrecoEvent, TabelaDePrecoState> {
  final RecuperarTabelaDePreco _recuperarTabelaDePreco;
  final CriarTabelaDePreco _criarTabelaDePreco;
  final AtualizarTabelaDePreco _atualizarTabelaDePreco;

  TabelaDePrecoBloc(
    this._recuperarTabelaDePreco,
    this._criarTabelaDePreco,
    this._atualizarTabelaDePreco,
  ) : super(const TabelaDePrecoState(tabelaDePrecoStep: TabelaDePrecoStep.inicial)) {
    on<TabelaDePrecoIniciou>(_onTabelaDePrecoIniciou);
    on<TabelaDePrecoEditou>(_onTabelaDePrecoEditou);
    on<TabelaDePreceSalvou>(_onTabelaDePreceSalvou);
  }

  FutureOr<void> _onTabelaDePrecoIniciou(
    TabelaDePrecoIniciou event,
    Emitter<TabelaDePrecoState> emit,
  ) async {
    try {
      emit(state.copyWith(tabelaDePrecoStep: TabelaDePrecoStep.carregando));

      if (event.idTabelaDePreco != null) {
        final tabela = await _recuperarTabelaDePreco.call(
          event.idTabelaDePreco!,
        );
        if (tabela != null) {
          emit(TabelaDePrecoState.fromModel(tabela));
        } else {
          emit(state.copyWith(tabelaDePrecoStep: TabelaDePrecoStep.falha));
        }
      } else {
        emit(
          const TabelaDePrecoState(
            tabelaDePrecoStep: TabelaDePrecoStep.editando,
            inativa: false,
          ),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(tabelaDePrecoStep: TabelaDePrecoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onTabelaDePrecoEditou(
    TabelaDePrecoEditou event,
    Emitter<TabelaDePrecoState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoStep: TabelaDePrecoStep.editando,
        nome: event.nome,
        terminador: event.terminador,
      ),
    );
  }

  FutureOr<void> _onTabelaDePreceSalvou(
    TabelaDePreceSalvou event,
    Emitter<TabelaDePrecoState> emit,
  ) async {
    try {
      emit(state.copyWith(tabelaDePrecoStep: TabelaDePrecoStep.carregando));

      if (state.id != null) {
        final tabela = await _atualizarTabelaDePreco.call(
          id: state.id!,
          nome: state.nome!,
          terminador: state.terminador,
        );
        emit(TabelaDePrecoState.fromModel(tabela, step: TabelaDePrecoStep.salvo));
      } else {
        final tabela = await _criarTabelaDePreco.call(
          nome: state.nome!,
          terminador: state.terminador,
        );
        emit(TabelaDePrecoState.fromModel(tabela, step: TabelaDePrecoStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(tabelaDePrecoStep: TabelaDePrecoStep.falha));
      addError(e, s);
    }
  }
}
