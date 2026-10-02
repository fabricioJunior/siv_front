import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/domain/referencias_filtro.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/referencias_bloc/referencias_bloc.dart'
    show ReferenciasOrdenacao;
import 'package:produtos/use_cases.dart';

part 'referencias_lista_event.dart';
part 'referencias_lista_state.dart';

/// Lista de Referências com busca, filtros e ordenação feitos no servidor (`GET /referencias/busca`), paginada.
class ReferenciasListaBloc
    extends Bloc<ReferenciasListaEvent, ReferenciasListaState> {
  final BuscarReferencias _buscarReferencias;

  // Cada busca nova invalida as anteriores: se a resposta de "cam" chegar depois da de "camisa", ela é descartada.
  int _geracao = 0;

  ReferenciasListaBloc(this._buscarReferencias)
    : super(const ReferenciasListaState()) {
    on<ReferenciasListaIniciou>((_, emit) => _carregar(emit));
    on<ReferenciasListaFiltrou>(
      (event, emit) =>
          _carregar(emit, filtro: event.filtro, ordenacao: event.ordenacao),
    );
    on<ReferenciasListaRecarregou>((_, emit) => _carregar(emit));
    on<ReferenciasListaCarregouMais>(_onCarregouMais);
  }

  Future<ReferenciasBuscaResultado> _consultar({
    required ReferenciasFiltro filtro,
    required ReferenciasOrdenacao ordenacao,
    required int pagina,
  }) {
    final (campo, direcao) = ordenacao.paraServidor;
    return _buscarReferencias.call(
      busca: filtro.busca,
      categoriaId: filtro.categoriaId,
      semNcm: filtro.semNcm,
      semPeso: filtro.semPeso,
      orderBy: campo,
      orderDir: direcao,
      page: pagina,
    );
  }

  Future<void> _carregar(
    Emitter<ReferenciasListaState> emit, {
    ReferenciasFiltro? filtro,
    ReferenciasOrdenacao? ordenacao,
  }) async {
    final geracao = ++_geracao;
    final novoFiltro = filtro ?? state.filtro;
    final novaOrdenacao = ordenacao ?? state.ordenacao;
    final primeiraCarga = state.itens.isEmpty;

    emit(
      state.copyWith(
        etapa: primeiraCarga ? ReferenciasListaEtapa.carregando : state.etapa,
        filtro: novoFiltro,
        ordenacao: novaOrdenacao,
        atualizando: !primeiraCarga,
        carregandoMais: false,
      ),
    );

    try {
      final resultado = await _consultar(
        filtro: novoFiltro,
        ordenacao: novaOrdenacao,
        pagina: 1,
      );
      if (geracao != _geracao) return;
      emit(
        state.copyWith(
          etapa: ReferenciasListaEtapa.carregado,
          itens: resultado.items,
          totalItens: resultado.totalItems,
          paginaAtual: resultado.currentPage,
          totalPaginas: resultado.totalPages,
          resumo: resultado.resumo,
          atualizando: false,
        ),
      );
    } catch (e, s) {
      if (geracao != _geracao) return;
      emit(
        state.copyWith(etapa: ReferenciasListaEtapa.falha, atualizando: false),
      );
      addError(e, s);
    }
  }

  Future<void> _onCarregouMais(
    ReferenciasListaCarregouMais event,
    Emitter<ReferenciasListaState> emit,
  ) async {
    if (state.carregandoMais || state.atualizando || !state.temMais) return;
    final geracao = _geracao;
    emit(state.copyWith(carregandoMais: true));
    try {
      final resultado = await _consultar(
        filtro: state.filtro,
        ordenacao: state.ordenacao,
        pagina: state.paginaAtual + 1,
      );
      // Filtro mudou enquanto a próxima página vinha: ela é da busca antiga.
      if (geracao != _geracao) return;
      emit(
        state.copyWith(
          itens: [...state.itens, ...resultado.items],
          totalItens: resultado.totalItems,
          paginaAtual: resultado.currentPage,
          totalPaginas: resultado.totalPages,
          carregandoMais: false,
        ),
      );
    } catch (e, s) {
      if (geracao != _geracao) return;
      emit(state.copyWith(carregandoMais: false));
      addError(e, s);
    }
  }
}
