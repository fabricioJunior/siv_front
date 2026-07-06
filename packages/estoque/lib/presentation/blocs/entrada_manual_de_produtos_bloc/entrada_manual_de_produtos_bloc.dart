import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'entrada_manual_de_produtos_event.dart';
part 'entrada_manual_de_produtos_state.dart';

class EntradaManualDeProdutosBloc
    extends Bloc<EntradaManualDeProdutosEvent, EntradaManualDeProdutosState> {
  final SalvarListaDeProdutosCompartilhada _salvarListaDeProdutosCompartilhada;
  final RecuperarCaixaAberto _recuperarCaixaAberto;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  EntradaManualDeProdutosBloc(
    this._salvarListaDeProdutosCompartilhada,
    this._recuperarCaixaAberto,
    this._acessoGlobalSessao,
  ) : super(const EntradaManualDeProdutosState()) {
    on<EntradaManualFuncionarioSelecionado>(_onFuncionarioSelecionado);
    on<EntradaManualTabelaDePrecoSelecionada>(_onTabelaDePrecoSelecionada);
    on<EntradaManualLeituraSolicitada>(_onLeituraSolicitada);
    on<EntradaManualEdicaoSolicitada>(_onEdicaoSolicitada);
    on<EntradaManualSalvarSolicitado>(_onSalvarSolicitado);
    on<EntradaManualResetSolicitado>(_onResetSolicitado);
  }

  FutureOr<void> _onFuncionarioSelecionado(
    EntradaManualFuncionarioSelecionado event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        funcionarioSelecionado: event.funcionarioSelecionado,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onTabelaDePrecoSelecionada(
    EntradaManualTabelaDePrecoSelecionada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoSelecionada: event.tabelaDePrecoSelecionada,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onLeituraSolicitada(
    EntradaManualLeituraSolicitada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) async {
    final erro = _validarSelecoes();
    if (erro != null) {
      emit(state.copyWith(erro: erro));
      return;
    }

    final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
    final terminalId = _acessoGlobalSessao.terminalIdDaSessao;
    if (empresaId == null || terminalId == null) {
      emit(
        state.copyWith(
          erro: 'Sessão sem empresa/terminal definidos. Faça login novamente.',
        ),
      );
      return;
    }

    emit(state.copyWith(verificandoCaixa: true, erro: null));

    try {
      final caixa = await _recuperarCaixaAberto.call(
        idEmpresa: empresaId,
        idTerminal: terminalId,
      );

      if (caixa == null) {
        emit(
          state.copyWith(
            verificandoCaixa: false,
            erro: 'Nenhum caixa aberto para este terminal. Abra um caixa antes de continuar.',
          ),
        );
        return;
      }

      if (caixa.situacao != SituacaoCaixa.aberto) {
        emit(
          state.copyWith(
            verificandoCaixa: false,
            erro: 'Seu caixa está em contagem e não pode receber novas movimentações. '
                'Finalize a contagem ou abra outro caixa antes de continuar.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          verificandoCaixa: false,
          step: EntradaManualDeProdutosStep.leitura,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          verificandoCaixa: false,
          erro: 'Falha ao verificar o caixa da sessão. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onEdicaoSolicitada(
    EntradaManualEdicaoSolicitada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        step: EntradaManualDeProdutosStep.configuracao,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvarSolicitado(
    EntradaManualSalvarSolicitado event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) async {
    final erroSelecao = _validarSelecoes();
    if (erroSelecao != null) {
      emit(state.copyWith(erro: erroSelecao));
      return;
    }

    final produtos = _mapearProdutos(event.itens);
    if (produtos.isEmpty) {
      emit(
        state.copyWith(
          erro: 'Adicione ao menos um produto para criar o romaneio.',
        ),
      );
      return;
    }

    emit(state.copyWith(salvando: true, erro: null));

    try {
      final origemCompartilhada = event.operacao == 'transferencia_saida'
          ? OrigemCompartilhadaTipo.manualSaidaDeProdutos
          : OrigemCompartilhadaTipo.manualEntradaDeProdutos;

      final lista = await _salvarListaDeProdutosCompartilhada(
        listaCompartilhada: ListaDeProdutosCompartilhada.criar(
          origem: origemCompartilhada,
          funcionarioId: state.funcionarioSelecionado?.id,
          tabelaPrecoId: state.tabelaDePrecoSelecionada?.id,
        ),
        produtos: produtos,
      );

      emit(
        state.copyWith(
          salvando: false,
          listaCompartilhadaHash: lista.hash,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          erro: 'Falha ao salvar os produtos localmente. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onResetSolicitado(
    EntradaManualResetSolicitado event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(const EntradaManualDeProdutosState());
  }

  String? _validarSelecoes() {
    if (state.funcionarioSelecionado == null) {
      return 'Selecione um funcionário para continuar.';
    }

    if (state.tabelaDePrecoSelecionada == null) {
      return 'Selecione uma tabela de preço para continuar.';
    }

    return null;
  }

  List<ProdutoCompartilhado> _mapearProdutos(List<Map<String, dynamic>> itens) {
    final produtos = <ProdutoCompartilhado>[];

    for (final item in itens) {
      final produtoId = _toInt(
        item['produtoId'] ?? item['id'] ?? item['produto'],
      );
      final quantidade = _toInt(
        item['quantidade'] ?? item['quantidadeLida'] ?? item['qtd'],
      );

      if (produtoId == null || quantidade == null || quantidade <= 0) {
        continue;
      }

      produtos.add(
        ProdutoCompartilhado.create(
          produtoId: produtoId,
          quantidade: quantidade,
          valorUnitario:
              _toDouble(
                item['valorUnitario'] ?? item['preco'] ?? item['valor'],
              ) ??
              0,
          nome:
              item['nome']?.toString() ?? item['produtoNome']?.toString() ?? '',
          corNome: item['corNome']?.toString() ?? item['cor']?.toString() ?? '',
          tamanhoNome:
              item['tamanhoNome']?.toString() ??
              item['tamanho']?.toString() ??
              '',
        ),
      );
    }

    return produtos;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
