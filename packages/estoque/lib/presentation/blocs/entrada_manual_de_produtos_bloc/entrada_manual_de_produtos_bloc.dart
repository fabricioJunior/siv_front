import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';

part 'entrada_manual_de_produtos_event.dart';
part 'entrada_manual_de_produtos_state.dart';

class EntradaManualDeProdutosBloc
    extends Bloc<EntradaManualDeProdutosEvent, EntradaManualDeProdutosState> {
  final SalvarListaDeProdutosCompartilhada _salvarListaDeProdutosCompartilhada;

  EntradaManualDeProdutosBloc(this._salvarListaDeProdutosCompartilhada)
    : super(const EntradaManualDeProdutosState()) {
    on<EntradaManualFuncionarioSelecionado>(_onFuncionarioSelecionado);
    on<EntradaManualTabelaDePrecoSelecionada>(_onTabelaDePrecoSelecionada);
    on<EntradaManualLeituraSolicitada>(_onLeituraSolicitada);
    on<EntradaManualEdicaoSolicitada>(_onEdicaoSolicitada);
    on<EntradaManualSalvarSolicitado>(_onSalvarSolicitado);
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
  ) {
    final erro = _validarSelecoes();
    if (erro != null) {
      emit(state.copyWith(erro: erro));
    } else {
      emit(
        state.copyWith(step: EntradaManualDeProdutosStep.leitura, erro: null),
      );
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
          ? OrigemCompartilhadaTipo.romenioSaidaDeProdutos
          : OrigemCompartilhadaTipo.romenioEntradaDeProdutos;

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
