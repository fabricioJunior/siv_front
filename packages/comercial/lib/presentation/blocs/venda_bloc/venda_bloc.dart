import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';

part 'venda_event.dart';
part 'venda_state.dart';

class VendaBloc extends Bloc<VendaEvent, VendaState> {
  final SalvarListaDeProdutosCompartilhada _salvarListaDeProdutosCompartilhada;
  final CriarPedido _criarPedido;

  VendaBloc(
    this._salvarListaDeProdutosCompartilhada,
    this._criarPedido,
  ) : super(const VendaState()) {
    on<VendaClienteSelecionado>(_onClienteSelecionado);
    on<VendaVendedorSelecionado>(_onVendedorSelecionado);
    on<VendaTabelaDePrecoSelecionada>(_onTabelaDePrecoSelecionada);
    on<VendaLeituraSolicitada>(_onLeituraSolicitada);
    on<VendaEdicaoSolicitada>(_onEdicaoSolicitada);
    on<VendaFinalizarSolicitada>(_onFinalizarSolicitada);
    on<VendaCriarPedidoSolicitado>(_onCriarPedidoSolicitado);
    on<VendaResetSolicitado>(_onResetSolicitado);
  }

  void _onClienteSelecionado(
    VendaClienteSelecionado event,
    Emitter<VendaState> emit,
  ) {
    emit(
      state.copyWith(clienteSelecionado: event.clienteSelecionado, erro: null),
    );
  }

  void _onVendedorSelecionado(
    VendaVendedorSelecionado event,
    Emitter<VendaState> emit,
  ) {
    emit(
      state.copyWith(
          vendedorSelecionado: event.vendedorSelecionado, erro: null),
    );
  }

  void _onTabelaDePrecoSelecionada(
    VendaTabelaDePrecoSelecionada event,
    Emitter<VendaState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoSelecionada: event.tabelaDePrecoSelecionada,
        erro: null,
      ),
    );
  }

  void _onLeituraSolicitada(
    VendaLeituraSolicitada event,
    Emitter<VendaState> emit,
  ) {
    final erro = _validarSelecoes();
    if (erro != null) {
      emit(state.copyWith(erro: erro));
    } else {
      emit(state.copyWith(step: VendaStep.leitura, erro: null));
    }
  }

  void _onEdicaoSolicitada(
    VendaEdicaoSolicitada event,
    Emitter<VendaState> emit,
  ) {
    emit(state.copyWith(step: VendaStep.configuracao, erro: null));
  }

  FutureOr<void> _onFinalizarSolicitada(
    VendaFinalizarSolicitada event,
    Emitter<VendaState> emit,
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
          erro: 'Adicione ao menos um produto para finalizar a venda.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        processando: true,
        processoAtual: VendaProcesso.finalizarVenda,
        erro: null,
      ),
    );

    try {
      final lista = await _salvarListaDeProdutosCompartilhada(
        listaCompartilhada: ListaDeProdutosCompartilhada.criar(
          origem: OrigemCompartilhadaTipo.venda,
          pessoaId: state.clienteSelecionado?.id,
          funcionarioId: state.vendedorSelecionado?.id,
          tabelaPrecoId: state.tabelaDePrecoSelecionada?.id,
        ),
        produtos: produtos,
      );

      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          listaCompartilhadaHash: lista.hash,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          erro: 'Falha ao preparar a venda. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onCriarPedidoSolicitado(
    VendaCriarPedidoSolicitado event,
    Emitter<VendaState> emit,
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
          erro: 'Adicione ao menos um produto para criar o pedido.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        processando: true,
        processoAtual: VendaProcesso.criarPedido,
        erro: null,
      ),
    );

    try {
      final lista = await _salvarListaDeProdutosCompartilhada(
        listaCompartilhada: ListaDeProdutosCompartilhada.criar(
          origem: OrigemCompartilhadaTipo.venda,
          pessoaId: state.clienteSelecionado?.id,
          funcionarioId: state.vendedorSelecionado?.id,
          tabelaPrecoId: state.tabelaDePrecoSelecionada?.id,
        ),
        produtos: produtos,
      );

      final agora = DateTime.now();
      final observacao = StringBuffer('Pedido criado pela tela de venda.')
        ..write(' Itens: ${event.quantidadeProdutos}.')
        ..write(
          ' Valor total: R\$ ${event.valorTotal.toStringAsFixed(2).replaceAll('.', ',')}.',
        )
        ..write(' Lista local: ${lista.hash}.');

      final pedido = await _criarPedido(
        Pedido.create(
          pessoaId: state.clienteSelecionado?.id,
          funcionarioId: state.vendedorSelecionado?.id,
          tabelaPrecoId: state.tabelaDePrecoSelecionada?.id,
          dataBasePagamento: agora,
          previsaoDeFaturamento: agora,
          previsaoDeEntrega: agora,
          parcelas: 1,
          intervalo: 30,
          tipo: 'venda',
          fiscal: false,
          observacao: observacao.toString(),
        ),
      );

      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          pedidoCriadoId: pedido.id,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          erro: 'Falha ao criar o pedido. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  void _onResetSolicitado(
    VendaResetSolicitado event,
    Emitter<VendaState> emit,
  ) {
    emit(const VendaState());
  }

  String? _validarSelecoes() {
    if (state.clienteSelecionado == null) {
      return 'Selecione um cliente para continuar.';
    }

    if (state.vendedorSelecionado == null) {
      return 'Selecione um vendedor para continuar.';
    }

    if (state.tabelaDePrecoSelecionada == null) {
      return 'Selecione uma tabela de preço para continuar.';
    }

    return null;
  }

  List<ProdutoCompartilhado> _mapearProdutos(List<Map<String, dynamic>> itens) {
    final produtos = <ProdutoCompartilhado>[];

    for (final item in itens) {
      final produtoId =
          _toInt(item['produtoId'] ?? item['id'] ?? item['produto']);
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
          valorUnitario: _toDouble(
                  item['valorUnitario'] ?? item['preco'] ?? item['valor']) ??
              0,
          nome: item['nome']?.toString() ?? item['descricao']?.toString() ?? '',
          corNome: item['corNome']?.toString() ?? item['cor']?.toString() ?? '',
          tamanhoNome: item['tamanhoNome']?.toString() ??
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
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
