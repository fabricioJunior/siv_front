import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart'
    show HttpException, mensagemDeErroApi;

part 'lista_personalizada_event.dart';
part 'lista_personalizada_state.dart';

class ListaPersonalizadaBloc
    extends Bloc<ListaPersonalizadaEvent, ListaPersonalizadaState> {
  final CriarListaPersonalizada _criarListaPersonalizada;
  final AdicionarItensListaPersonalizada _adicionarItensListaPersonalizada;
  final RemoverItensListaPersonalizada _removerItensListaPersonalizada;
  final RecuperarListaPersonalizada _recuperarListaPersonalizada;
  final BuscarLinkListaPersonalizada _buscarLinkListaPersonalizada;
  final AtualizarTituloListaPersonalizada _atualizarTituloListaPersonalizada;

  ListaPersonalizadaBloc(
    this._criarListaPersonalizada,
    this._adicionarItensListaPersonalizada,
    this._removerItensListaPersonalizada,
    this._recuperarListaPersonalizada,
    this._buscarLinkListaPersonalizada,
    this._atualizarTituloListaPersonalizada,
  ) : super(const ListaPersonalizadaState()) {
    on<ListaPersonalizadaCriou>(_onCriou);
    on<ListaPersonalizadaAbriu>(_onAbriu);
    on<ListaPersonalizadaReferenciasAdicionou>(_onReferenciasAdicionou);
    on<ListaPersonalizadaReferenciasRemoveu>(_onReferenciasRemoveu);
    on<ListaPersonalizadaItensAjustou>(_onItensAjustou);
    on<ListaPersonalizadaTituloAtualizou>(_onTituloAtualizou);
  }

  FutureOr<void> _onCriou(
    ListaPersonalizadaCriou event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    emit(state.copyWith(step: ListaPersonalizadaStep.salvando, erro: ''));
    try {
      final lista = await _criarListaPersonalizada.call(
        tabelaPrecoId: event.tabelaPrecoId,
        dataExpiracao: event.dataExpiracao,
        titulo: event.titulo,
      );
      emit(state.copyWith(step: ListaPersonalizadaStep.criada, lista: lista));
      await _carregarLink(lista.id, emit);
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListaPersonalizadaStep.formulario,
          erro: mensagemDeErroApi(e, 'Falha ao criar a lista.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onAbriu(
    ListaPersonalizadaAbriu event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    emit(state.copyWith(step: ListaPersonalizadaStep.salvando, erro: ''));
    try {
      final lista = await _recuperarListaPersonalizada.call(event.id);
      emit(state.copyWith(step: ListaPersonalizadaStep.criada, lista: lista));
      await _carregarLink(lista.id, emit);
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListaPersonalizadaStep.formulario,
          erro: mensagemDeErroApi(e, 'Falha ao carregar a lista.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _carregarLink(
    int listaId,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    try {
      final link = await _buscarLinkListaPersonalizada.call(listaId);
      emit(state.copyWith(link: link));
    } catch (e, s) {
      final mensagem = e is HttpException && e.statusCode == 400
          ? 'Site não configurado para esta empresa — fale com o suporte.'
          : mensagemDeErroApi(e, 'Falha ao obter o link da lista.');
      emit(state.copyWith(erro: mensagem));
      addError(e, s);
    }
  }

  FutureOr<void> _onReferenciasAdicionou(
    ListaPersonalizadaReferenciasAdicionou event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    final lista = state.lista;
    if (lista == null) return;

    emit(state.copyWith(atualizandoItens: true, erro: ''));
    try {
      final atualizada = await _adicionarItensListaPersonalizada.call(
        lista.id,
        event.referenciaIds,
      );
      emit(state.copyWith(lista: atualizada, atualizandoItens: false));
    } catch (e, s) {
      emit(
        state.copyWith(
          atualizandoItens: false,
          erro: mensagemDeErroApi(e, 'Falha ao adicionar referências na lista.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onReferenciasRemoveu(
    ListaPersonalizadaReferenciasRemoveu event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    final lista = state.lista;
    if (lista == null) return;

    emit(state.copyWith(atualizandoItens: true, erro: ''));
    try {
      final atualizada = await _removerItensListaPersonalizada.call(
        lista.id,
        event.referenciaIds,
      );
      emit(state.copyWith(lista: atualizada, atualizandoItens: false));
    } catch (e, s) {
      emit(
        state.copyWith(
          atualizandoItens: false,
          erro: mensagemDeErroApi(e, 'Falha ao remover referências da lista.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onItensAjustou(
    ListaPersonalizadaItensAjustou event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    final lista = state.lista;
    if (lista == null) return;
    if (event.paraAdicionar.isEmpty && event.paraRemover.isEmpty) return;

    emit(state.copyWith(atualizandoItens: true, erro: ''));
    try {
      var atual = lista;
      if (event.paraAdicionar.isNotEmpty) {
        atual = await _adicionarItensListaPersonalizada.call(
          atual.id,
          event.paraAdicionar,
        );
      }
      if (event.paraRemover.isNotEmpty) {
        atual = await _removerItensListaPersonalizada.call(
          atual.id,
          event.paraRemover,
        );
      }
      emit(state.copyWith(lista: atual, atualizandoItens: false));
    } catch (e, s) {
      emit(
        state.copyWith(
          atualizandoItens: false,
          erro: mensagemDeErroApi(e, 'Falha ao atualizar as referências da lista.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onTituloAtualizou(
    ListaPersonalizadaTituloAtualizou event,
    Emitter<ListaPersonalizadaState> emit,
  ) async {
    final lista = state.lista;
    if (lista == null) return;

    emit(state.copyWith(atualizandoTitulo: true, erro: ''));
    try {
      final atualizada = await _atualizarTituloListaPersonalizada.call(
        lista.id,
        event.titulo,
      );
      emit(state.copyWith(lista: atualizada, atualizandoTitulo: false));
    } catch (e, s) {
      emit(
        state.copyWith(
          atualizandoTitulo: false,
          erro: mensagemDeErroApi(e, 'Falha ao atualizar o título da lista.'),
        ),
      );
      addError(e, s);
    }
  }
}
