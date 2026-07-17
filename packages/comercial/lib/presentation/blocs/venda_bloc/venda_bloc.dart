import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
import 'package:pessoas/domain/usecases/recuperar_cliente_nao_cadastrado.dart';
import 'package:pessoas/domain/models/pessoa.dart';

part 'venda_event.dart';
part 'venda_state.dart';

class VendaBloc extends Bloc<VendaEvent, VendaState> {
  final SalvarListaDeProdutosCompartilhada _salvarListaDeProdutosCompartilhada;
  final CriarPedido _criarPedido;
  final SalvarOrcamento _salvarOrcamento;
  final CarregarOrcamento _carregarOrcamento;
  final ExcluirOrcamento _excluirOrcamento;
  final RecuperarCaixaAberto _recuperarCaixaAberto;
  final ObterBalancoEmAndamentoUseCase _obterBalancoEmAndamento;
  final IAcessoGlobalSessao _acessoGlobalSessao;
  final RecuperarClienteNaoCadastrado _recuperarClienteNaoCadastrado;

  VendaBloc(
    this._salvarListaDeProdutosCompartilhada,
    this._criarPedido,
    this._salvarOrcamento,
    this._carregarOrcamento,
    this._excluirOrcamento,
    this._recuperarCaixaAberto,
    this._obterBalancoEmAndamento,
    this._acessoGlobalSessao,
    this._recuperarClienteNaoCadastrado,
  ) : super(const VendaState()) {
    on<VendaClienteSelecionado>(_onClienteSelecionado);
    on<VendaClienteNaoCadastradoSolicitado>(
      _onClienteNaoCadastradoSolicitado,
    );
    on<VendaVendedorSelecionado>(_onVendedorSelecionado);
    on<VendaTabelaDePrecoSelecionada>(_onTabelaDePrecoSelecionada);
    on<VendaLeituraSolicitada>(_onLeituraSolicitada);
    on<VendaEdicaoSolicitada>(_onEdicaoSolicitada);
    on<VendaFinalizarSolicitada>(_onFinalizarSolicitada);
    on<VendaCriarPedidoSolicitado>(_onCriarPedidoSolicitado);
    on<VendaResetSolicitado>(_onResetSolicitado);
    on<VendaOrcamentoSalvarSolicitado>(_onOrcamentoSalvarSolicitado);
    on<VendaOrcamentoCarregarSolicitado>(_onOrcamentoCarregarSolicitado);
    on<VendaOrcamentoExcluirAposFinalizarSolicitado>(
      _onOrcamentoExcluirAposFinalizarSolicitado,
    );
  }

  void _onClienteSelecionado(
    VendaClienteSelecionado event,
    Emitter<VendaState> emit,
  ) {
    emit(
      state.copyWith(clienteSelecionado: event.clienteSelecionado, erro: null),
    );
  }

