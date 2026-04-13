import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';

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

  RomaneioCriacaoBloc(
    this._criarRomaneio,
    this._adicionarItemRomaneio,
    this._recuperarRomaneio,
    this._recuperarListaDeProdutosCompartilhada,
    this._removerListaDeProdutosCompartilhada,
    this._removerProdutoCompartilhado,
    this._atualizarListaCompartilhada,
  ) : super(const RomaneioCriacaoState.initial()) {
    on<RomaneioCriacaoSolicitada>(_onSolicitada);
  }

  FutureOr<void> _onSolicitada(
    RomaneioCriacaoSolicitada event,
    Emitter<RomaneioCriacaoState> emit,
  ) async {
    ListaDeProdutosCompartilhada? listaCompartilhada;
    var produtosCompartilhados = <ProdutoCompartilhado>[];

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

      final operacao = listaCompartilhada == null
          ? null
          : _resolverOperacao(listaCompartilhada);
      final itens = _extrairItens(produtosCompartilhados);
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
                funcionarioId: listaCompartilhada.funcionarioId,
                tabelaPrecoId: listaCompartilhada.tabelaPrecoId,
                operacao: operacao,
              ),
            )
          : await _recuperarRomaneio.call(listaCompartilhada.idLista!);

      final romaneioId = criado.id;

      await _atualizarListaCompartilhada.call(listaCompartilhada.copyWith(
        idLista: romaneioId,
      ));
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

      final romaneioAtualizado = await _recuperarRomaneio.call(romaneioId);
      await _removerListaCompartilhadaSeNecessario(event.hashLista);
      await _atualizarListaCompartilhada.call(listaCompartilhada.copyWith(
        processada: true,
      ));
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
          erro: 'Falha ao criar o romaneio.',
        ),
      );
      addError(e, s);
    }
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
