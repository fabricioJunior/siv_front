import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'ecommerce_referencias_event.dart';
part 'ecommerce_referencias_state.dart';

const _limitePagina = 50;

class EcommerceReferenciasBloc
    extends Bloc<EcommerceReferenciasEvent, EcommerceReferenciasState> {
  final RecuperarReferenciasEcommerce _recuperarReferenciasEcommerce;
  final AdicionarReferenciaEcommerce _adicionarReferenciaEcommerce;
  final AtualizarReferenciaEcommerce _atualizarReferenciaEcommerce;
  final PublicarReferenciasEmLoteEcommerce _publicarReferenciasEmLoteEcommerce;

  EcommerceReferenciasBloc(
    this._recuperarReferenciasEcommerce,
    this._adicionarReferenciaEcommerce,
    this._atualizarReferenciaEcommerce,
    this._publicarReferenciasEmLoteEcommerce,
  ) : super(const EcommerceReferenciasInitial()) {
    on<EcommerceReferenciasIniciou>(_onIniciou);
    on<EcommerceReferenciasCarregarMaisSolicitou>(_onCarregarMais);
    on<EcommerceReferenciaAdicionou>(_onAdicionou);
    on<EcommerceReferenciaPublicarSolicitou>(_onPublicar);
    on<EcommerceReferenciasDespublicarTodasSolicitou>(_onDespublicarTodas);
    on<EcommerceReferenciasPublicarEmLoteSolicitou>(_onPublicarEmLote);
  }

  FutureOr<void> _onIniciou(
    EcommerceReferenciasIniciou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    try {
      emit(const EcommerceReferenciasCarregarEmProgresso());
      final pagina = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: event.busca,
        categoriaIds: event.categoriaIds,
        rascunho: event.rascunhoFiltro,
        publicavel: event.publicavelFiltro,
        page: 1,
        limit: _limitePagina,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: event.ecommerceId,
          referencias: pagina.itens,
          busca: event.busca,
          categoriaIds: event.categoriaIds,
          rascunhoFiltro: event.rascunhoFiltro,
          publicavelFiltro: event.publicavelFiltro,
          total: pagina.total,
          totalPublicados: pagina.totalPublicados,
          totalRascunho: pagina.totalRascunho,
          totalNaoPublicaveis: pagina.totalNaoPublicaveis,
          pagina: 1,
          temMaisPaginas: pagina.itens.length >= _limitePagina,
        ),
      );
    } catch (e, s) {
      emit(const EcommerceReferenciasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onCarregarMais(
    EcommerceReferenciasCarregarMaisSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final atual = state;
    if (atual is! EcommerceReferenciasCarregarSucesso) return;
    if (!atual.temMaisPaginas || atual.carregandoMais) return;
    final ecommerceId = atual.ecommerceId;
    if (ecommerceId == null) return;

    emit(
      EcommerceReferenciasCarregarSucesso(
        ecommerceId: ecommerceId,
        referencias: atual.referencias,
        busca: atual.busca,
        categoriaIds: atual.categoriaIds,
        rascunhoFiltro: atual.rascunhoFiltro,
        publicavelFiltro: atual.publicavelFiltro,
        total: atual.total,
        totalPublicados: atual.totalPublicados,
        totalRascunho: atual.totalRascunho,
        totalNaoPublicaveis: atual.totalNaoPublicaveis,
        pagina: atual.pagina,
        temMaisPaginas: atual.temMaisPaginas,
        carregandoMais: true,
      ),
    );

    try {
      final proximaPagina = atual.pagina + 1;
      final pagina = await _recuperarReferenciasEcommerce.call(
        ecommerceId,
        busca: atual.busca,
        categoriaIds: atual.categoriaIds,
        rascunho: atual.rascunhoFiltro,
        publicavel: atual.publicavelFiltro,
        page: proximaPagina,
        limit: _limitePagina,
      );
      emit(
        EcommerceReferenciasCarregarSucesso(
          ecommerceId: ecommerceId,
          referencias: [...atual.referencias, ...pagina.itens],
          busca: atual.busca,
          categoriaIds: atual.categoriaIds,
          rascunhoFiltro: atual.rascunhoFiltro,
          publicavelFiltro: atual.publicavelFiltro,
          total: pagina.total ?? atual.total,
          totalPublicados: pagina.totalPublicados ?? atual.totalPublicados,
          totalRascunho: pagina.totalRascunho ?? atual.totalRascunho,
          totalNaoPublicaveis:
              pagina.totalNaoPublicaveis ?? atual.totalNaoPublicaveis,
          pagina: proximaPagina,
          temMaisPaginas: pagina.itens.length >= _limitePagina,
        ),
      );
    } catch (e, s) {
      emit(atual);
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
      add(
        EcommerceReferenciasIniciou(
          ecommerceId: event.ecommerceId,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
          publicavelFiltro: state.publicavelFiltro,
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

  // Publica direto da lista (card), sem passar pela tela de detalhe -- mesmo
  // use case usado lá. Update otimista (R5): só troca o item no state local,
  // sem reload completo nem processandoLote global. Reverte se o PATCH falhar.
  FutureOr<void> _onPublicar(
    EcommerceReferenciaPublicarSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final referenciasOriginais = state.referencias;
    final index = referenciasOriginais
        .indexWhere((referencia) => referencia.id == event.referenciaEcommerceId);
    if (index == -1) return;

    final referenciasOtimistas =
        List<EcommerceReferencia>.from(referenciasOriginais);
    referenciasOtimistas[index] = _comRascunho(
      referenciasOtimistas[index],
      event.rascunho,
    );

    emit(_copiarComReferencias(state, referenciasOtimistas));

    try {
      await _atualizarReferenciaEcommerce.call(
        event.ecommerceId,
        event.referenciaEcommerceId,
        rascunho: event.rascunho,
      );
    } catch (e, s) {
      emit(_copiarComReferencias(state, referenciasOriginais));
      addError(e, s);
    }
  }

  FutureOr<void> _onDespublicarTodas(
    EcommerceReferenciasDespublicarTodasSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final publicadas =
        state.referencias.where((referencia) => !referencia.rascunho).toList();
    if (publicadas.isEmpty) return;

    emit(_copiarComProgresso(state, processandoLote: true));

    try {
      final resultado = await _publicarReferenciasEmLoteEcommerce.call(
        event.ecommerceId,
        ids: publicadas.map((r) => r.id!).toList(),
        rascunho: true,
        onProgresso: (atual, total) => emit(
          _copiarComProgresso(
            state,
            processandoLote: true,
            loteAtual: atual,
            loteTotal: total,
          ),
        ),
      );
      final pagina = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunho: state.rascunhoFiltro,
        publicavel: state.publicavelFiltro,
      );
      emit(
        EcommerceReferenciasLoteConcluiu(
          ecommerceId: event.ecommerceId,
          referencias: pagina.itens,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
          publicados: resultado.atualizados,
          falharam: resultado.falharam.length,
          falhas: resultado.falharam,
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

  // Lote de verdade (R4): usa o endpoint dedicado quando existe; senão o
  // repositório mesmo cai no laço sequencial. Acumula falhas por motivo sem
  // abortar e só recarrega a lista uma vez no fim.
  FutureOr<void> _onPublicarEmLote(
    EcommerceReferenciasPublicarEmLoteSolicitou event,
    Emitter<EcommerceReferenciasState> emit,
  ) async {
    final ids = event.referenciaEcommerceIds;
    if (ids.isEmpty) return;

    emit(
      _copiarComProgresso(
        state,
        processandoLote: true,
        loteAtual: 0,
        loteTotal: ids.length,
      ),
    );

    try {
      final resultado = await _publicarReferenciasEmLoteEcommerce.call(
        event.ecommerceId,
        ids: ids,
        rascunho: event.rascunho,
        onProgresso: (atual, total) => emit(
          _copiarComProgresso(
            state,
            processandoLote: true,
            loteAtual: atual,
            loteTotal: total,
          ),
        ),
      );

      final pagina = await _recuperarReferenciasEcommerce.call(
        event.ecommerceId,
        busca: state.busca,
        categoriaIds: state.categoriaIds,
        rascunho: state.rascunhoFiltro,
        publicavel: state.publicavelFiltro,
      );
      emit(
        EcommerceReferenciasLoteConcluiu(
          ecommerceId: event.ecommerceId,
          referencias: pagina.itens,
          busca: state.busca,
          categoriaIds: state.categoriaIds,
          rascunhoFiltro: state.rascunhoFiltro,
          publicados: resultado.atualizados,
          falharam: resultado.falharam.length,
          falhas: resultado.falharam,
        ),
      );
    } catch (e, s) {
      emit(const EcommerceReferenciasCarregarFalha());
      addError(e, s);
    }
  }

  EcommerceReferencia _comRascunho(EcommerceReferencia referencia, bool rascunho) {
    return EcommerceReferencia.create(
      id: referencia.id,
      ecommerceId: referencia.ecommerceId,
      referenciaId: referencia.referenciaId,
      tabelaDePrecoId: referencia.tabelaDePrecoId,
      rascunho: rascunho,
      referenciaNome: referencia.referenciaNome,
      valor: referencia.valor,
      descricao: referencia.descricao,
      unidadeMedida: referencia.unidadeMedida,
      imagemUrl: referencia.imagemUrl,
      saldo: referencia.saldo,
      categoriaNome: referencia.categoriaNome,
      produtosTotal: referencia.produtosTotal,
      produtosDisponiveis: referencia.produtosDisponiveis,
      publicavel: referencia.publicavel,
      motivosBloqueio: referencia.motivosBloqueio,
      tabelaDePrecoNome: referencia.tabelaDePrecoNome,
    );
  }

  EcommerceReferenciasCarregarSucesso _copiarComReferencias(
    EcommerceReferenciasState base,
    List<EcommerceReferencia> referencias,
  ) {
    return EcommerceReferenciasCarregarSucesso(
      ecommerceId: base.ecommerceId,
      referencias: referencias,
      busca: base.busca,
      categoriaIds: base.categoriaIds,
      rascunhoFiltro: base.rascunhoFiltro,
      publicavelFiltro: base.publicavelFiltro,
      total: base.total,
      totalPublicados: base.totalPublicados,
      totalRascunho: base.totalRascunho,
      totalNaoPublicaveis: base.totalNaoPublicaveis,
      pagina: base.pagina,
      temMaisPaginas: base.temMaisPaginas,
    );
  }

  EcommerceReferenciasCarregarSucesso _copiarComProgresso(
    EcommerceReferenciasState base, {
    required bool processandoLote,
    int? loteAtual,
    int? loteTotal,
  }) {
    return EcommerceReferenciasCarregarSucesso(
      ecommerceId: base.ecommerceId,
      referencias: base.referencias,
      processandoLote: processandoLote,
      loteAtual: loteAtual ?? base.loteAtual,
      loteTotal: loteTotal ?? base.loteTotal,
      busca: base.busca,
      categoriaIds: base.categoriaIds,
      rascunhoFiltro: base.rascunhoFiltro,
      publicavelFiltro: base.publicavelFiltro,
      total: base.total,
      totalPublicados: base.totalPublicados,
      totalRascunho: base.totalRascunho,
      totalNaoPublicaveis: base.totalNaoPublicaveis,
      pagina: base.pagina,
      temMaisPaginas: base.temMaisPaginas,
    );
  }
}