  // Pré-seleciona a pessoa placebo "Cliente não cadastrado" ao entrar na
  // tela (ou reiniciar o fluxo), pra vendas físicas sem cliente real
  // satisfazerem _validarSelecoes() sem exigir ação extra do operador. Só
  // preenche se o operador ainda não tiver escolhido/trocado o cliente, pra
  // não sobrescrever uma seleção manual já feita nem o cliente carregado de
  // um orçamento.
  FutureOr<void> _onClienteNaoCadastradoSolicitado(
    VendaClienteNaoCadastradoSolicitado event,
    Emitter<VendaState> emit,
  ) async {
    if (state.clienteSelecionado != null) return;

    try {
      final pessoa = await _recuperarClienteNaoCadastrado();
      if (state.clienteSelecionado != null) return;

      emit(
        state.copyWith(clienteSelecionado: _pessoaToSelectData(pessoa)),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  SelectData _pessoaToSelectData(Pessoa pessoa) {
    return SelectData(
      id: pessoa.id ?? 0,
      nome: pessoa.nome,
      data: {
        'id': pessoa.id,
        'nome': pessoa.nome,
        'documento': pessoa.documento,
        'email': pessoa.email,
        'telefone': pessoa.contato,
        'generica': pessoa.generica,
      },
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

  FutureOr<void> _onLeituraSolicitada(
    VendaLeituraSolicitada event,
    Emitter<VendaState> emit,
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
      final balancoEmAndamento = await _obterBalancoEmAndamento.call();
      if (balancoEmAndamento != null) {
        emit(
          state.copyWith(
            verificandoCaixa: false,
            erro: 'Balanço #${balancoEmAndamento.id} em andamento — operação bloqueada.',
          ),
        );
        return;
      }

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

      final contagemJaEncerrada = caixa.contagem?.encerrada == true;
      if (caixa.situacao != SituacaoCaixa.aberto && !contagemJaEncerrada) {
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
          step: VendaStep.leitura,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          verificandoCaixa: false,
          erro: 'Falha ao verificar o caixa e o balanço da sessão. Tente novamente.',
        ),
      );
      addError(e, s);
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
          formasDePagamentoRealizadas: event.formasDePagamentoRealizadas
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false),
          valorDesconto: event.valorDesconto,
          descontosItens: event.descontosItens
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false),
          incluirCpfNaNota: event.incluirCpfNaNota,
          cpfNaNota: event.cpfNaNota,
          pontuarFidelidade: event.pontuarFidelidade,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          erro: mensagemDeErroApi(
              e, 'Falha ao preparar a venda. Tente novamente.'),
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
          erro:
              mensagemDeErroApi(e, 'Falha ao criar o pedido. Tente novamente.'),
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

  FutureOr<void> _onOrcamentoSalvarSolicitado(
    VendaOrcamentoSalvarSolicitado event,
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
          erro: 'Adicione ao menos um produto para salvar o orçamento.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        processando: true,
        processoAtual: VendaProcesso.salvarOrcamento,
        erro: null,
      ),
    );

    try {
      final orcamento = await _salvarOrcamento(
        OrcamentoLocal.criar(
          hash: state.orcamentoId,
          clienteId: state.clienteSelecionado?.id,
          clienteNome: state.clienteSelecionado?.nome,
          funcionarioId: state.vendedorSelecionado?.id,
          funcionarioNome: state.vendedorSelecionado?.nome,
          tabelaPrecoId: state.tabelaDePrecoSelecionada?.id,
          tabelaPrecoNome: state.tabelaDePrecoSelecionada?.nome,
          itens: produtos,
        ),
      );

      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          orcamentoId: orcamento.hash,
          orcamentoSalvoContador: state.orcamentoSalvoContador + 1,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          processoAtual: null,
          erro: mensagemDeErroApi(
              e, 'Falha ao salvar o orçamento. Tente novamente.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onOrcamentoCarregarSolicitado(
    VendaOrcamentoCarregarSolicitado event,
    Emitter<VendaState> emit,
  ) async {
    try {
      final orcamento = await _carregarOrcamento(event.hash);
      if (orcamento == null) {
        emit(state.copyWith(erro: 'Orçamento não encontrado.'));
        return;
      }

      emit(
        state.copyWith(
          step: VendaStep.leitura,
          clienteSelecionado: orcamento.clienteId == null
              ? null
              : SelectData(
                  id: orcamento.clienteId!,
                  nome: orcamento.clienteNome ?? '',
                  data: const {},
                ),
          vendedorSelecionado: orcamento.funcionarioId == null
              ? null
              : SelectData(
                  id: orcamento.funcionarioId!,
                  nome: orcamento.funcionarioNome ?? '',
                  data: const {},
                ),
          tabelaDePrecoSelecionada: orcamento.tabelaPrecoId == null
              ? null
              : SelectData(
                  id: orcamento.tabelaPrecoId!,
                  nome: orcamento.tabelaPrecoNome ?? '',
                  data: const {},
                ),
          orcamentoId: orcamento.hash,
          orcamentoItensPreCarregados: orcamento.itens,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          erro: mensagemDeErroApi(e, 'Falha ao carregar o orçamento.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onOrcamentoExcluirAposFinalizarSolicitado(
    VendaOrcamentoExcluirAposFinalizarSolicitado event,
    Emitter<VendaState> emit,
  ) async {
    try {
      await _excluirOrcamento(event.hash);
    } catch (e, s) {
      addError(e, s);
    }
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
