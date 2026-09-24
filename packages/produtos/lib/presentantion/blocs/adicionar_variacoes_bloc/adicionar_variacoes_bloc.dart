import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/produtos_da_referencia_bloc/produtos_da_referencia_bloc.dart';
import 'package:produtos/use_cases.dart';

part 'adicionar_variacoes_event.dart';
part 'adicionar_variacoes_state.dart';

/// Painel "Adicionar variações": seleciona cores/tamanhos/(estampas) pra
/// criar em lote as combinações que ainda não existem na grade. O que já
/// está na grade vem marcado e travado (não pode ser desmarcado).
class AdicionarVariacoesBloc
    extends Bloc<AdicionarVariacoesEvent, AdicionarVariacoesState> {
  final RecuperarCores _recuperarCores;
  final RecuperarTamanhos _recuperarTamanhos;
  final RecuperarEstampas _recuperarEstampas;
  final CriarCodigoDeBarras _criarCodigoDeBarras;
  final CriarProdutosEmLote _criarProdutosEmLote;

  AdicionarVariacoesBloc(
    this._recuperarCores,
    this._recuperarTamanhos,
    this._recuperarEstampas,
    this._criarCodigoDeBarras,
    this._criarProdutosEmLote,
  ) : super(const AdicionarVariacoesState()) {
    on<AdicionarVariacoesIniciou>(_onIniciou);
    on<AdicionarVariacoesCorAlternou>(_onCorAlternou);
    on<AdicionarVariacoesTamanhoAlternou>(_onTamanhoAlternou);
    on<AdicionarVariacoesEstampaAlternou>(_onEstampaAlternou);
    on<AdicionarVariacoesEstampasAtivouAlternou>(_onEstampasAtivouAlternou);
    on<AdicionarVariacoesBuscaAlterou>(_onBuscaAlterou);
    on<AdicionarVariacoesConfirmou>(_onConfirmou);
  }

  FutureOr<void> _onIniciou(
    AdicionarVariacoesIniciou event,
    Emitter<AdicionarVariacoesState> emit,
  ) async {
    emit(
      state.copyWith(
        step: AdicionarVariacoesStep.carregando,
        referenciaId: event.referenciaId,
        corIdsNaGrade: event.corIdsNaGrade,
        tamanhoIdsNaGrade: event.tamanhoIdsNaGrade,
        estampaIdsNaGrade: event.estampaIdsNaGrade,
        chavesNaGrade: event.chavesNaGrade,
        coresSelecionadas: event.corIdsNaGrade,
        tamanhosSelecionados: event.tamanhoIdsNaGrade,
        estampasSelecionadas: event.estampaIdsNaGrade,
        estampasAtivo: event.estampaIdsNaGrade.isNotEmpty,
      ),
    );
    try {
      final cores = await _recuperarCores.call(inativo: false);
      final tamanhos = await _recuperarTamanhos.call(inativo: false);
      final estampas = await _recuperarEstampas
          .call(inativo: false)
          .catchError((_) => const <Estampa>[]);

      emit(
        state.copyWith(
          step: AdicionarVariacoesStep.pronto,
          todasCores: cores,
          todosTamanhos: tamanhos,
          todasEstampas: estampas,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: AdicionarVariacoesStep.falha));
      addError(e, s);
    }
  }

  void _onCorAlternou(
    AdicionarVariacoesCorAlternou event,
    Emitter<AdicionarVariacoesState> emit,
  ) {
    if (state.corIdsNaGrade.contains(event.corId)) {
      return;
    }
    emit(
      state.copyWith(
        coresSelecionadas: _alternar(state.coresSelecionadas, event.corId),
      ),
    );
  }

  void _onTamanhoAlternou(
    AdicionarVariacoesTamanhoAlternou event,
    Emitter<AdicionarVariacoesState> emit,
  ) {
    if (state.tamanhoIdsNaGrade.contains(event.tamanhoId)) return;
    emit(
      state.copyWith(
        tamanhosSelecionados: _alternar(
          state.tamanhosSelecionados,
          event.tamanhoId,
        ),
      ),
    );
  }

  void _onEstampaAlternou(
    AdicionarVariacoesEstampaAlternou event,
    Emitter<AdicionarVariacoesState> emit,
  ) {
    if (state.estampaIdsNaGrade.contains(event.estampaId)) return;
    emit(
      state.copyWith(
        estampasSelecionadas: _alternar(
          state.estampasSelecionadas,
          event.estampaId,
        ),
      ),
    );
  }

  FutureOr<void> _onEstampasAtivouAlternou(
    AdicionarVariacoesEstampasAtivouAlternou event,
    Emitter<AdicionarVariacoesState> emit,
  ) {
    emit(state.copyWith(estampasAtivo: event.ativo));
  }

  FutureOr<void> _onBuscaAlterou(
    AdicionarVariacoesBuscaAlterou event,
    Emitter<AdicionarVariacoesState> emit,
  ) {
    switch (event.campo) {
      case CampoBuscaVariacoes.cor:
        emit(state.copyWith(buscaCor: event.texto));
        break;
      case CampoBuscaVariacoes.tamanho:
        emit(state.copyWith(buscaTamanho: event.texto));
        break;
      case CampoBuscaVariacoes.estampa:
        emit(state.copyWith(buscaEstampa: event.texto));
        break;
    }
  }

  FutureOr<void> _onConfirmou(
    AdicionarVariacoesConfirmou event,
    Emitter<AdicionarVariacoesState> emit,
  ) async {
    final combinacoes = state.combinacoesNovas;
    if (combinacoes.isEmpty || state.referenciaId == null) return;

    emit(state.copyWith(step: AdicionarVariacoesStep.salvando));
    try {
      final itens = <NovoProdutoCombinacao>[];
      for (final combinacao in combinacoes) {
        final codigoDeBarras = await _criarCodigoDeBarras.call();
        itens.add(
          NovoProdutoCombinacao(
            referenciaId: state.referenciaId!,
            corId: combinacao.corId,
            tamanhoId: combinacao.tamanhoId,
            estampaId: combinacao.estampaId,
            codigoDeBarras: codigoDeBarras,
          ),
        );
      }

      final criados = await _criarProdutosEmLote.call(itens);
      emit(
        state.copyWith(step: AdicionarVariacoesStep.sucesso, criados: criados),
      );
    } catch (e, s) {
      emit(state.copyWith(step: AdicionarVariacoesStep.falha));
      addError(e, s);
    }
  }

  Set<int> _alternar(Set<int> conjunto, int id) {
    final novo = Set<int>.from(conjunto);
    if (!novo.remove(id)) novo.add(id);
    return novo;
  }
}
