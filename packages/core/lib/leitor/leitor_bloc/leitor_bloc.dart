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
  final int? _tabelaDePrecoId;
  final bool _aceitarApenasProdutosComPreco;
  final String Function(String descricao)? _mensagemQuantidadeIndisponivel;

  LeitorBloc({
    required ILeitorDataDatasource dataSource,
    bool controlarQuantidade = false,
    int? tabelaDePrecoId,
    bool aceitarApenasProdutosComPreco = false,
    String Function(String descricao)? mensagemQuantidadeIndisponivel,
    LeitorState? estadoInicial,
  })  : _dataSource = dataSource,
        _tabelaDePrecoId = tabelaDePrecoId,
        _aceitarApenasProdutosComPreco = aceitarApenasProdutosComPreco,
        _mensagemQuantidadeIndisponivel = mensagemQuantidadeIndisponivel,
        super(
          (estadoInicial ??
                  LeitorState.initial(
                    controlarQuantidade: controlarQuantidade,
                  ))
              .copyWith(
            controlarQuantidade: controlarQuantidade,
            processando: false,
            erro: null,
            aviso: null,
            avisoTipo: null,
          ),
        ) {
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
    on<LeitorProdutosPreCarregadosInformados>(
      _onLeitorProdutosPreCarregadosInformados,
      transformer: sequential(),
    );
  }

  Future<void> _onLeitorProdutosPreCarregadosInformados(
    LeitorProdutosPreCarregadosInformados event,
    Emitter<LeitorState> emit,
  ) async {
    if (event.produtos.isEmpty) {
      return;
    }

    final produtosNaoCarregados = <String>[];
    final produtosCarregadosComAjuste = <String>[];
    final quantidadesPrevistasPorCodigo = <String, int>{
      for (final item in state.itens) item.codigoDeBarras: item.quantidadeLida,
    };

    for (final produto in event.produtos) {
      if (produto.quantidade <= 0) {
        continue;
      }

      final LeitorData? data;
      try {
        data = await _dataSource.getDataPorProdutoId(
          produto.produtoId,
          tabelaDePrecoId: _tabelaDePrecoId,
        );
      } catch (_) {
        continue;
      }

      if (data == null) {
        continue;
      }

      var quantidadeParaCarregar = produto.quantidade;
      if (state.controlarQuantidade) {
        final estoqueDisponivel = data.quantidade;
        if (estoqueDisponivel == 0) {
          produtosNaoCarregados.add(
            '${data.descricao} (${data.descricao} - ${data.tamanho}/${data.cor}): estoque igual a zero.',
          );
          continue;
        }

        final quantidadeJaPrevista =
            quantidadesPrevistasPorCodigo[data.codigoDeBarras] ?? 0;
        final quantidadeDisponivelParaCarga =
            estoqueDisponivel - quantidadeJaPrevista;

        if (quantidadeDisponivelParaCarga <= 0) {
          produtosNaoCarregados.add(
            '${data.descricao} (${data.descricao} - ${data.tamanho}/${data.cor}): sem quantidade disponível para carregar.',
          );
          continue;
        }

        if (quantidadeParaCarregar > quantidadeDisponivelParaCarga) {
          produtosCarregadosComAjuste.add(
            '${data.descricao} (ID ${produto.produtoId}): solicitado ${produto.quantidade}, carregado $quantidadeDisponivelParaCarga.',
          );
          quantidadeParaCarregar = quantidadeDisponivelParaCarga;
        }
      }

      if (quantidadeParaCarregar <= 0) {
        continue;
      }

      quantidadesPrevistasPorCodigo[data.codigoDeBarras] =
          (quantidadesPrevistasPorCodigo[data.codigoDeBarras] ?? 0) +
              quantidadeParaCarregar;

      add(
        LeitorCodigoInformado(
          data.codigoDeBarras,
          quantidade: quantidadeParaCarregar,
        ),
      );
    }

    if (state.controlarQuantidade &&
        (produtosNaoCarregados.isNotEmpty ||
            produtosCarregadosComAjuste.isNotEmpty)) {
      final mensagem = [
        'Pré-carregamento concluído com ajustes:',
        if (produtosNaoCarregados.isNotEmpty) ...[
          'Não carregados:',
          ...produtosNaoCarregados.map((item) => '- $item'),
        ],
        if (produtosCarregadosComAjuste.isNotEmpty) ...[
          'Carregados com limite de estoque:',
          ...produtosCarregadosComAjuste.map((item) => '- $item'),
        ],
      ].join('\n');

      emit(
        state.copyWith(
          aviso: mensagem,
          avisoTipo: null,
          tokenAviso: state.tokenAviso + 1,
        ),
      );
    }
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
      data = await _dataSource.getData(
        codigo,
        tabelaDePrecoId: _tabelaDePrecoId,
      );
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
    final valorProduto = leitorData.valor;
    final exigirPreco = _aceitarApenasProdutosComPreco;

    if (exigirPreco && (valorProduto == null || valorProduto <= 0)) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: codigo,
          ultimoCodigoLidoValido: false,
          erro:
              'Produto sem preço cadastrado para a tabela de preço informada.',
          aviso: null,
          avisoTipo: null,
          tokenErro: state.tokenErro + 1,
        ),
      );
      return;
    }

    final quantidadeAdicionada = event.quantidade > 0 ? event.quantidade : 1;

    if (state.controlarQuantidade &&
        estoqueDisponivel >= 0 &&
        quantidadeAtual + quantidadeAdicionada > estoqueDisponivel) {
      emit(
        state.copyWith(
          processando: false,
          ultimoCodigoInformado: codigo,
          ultimoCodigoLidoValido: false,
          erro: _mensagemQuantidadeIndisponivel?.call(leitorData.descricao) ??
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
      valorUnitario: valorProduto ?? itemExistente?.valorUnitario,
      dados: leitorData.dados,
      quantidadeLida: quantidadeAtual + quantidadeAdicionada,
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
          quantidade: quantidadeAdicionada,
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
