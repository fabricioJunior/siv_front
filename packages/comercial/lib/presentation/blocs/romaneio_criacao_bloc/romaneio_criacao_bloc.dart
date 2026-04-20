import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/sessao.dart';

part 'romaneio_criacao_event.dart';
part 'romaneio_criacao_state.dart';

class RomaneioCriacaoBloc
    extends Bloc<RomaneioCriacaoEvent, RomaneioCriacaoState> {
  final CriarRomaneio _criarRomaneio;
  final AdicionarItemRomaneio _adicionarItemRomaneio;
  final RecuperarRomaneio _recuperarRomaneio;
  final RecuperarListaDeProdutosCompartilhada
      _recuperarListaDeProdutosCompartilhada;
  final RemoverListaDeProdutosCompartilhada
      _removerListaDeProdutosCompartilhada;
  final RemoverProdutoCompartilhado _removerProdutoCompartilhado;
  final AtualizarListaCompartilhada _atualizarListaCompartilhada;
  final ReceberRomaneioNoCaixa _receberRomaneioNoCaixa;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  RomaneioCriacaoBloc(
    this._criarRomaneio,
    this._adicionarItemRomaneio,
    this._recuperarRomaneio,
    this._recuperarListaDeProdutosCompartilhada,
    this._removerListaDeProdutosCompartilhada,
    this._removerProdutoCompartilhado,
    this._atualizarListaCompartilhada,
    this._receberRomaneioNoCaixa,
    this._acessoGlobalSessao,
  ) : super(const RomaneioCriacaoState.initial()) {
    on<RomaneioCriacaoSolicitada>(_onSolicitada);
  }

  FutureOr<void> _onSolicitada(
    RomaneioCriacaoSolicitada event,
    Emitter<RomaneioCriacaoState> emit,
  ) async {
    ListaDeProdutosCompartilhada? listaCompartilhada;
    var produtosCompartilhados = <ProdutoCompartilhado>[];
    TipoOperacao? operacao;
    var itens = <RomaneioItem>[];
    var falhaAoReceberNoCaixa = false;

    emit(
      state.copyWith(
        step: RomaneioCriacaoStep.processando,
        hashLista: event.hashLista,
        listaCompartilhada: null,
        produtosCompartilhados: const [],
        erro: null,
        totalItensProcessados: 0,
      ),
    );

    try {
      listaCompartilhada = await _recuperarListaDeProdutosCompartilhada.call(
        event.hashLista,
      );
      produtosCompartilhados = await _recuperarListaDeProdutosCompartilhada
          .recuperarProdutos(event.hashLista);

      operacao = listaCompartilhada == null
          ? null
          : _resolverOperacao(listaCompartilhada);
      itens = _extrairItens(produtosCompartilhados);
      final erro = _validar(listaCompartilhada, operacao, itens);

      if (erro != null) {
        emit(
          state.copyWith(
            step: RomaneioCriacaoStep.falha,
            hashLista: event.hashLista,
            listaCompartilhada: listaCompartilhada,
            produtosCompartilhados: produtosCompartilhados,
            erro: erro,
            totalItensProcessados: itens.length,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.processando,
          hashLista: event.hashLista,
          listaCompartilhada: listaCompartilhada,
          produtosCompartilhados: produtosCompartilhados,
          erro: null,
          totalItensProcessados: itens.length,
        ),
      );
      bool precisaCriarRomaneio = listaCompartilhada!.idLista == null;
      final criado = precisaCriarRomaneio
          ? await _criarRomaneio.call(
              Romaneio.create(
                pessoaId: listaCompartilhada.pessoaId,
                funcionarioId: listaCompartilhada.funcionarioId,
                tabelaPrecoId: listaCompartilhada.tabelaPrecoId,
                operacao: operacao,
              ),
            )
          : await _recuperarRomaneio.call(listaCompartilhada.idLista!);

      final romaneioId = criado.id;

      listaCompartilhada = listaCompartilhada.copyWith(
        idLista: romaneioId,
      );
      await _atualizarListaCompartilhada.call(listaCompartilhada);
      if (romaneioId == null) {
        throw StateError('A API não retornou o id do romaneio criado.');
      }

      for (final item in produtosCompartilhados) {
        await _adicionarItemRomaneio.call(
          romaneioId: romaneioId,
          item: _extrairItem(item),
        );
        await _removerProdutoCompartilhado.call(item.hash);
      }

      await _removerListaCompartilhadaSeNecessario(event.hashLista);
      listaCompartilhada = listaCompartilhada.copyWith(
        processada: true,
      );
      await _atualizarListaCompartilhada.call(listaCompartilhada);

      if (operacao == TipoOperacao.transferencia_entrada ||
          operacao == TipoOperacao.venda) {
        falhaAoReceberNoCaixa = true;
        final caixaId = _acessoGlobalSessao.caixaIdDaSessao;
        if (caixaId == null) {
          throw StateError(
            'Não foi possível receber romaneio: caixa da sessão não encontrado.',
          );
        }

        await _receberRomaneioNoCaixa.call(
          caixaId: caixaId,
          romaneioId: romaneioId,
        );
        falhaAoReceberNoCaixa = false;
      }

      final romaneioAtualizado = await _recuperarRomaneio.call(romaneioId);
      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.sucesso,
          hashLista: event.hashLista,
          listaCompartilhada: listaCompartilhada,
          produtosCompartilhados: produtosCompartilhados,
          romaneio: romaneioAtualizado,
          erro: null,
          totalItensProcessados: itens.length,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.falha,
          hashLista: event.hashLista,
          listaCompartilhada: listaCompartilhada,
          produtosCompartilhados: produtosCompartilhados,
          erro: _mensagemFalhaProcessamento(
            listaCompartilhada: listaCompartilhada,
            operacao: operacao,
            falhaAoReceberNoCaixa: falhaAoReceberNoCaixa,
          ),
          totalItensProcessados: itens.length,
        ),
      );
      addError(e, s);
    }
  }

  String _mensagemFalhaProcessamento({
    required ListaDeProdutosCompartilhada? listaCompartilhada,
    required TipoOperacao? operacao,
    required bool falhaAoReceberNoCaixa,
  }) {
    final romaneioId = listaCompartilhada?.idLista;

    if (falhaAoReceberNoCaixa && romaneioId != null) {
      return 'O romaneio #$romaneioId foi criado, mas não foi possível encaminhá-lo ao caixa automaticamente. Volte e conclua o processo manualmente.';
    }

    if (romaneioId != null) {
      return 'O romaneio #$romaneioId foi criado, mas o processamento não foi concluído automaticamente. Volte e confira os romaneios pendentes.';
    }

    return 'Falha ao criar o romaneio. Tente novamente.';
  }

  String? _validar(
    ListaDeProdutosCompartilhada? listaCompartilhada,
    TipoOperacao? operacao,
    List<RomaneioItem> itens,
  ) {
    if (listaCompartilhada == null) {
      return 'Lista compartilhada não encontrada para o hash informado.';
    }

    if (listaCompartilhada.funcionarioId == null) {
      return 'A lista compartilhada não possui um funcionarioId válido.';
    }

    if (listaCompartilhada.tabelaPrecoId == null) {
      return 'A lista compartilhada não possui um tabelaPrecoId válido.';
    }

    if (operacao == TipoOperacao.venda && listaCompartilhada.pessoaId == null) {
      return 'A lista compartilhada não possui um cliente válido para a venda.';
    }

    if (operacao == null) {
      return 'A lista compartilhada não possui uma operação válida do romaneio.';
    }

    if (itens.isEmpty) {
      return 'A lista compartilhada não possui produtos válidos para criar o romaneio.';
    }

    return null;
  }

  List<RomaneioItem> _extrairItens(List<ProdutoCompartilhado> produtos) {
    return produtos
        .where((produto) => produto.quantidade > 0)
        .map(
          (produto) => _extrairItem(produto),
        )
        .toList();
  }

  RomaneioItem _extrairItem(ProdutoCompartilhado produto) {
    return RomaneioItem.create(
      produtoId: produto.produtoId,
      quantidade: produto.quantidade.toDouble(),
      referenciaNome: produto.nome,
      corNome: produto.corNome,
      tamanhoNome: produto.tamanhoNome,
    );
  }

  TipoOperacao? _resolverOperacao(ListaDeProdutosCompartilhada lista) {
    switch (lista.origem) {
      case OrigemCompartilhadaTipo.romenioEntradaDeProdutos:
        return TipoOperacao.transferencia_entrada;
      case OrigemCompartilhadaTipo.romenioSaidaDeProdutos:
        return TipoOperacao.transferencia_saida;
      case OrigemCompartilhadaTipo.venda:
        return TipoOperacao.venda;
    }
  }

  Future<void> _removerListaCompartilhadaSeNecessario(String hashLista) async {
    if (hashLista.trim().isEmpty) {
      return;
    }

    try {
      await _removerListaDeProdutosCompartilhada(hashLista);
    } catch (e, s) {
      addError(e, s);
    }
  }
}
