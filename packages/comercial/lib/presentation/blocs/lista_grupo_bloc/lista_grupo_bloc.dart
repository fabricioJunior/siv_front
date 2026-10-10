import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'lista_grupo_event.dart';
part 'lista_grupo_state.dart';

class ListaGrupoBloc extends Bloc<ListaGrupoEvent, ListaGrupoState> {
  final RecuperarListaGrupo _recuperar;
  final CriarListaGrupo _criar;
  final AtualizarListaGrupo _atualizar;
  final DefinirListasDoGrupo _definirListas;
  final EnviarIconeListaGrupo _enviarIcone;
  final ListarListasPersonalizadas _listarListas;
  final ArquivoService _arquivos;

  ListaGrupoBloc(
    this._recuperar,
    this._criar,
    this._atualizar,
    this._definirListas,
    this._enviarIcone,
    this._listarListas,
    this._arquivos,
  ) : super(const ListaGrupoState()) {
    on<ListaGrupoAbriu>(_onAbriu);
    on<ListaGrupoIconeEscolheu>(_onIconeEscolheu);
    on<ListaGrupoSalvou>(_onSalvou);
  }

  Future<void> _onAbriu(ListaGrupoAbriu event, Emitter<ListaGrupoState> emit) async {
    emit(state.copyWith(step: ListaGrupoStep.carregando, erro: ''));
    try {
      final opcoes = await _listarListas.call(limit: 100, tipo: ListaTipo.catalogo);
      final grupo = event.id == null ? null : await _recuperar.call(event.id!);
      emit(
        state.copyWith(
          step: ListaGrupoStep.pronto,
          grupo: grupo,
          opcoes: opcoes.items,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListaGrupoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar o grupo.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onIconeEscolheu(
    ListaGrupoIconeEscolheu event,
    Emitter<ListaGrupoState> emit,
  ) async {
    final arquivo = await _arquivos.selecionarArquivoComBytes(
      extensoes: const ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (arquivo == null) return;
    final grupo = state.grupo;
    if (grupo == null) {
      emit(state.copyWith(iconeLocal: arquivo, erro: ''));
      return;
    }
    emit(state.copyWith(step: ListaGrupoStep.salvando, erro: ''));
    try {
      final atualizado = await _enviarIcone.call(grupo.id, arquivo.bytes, arquivo.nome);
      emit(state.copyWith(step: ListaGrupoStep.pronto, grupo: atualizado));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListaGrupoStep.pronto,
          erro: mensagemDeErroApi(e, 'Falha ao enviar o ícone.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onSalvou(ListaGrupoSalvou event, Emitter<ListaGrupoState> emit) async {
    emit(state.copyWith(step: ListaGrupoStep.salvando, erro: ''));
    try {
      var grupo = state.grupo == null
          ? await _criar.call(nome: event.nome, descricao: event.descricao, ativo: event.ativo)
          : await _atualizar.call(
              state.grupo!.id,
              nome: event.nome,
              descricao: event.descricao,
              ativo: event.ativo,
            );
      await _definirListas.call(grupo.id, event.listaIds);
      final icone = state.iconeLocal;
      if (icone != null) {
        grupo = await _enviarIcone.call(grupo.id, icone.bytes, icone.nome);
      }
      emit(state.copyWith(step: ListaGrupoStep.salvo, grupo: grupo));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListaGrupoStep.pronto,
          erro: mensagemDeErroApi(e, 'Falha ao salvar o grupo.'),
        ),
      );
      addError(e, s);
    }
  }
}
