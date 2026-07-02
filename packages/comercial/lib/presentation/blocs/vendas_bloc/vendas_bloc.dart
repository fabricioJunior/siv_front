import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'vendas_event.dart';
part 'vendas_state.dart';

class VendasBloc extends Bloc<VendasEvent, VendasState> {
  final RecuperarRomaneios _recuperarRomaneios;

  VendasBloc(this._recuperarRomaneios) : super(const VendasState.initial()) {
    on<VendasIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    VendasIniciou event,
    Emitter<VendasState> emit,
  ) async {
    final searchTerm = (event.searchTerm ?? state.searchTerm).trim();
    final filtroBusca = searchTerm.isEmpty ? null : searchTerm;
    final caixaId = event.caixaIdInformado ? event.caixaId : state.caixaId;
    final dataHoraInicial = event.dataHoraInicialInformada
        ? event.dataHoraInicial
        : state.dataHoraInicial;
    final dataHoraFinal = event.dataHoraFinalInformada
        ? event.dataHoraFinal
        : state.dataHoraFinal;

    try {
      emit(
        state.copyWith(
          step: VendasStep.carregando,
          searchTerm: searchTerm,
          caixaId: caixaId,
          limparCaixaId: caixaId == null,
          dataHoraInicial: dataHoraInicial,
          limparDataHoraInicial: dataHoraInicial == null,
          dataHoraFinal: dataHoraFinal,
          limparDataHoraFinal: dataHoraFinal == null,
          erro: null,
        ),
      );

      final vendas = await _recuperarRomaneios.call(
        page: 1,
        limit: 50,
        searchTerm: filtroBusca,
        caixaId: caixaId,
        dataHoraInicial: dataHoraInicial,
        dataHoraFinal: dataHoraFinal,
        operacoes: const [TipoOperacao.venda],
      );

      emit(
        state.copyWith(
          vendas: vendas,
          searchTerm: searchTerm,
          step: VendasStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: VendasStep.falha,
          erro: 'Falha ao carregar vendas.',
        ),
      );
      addError(e, s);
    }
  }
}
