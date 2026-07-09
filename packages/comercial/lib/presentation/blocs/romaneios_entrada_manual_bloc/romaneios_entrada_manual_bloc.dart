import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'romaneios_entrada_manual_event.dart';
part 'romaneios_entrada_manual_state.dart';

class RomaneiosEntradaManualBloc
    extends Bloc<RomaneiosEntradaManualEvent, RomaneiosEntradaManualState> {
  final RecuperarRomaneios _recuperarRomaneios;

  RomaneiosEntradaManualBloc(this._recuperarRomaneios)
      : super(const RomaneiosEntradaManualState.initial()) {
    on<RomaneiosEntradaManualIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    RomaneiosEntradaManualIniciou event,
    Emitter<RomaneiosEntradaManualState> emit,
  ) async {
    final searchTerm = (event.searchTerm ?? state.searchTerm).trim();
    final filtroBusca = searchTerm.isEmpty ? null : searchTerm;
    final dataHoraInicial = event.dataHoraInicialInformada
        ? event.dataHoraInicial
        : state.dataHoraInicial;
    final dataHoraFinal = event.dataHoraFinalInformada
        ? event.dataHoraFinal
        : state.dataHoraFinal;

    try {
      emit(
        state.copyWith(
          step: RomaneiosEntradaManualStep.carregando,
          searchTerm: searchTerm,
          dataHoraInicial: dataHoraInicial,
          limparDataHoraInicial: dataHoraInicial == null,
          dataHoraFinal: dataHoraFinal,
          limparDataHoraFinal: dataHoraFinal == null,
          erro: null,
        ),
      );

      final romaneios = await _recuperarRomaneios.call(
        page: 1,
        limit: 50,
        searchTerm: filtroBusca,
        dataHoraInicial: dataHoraInicial,
        dataHoraFinal: dataHoraFinal,
        operacoes: const [TipoOperacao.manual_entrada],
      );

      emit(
        state.copyWith(
          romaneios: romaneios,
          searchTerm: searchTerm,
          step: RomaneiosEntradaManualStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: RomaneiosEntradaManualStep.falha,
          erro: mensagemDeErroApi(
            e,
            'Falha ao carregar romaneios de entrada manual.',
          ),
        ),
      );
      addError(e, s);
    }
  }
}
