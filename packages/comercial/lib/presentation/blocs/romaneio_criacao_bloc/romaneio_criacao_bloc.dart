import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

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
  final RecuperarCaixaAberto _recuperarCaixaAberto;

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
    this._recuperarCaixaAberto,
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
    var formasDePagamentoRealizadas = <RomaneioPagamentoRealizado>[];
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
      formasDePagamentoRealizadas = _extrairFormasDePagamentoRealizadas(
          event.formasDePagamentoRealizadas);
      final erro = _validar(
        listaCompartilhada,
        operacao,
        itens,
        formasDePagamentoRealizadas,
      );

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
      // Soma a partir de descontosItens (não de event.desconto) -- o widget
      // de pagamento distribui o desconto "geral" digitado nos itens antes
      // de retornar o resultado (ver comentário em pagamentos_realizados_
      // state.dart:61-66), e event.desconto só registra o último valor
      // "geral" informado (fica 0 se o usuário só usou desconto por item
      // explícito). Somar aqui cobre os dois casos igual.
      final descontoTotal = event.descontosItens.fold<double>(
        0,
        (soma, item) => soma + (_toDouble(item['valor']) ?? 0),
      );

      bool precisaCriarRomaneio = listaCompartilhada!.idLista == null;
      final criado = precisaCriarRomaneio
          ? await _criarRomaneio.call(
              Romaneio.create(
                pessoaId: listaCompartilhada.pessoaId,
                funcionarioId: listaCompartilhada.funcionarioId,
                tabelaPrecoId: listaCompartilhada.tabelaPrecoId,
                operacao: operacao,
                desconto: descontoTotal,
                consignacaoId: event.consignacaoId,
                romaneiosConsignacao: event.romaneiosConsignacao,
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
          operacao == TipoOperacao.manual_entrada ||
          operacao == TipoOperacao.venda ||
          operacao == TipoOperacao.venda_devolucao) {
        falhaAoReceberNoCaixa = true;
        final caixaId = _acessoGlobalSessao.caixaIdDaSessao;
        if (caixaId == null) {
          throw StateError(
            'Não foi possível receber romaneio: caixa da sessão não encontrado.',
          );
        }

        final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
        final terminalId = _acessoGlobalSessao.terminalIdDaSessao;
        if (empresaId != null && terminalId != null) {
          final caixa = await _recuperarCaixaAberto.call(
            idEmpresa: empresaId,
            idTerminal: terminalId,
          );

          final contagemJaEncerrada = caixa?.contagem?.encerrada == true;
          if (caixa == null ||
              (caixa.situacao != SituacaoCaixa.aberto &&
                  !contagemJaEncerrada)) {
            throw StateError(
              'Não foi possível receber romaneio: o caixa está em contagem ou fechado. '
              'Finalize a contagem ou abra outro caixa antes de continuar.',
            );
          }
        }

        // Não reenvia descontosItens aqui -- o desconto já foi persistido
        // no romaneio na criação acima (desconto: descontoTotal), e o
        // backend usa romaneio.desconto como base automática ao receber
        // (receber.service.ts). Mandar os dois juntos soma o desconto em
        // dobro, dando troco maior que o devido (bug real identificado em
        // vendas de produção com desconto + pagamento em dinheiro).
        await _receberRomaneioNoCaixa.call(
          caixaId: caixaId,
          romaneioId: romaneioId,
          formasDePagamentoRealizadas: formasDePagamentoRealizadas,
          incluirCpfNaNota: event.incluirCpfNaNota,
          cpfNaNota: event.cpfNaNota,
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
            erro: e,
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
    required Object erro,
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

    return mensagemDeErroApi(
        erro, 'Falha ao criar o romaneio. Tente novamente.');
  }

  String? _validar(
    ListaDeProdutosCompartilhada? listaCompartilhada,
    TipoOperacao? operacao,
    List<RomaneioItem> itens,
    List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
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

    if ((operacao == TipoOperacao.venda ||
            operacao == TipoOperacao.venda_devolucao) &&
        listaCompartilhada.pessoaId == null) {
      return 'A lista compartilhada não possui um cliente válido para a venda.';
    }

    if (operacao == null) {
      return 'A lista compartilhada não possui uma operação válida do romaneio.';
    }

    if (itens.isEmpty) {
      return 'A lista compartilhada não possui produtos válidos para criar o romaneio.';
    }

    if (operacao == TipoOperacao.venda && formasDePagamentoRealizadas.isEmpty) {
      return 'Informe ao menos uma forma de pagamento realizada para criar o romaneio de venda.';
    }

    return null;
  }

  List<RomaneioPagamentoRealizado> _extrairFormasDePagamentoRealizadas(
    List<Map<String, dynamic>> formas,
  ) {
    return formas
        .map((item) {
          final formaDePagamentoId = _toInt(item['formaDePagamentoId']);
          final valor = _toDouble(item['valor']);
          final parcela = _toInt(item['parcela']) ?? 1;
          final controle = _toInt(item['controle']) ?? 0;

          if (formaDePagamentoId == null || formaDePagamentoId <= 0) {
            return null;
          }

          if (valor == null || valor <= 0) {
            return null;
          }

          return RomaneioPagamentoRealizado.create(
            controle: controle > 0 ? controle : 1,
            formaDePagamentoId: formaDePagamentoId,
            parcela: parcela > 0 ? parcela : 1,
            valor: valor,
          );
        })
        .whereType<RomaneioPagamentoRealizado>()
        .toList(growable: false);
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
      case OrigemCompartilhadaTipo.vendaDevolucao:
        return TipoOperacao.venda_devolucao;
      case OrigemCompartilhadaTipo.manualEntradaDeProdutos:
        return TipoOperacao.manual_entrada;
      case OrigemCompartilhadaTipo.manualSaidaDeProdutos:
        return TipoOperacao.manual_saida;
      case OrigemCompartilhadaTipo.consignacaoSaida:
        return TipoOperacao.consignacao_saida;
      case OrigemCompartilhadaTipo.consignacaoDevolucao:
        return TipoOperacao.consignacao_devolucao;
      case OrigemCompartilhadaTipo.orcamento:
        return null;
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

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
