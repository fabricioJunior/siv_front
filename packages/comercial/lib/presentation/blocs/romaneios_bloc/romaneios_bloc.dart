import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';

part 'romaneios_event.dart';
part 'romaneios_state.dart';

class RomaneiosBloc extends Bloc<RomaneiosEvent, RomaneiosState> {
  final RecuperarRomaneios _recuperarRomaneios;
  final RecuperarListaDeProdutosCompartilhada
      _recuperarListaDeProdutosCompartilhada;

  RomaneiosBloc(
    this._recuperarRomaneios,
    this._recuperarListaDeProdutosCompartilhada,
  ) : super(const RomaneiosState.initial()) {
    on<RomaneiosIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    RomaneiosIniciou event,
    Emitter<RomaneiosState> emit,
  ) async {
    final searchTerm = (event.searchTerm ?? state.searchTerm).trim();
    final filtroBusca = searchTerm.isEmpty ? null : searchTerm;

    try {
      emit(
        state.copyWith(
          step: RomaneiosStep.carregando,
          searchTerm: searchTerm,
          erro: null,
        ),
      );

      final romaneios = await _recuperarRomaneios.call(
        page: 1,
        limit: 50,
        searchTerm: filtroBusca,
      );
      final itensPendentesPorRomaneio =
          await _recuperarPendenciasDeEnvio(romaneios);

      emit(
        state.copyWith(
          romaneios: romaneios,
          itensPendentesPorRomaneio: itensPendentesPorRomaneio,
          searchTerm: searchTerm,
          step: RomaneiosStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneiosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar romaneios.')));
      addError(e, s);
    }
  }

  Future<Map<int, int>> _recuperarPendenciasDeEnvio(
    List<Romaneio> romaneios,
  ) async {
    final pendencias = <int, int>{};

    for (final romaneio in romaneios) {
      final romaneioId = romaneio.id;
      if (romaneioId == null) {
        continue;
      }

      try {
        final listas = await _recuperarListaDeProdutosCompartilhada
            .recuperarListas(idLista: romaneioId);

        var quantidadeItensPendentes = 0;
        for (final lista in listas) {
          final produtosPendentes = await _recuperarListaDeProdutosCompartilhada
              .recuperarProdutos(lista.hash);
          quantidadeItensPendentes += produtosPendentes.length;
        }

        if (quantidadeItensPendentes > 0) {
          pendencias[romaneioId] = quantidadeItensPendentes;
        }
      } catch (_) {
        continue;
      }
    }

    return pendencias;
  }
}
