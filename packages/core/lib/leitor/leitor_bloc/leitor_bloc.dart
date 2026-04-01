import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

part 'leitor_event.dart';
part 'leitor_state.dart';

class LeitorBloc extends Bloc<LeitorEvent, LeitorState> {
  final ILeitorDataDatasource _dataSource;

  LeitorBloc({
    required ILeitorDataDatasource dataSource,
    bool controlarQuantidade = false,
  })  : _dataSource = dataSource,
        super(LeitorState.initial(controlarQuantidade: controlarQuantidade)) {
    on<LeitorCodigoInformado>(
      _onLeitorCodigoInformado,
      transformer: sequential(),
    );
    on<LeitorQuantidadeRemovida>(
      _onLeitorQuantidadeRemovida,
      transformer: sequential(),
    );
    on<LeitorItemExcluido>(
      _onLeitorItemExcluido,
      transformer: sequential(),
    );
    on<LeitorReiniciado>(
      _onLeitorReiniciado,
      transformer: sequential(),
    );
  }

  Future<void> _onLeitorCodigoInformado(
    LeitorCodigoInformado event,
    Emitter<LeitorState> emit,
  ) async {
    final codigo = event.codigo.trim();
    if (codigo.isEmpty) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: '',
          ultimoCodigoLidoValido: false,
          erro: 'Informe um código de barras válido.',
          aviso: null,
          avisoTipo: null,
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        processando: true,
        erro: null,
        aviso: null,
        avisoTipo: null,
        ultimoCodigoInformado: codigo,
      ),
    );

    final LeitorData? data;
    try {
      data = await _dataSource.getData(codigo);
    } catch (_) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: codigo,
          ultimoCodigoLidoValido: false,
          erro: 'Erro ao consultar o código de barras informado.',
          aviso: null,
          avisoTipo: null,
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    if (data == null) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: codigo,
          ultimoCodigoLidoValido: false,
          erro: 'Produto não encontrado para o código informado.',
          aviso: null,
          avisoTipo: null,
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    final leitorData = data;

    final itens = List<LeitorItemContado>.from(state.itens);
    final indiceExistente = itens.indexWhere(
      (item) => item.codigoDeBarras == leitorData.codigoDeBarras,
    );
    final itemExistente = indiceExistente >= 0 ? itens[indiceExistente] : null;
    final quantidadeAtual = itemExistente?.quantidadeLida ?? 0;
    final estoqueDisponivel = leitorData.quantidade;

    if (state.controlarQuantidade &&
        estoqueDisponivel >= 0 &&
        quantidadeAtual + 1 > estoqueDisponivel) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: codigo,
          ultimoCodigoLidoValido: false,
          erro:
              'Quantidade excede o estoque disponível para ${leitorData.descricao}.',
          aviso: null,
          avisoTipo: null,
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    final itemAtualizado =
        (itemExistente ?? LeitorItemContado.fromData(leitorData)).copyWith(
      descricao: leitorData.descricao,
      idReferencia: leitorData.idReferencia,
      tamanho: leitorData.tamanho,
      cor: leitorData.cor,
      estoqueDisponivel: estoqueDisponivel,
      dados: leitorData.dados,
      quantidadeLida: quantidadeAtual + 1,
    );

    if (indiceExistente >= 0) {
      itens[indiceExistente] = itemAtualizado;
    } else {
      itens.add(itemAtualizado);
    }

    final historico = List<LeitorHistoricoRegistro>.from(state.historico)
      ..add(
        LeitorHistoricoRegistro(
          dataHora: DateTime.now(),
          tipo: LeitorHistoricoTipo.adicao,
          codigoDeBarras: itemAtualizado.codigoDeBarras,
          descricao: itemAtualizado.descricao,
          tamanho: itemAtualizado.tamanho,
          cor: itemAtualizado.cor,
          quantidade: 1,
          quantidadeAposOperacao: itemAtualizado.quantidadeLida,
        ),
      );

    emit(
      state.copyWith(
        processando: false,
        itens: itens,
        historico: historico,
        ultimoProdutoLido: itemAtualizado,
        ultimoCodigoInformado: codigo,
        ultimoCodigoLidoValido: true,
        erro: null,
        tokenUltimoProduto: state.tokenUltimoProduto + 1,
        aviso: itemExistente != null
            ? 'O mesmo código foi informado novamente: ${itemAtualizado.codigoDeBarras}.'
            : null,
        avisoTipo:
            itemExistente != null ? LeitorAvisoTipo.codigoDuplicado : null,
        tokenAviso:
            itemExistente != null ? state.tokenAviso + 1 : state.tokenAviso,
      ),
    );
  }

  void _onLeitorQuantidadeRemovida(
    LeitorQuantidadeRemovida event,
    Emitter<LeitorState> emit,
  ) {
    final itens = List<LeitorItemContado>.from(state.itens);
    final indice = itens.indexWhere(
      (item) => item.codigoDeBarras == event.codigo,
    );
    if (indice < 0) {
      emit(
        state.copyWith(
          erro: 'Produto não encontrado na leitura atual.',
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    final item = itens[indice];
    final quantidadeRemovida = event.quantidade <= item.quantidadeLida
        ? event.quantidade
        : item.quantidadeLida;
    final novaQuantidade = item.quantidadeLida - quantidadeRemovida;
    final LeitorItemContado? ultimoProdutoAtualizado;
    if (novaQuantidade > 0) {
      final itemAtualizado = item.copyWith(quantidadeLida: novaQuantidade);
      itens[indice] = itemAtualizado;
      ultimoProdutoAtualizado = itemAtualizado;
    } else {
      itens.removeAt(indice);
      ultimoProdutoAtualizado = itens.isEmpty ? null : itens.first;
    }

    final historico = List<LeitorHistoricoRegistro>.from(state.historico)
      ..add(
        LeitorHistoricoRegistro(
          dataHora: DateTime.now(),
          tipo: LeitorHistoricoTipo.remocao,
          codigoDeBarras: item.codigoDeBarras,
          descricao: item.descricao,
          tamanho: item.tamanho,
          cor: item.cor,
          quantidade: quantidadeRemovida,
          quantidadeAposOperacao: novaQuantidade,
        ),
      );

    emit(
      state.copyWith(
        itens: itens,
        historico: historico,
        ultimoProdutoLido: ultimoProdutoAtualizado,
        tokenUltimoProduto: state.tokenUltimoProduto + 1,
        erro: null,
        aviso: null,
        avisoTipo: null,
      ),
    );
  }

  void _onLeitorItemExcluido(
    LeitorItemExcluido event,
    Emitter<LeitorState> emit,
  ) {
    final indiceItemRemovido = state.itens.indexWhere(
      (item) => item.codigoDeBarras == event.codigo,
    );
    final itemRemovido =
        indiceItemRemovido >= 0 ? state.itens[indiceItemRemovido] : null;

    final itens = state.itens
        .where((item) => item.codigoDeBarras != event.codigo)
        .toList();

    final historico = List<LeitorHistoricoRegistro>.from(state.historico);
    if (itemRemovido != null) {
      historico.add(
        LeitorHistoricoRegistro(
          dataHora: DateTime.now(),
          tipo: LeitorHistoricoTipo.remocao,
          codigoDeBarras: itemRemovido.codigoDeBarras,
          descricao: itemRemovido.descricao,
          tamanho: itemRemovido.tamanho,
          cor: itemRemovido.cor,
          quantidade: itemRemovido.quantidadeLida,
          quantidadeAposOperacao: 0,
        ),
      );
    }

    emit(
      state.copyWith(
        itens: itens,
        historico: historico,
        ultimoProdutoLido: itens.isEmpty ? null : itens.first,
        tokenUltimoProduto: state.tokenUltimoProduto + 1,
        erro: null,
        aviso: null,
        avisoTipo: null,
      ),
    );
  }

  void _onLeitorReiniciado(
    LeitorReiniciado event,
    Emitter<LeitorState> emit,
  ) {
    emit(LeitorState.initial(controlarQuantidade: state.controlarQuantidade));
  }
}
