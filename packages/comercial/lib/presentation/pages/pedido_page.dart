import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/relatorios/pdf/nota_entrega_pdf_exporter.dart';
import 'package:comercial/presentation/widgets/impressao_documento_helper.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PedidoPage extends StatefulWidget {
  final int? idPedido;
  final SeletorWidget? pessoaSeletor;
  final SeletorWidget? funcionarioSeletor;
  final SeletorWidget? tabelaDePrecoSeletor;

  const PedidoPage({
    super.key,
    this.idPedido,
    this.pessoaSeletor,
    this.funcionarioSeletor,
    this.tabelaDePrecoSeletor,
  });

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  static const _tipos = [
    'venda',
    'compra',
    'transferencia_saida',
    'transferencia_entrada',
    'taxa_entrega',
  ];

  final _formKey = GlobalKey<FormState>();
  final _pessoaIdController = TextEditingController();
  final _funcionarioIdController = TextEditingController();
  final _tabelaPrecoIdController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _valorTaxaEntregaController = TextEditingController();

  String? _enderecoEntregaResumo;
  bool _criandoPagamento = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pessoaIdController.dispose();
    _funcionarioIdController.dispose();
    _tabelaPrecoIdController.dispose();
    _observacaoController.dispose();
    _valorTaxaEntregaController.dispose();
    super.dispose();
  }

  Future<void> _cancelarPedido() async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar pedido'),
          content: TextField(
            controller: motivoController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Motivo cancelamento'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, motivoController.text.trim()),
              child: const Text('Cancelar pedido'),
            ),
          ],
        );
      },
    );

    if (motivo == null || motivo.isEmpty) return;

    if (!mounted) return;
    context.read<PedidoBloc>().add(PedidoCancelou(motivo));
  }

  Future<void> _selecionarEnderecoEntrega(BuildContext context) async {
    final pessoaId = int.tryParse(_pessoaIdController.text);
    if (pessoaId == null || pessoaId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a pessoa antes de selecionar o endereço.'),
        ),
      );
      return;
    }

    final selecionado = await Navigator.of(context).pushNamed(
      '/selecionar_endereco',
      arguments: {
        'idPessoa': pessoaId,
        'titulo': 'Endereço de entrega',
      },
    ) as Map<String, dynamic>?;

    if (selecionado == null || !mounted) return;

    final id = int.tryParse('${selecionado['id']}');
    if (id == null) return;

    final resumo =
        '${selecionado['logradouro'] ?? ''}, ${selecionado['numero'] ?? ''}'
        ' - ${selecionado['bairro'] ?? ''}';

    setState(() {
      _enderecoEntregaResumo = resumo;
    });

    context.read<PedidoBloc>().add(
          PedidoEnderecoEntregaAlterado(id, enderecoEntregaResumo: resumo),
        );
  }

  double _valorRestantePagamento(PedidoState state) {
    final somaLancada = state.pagamentos.fold<double>(
      0,
      (soma, pagamento) => soma + (pagamento.valorEsperado ?? 0),
    );
    final restante = state.valorTotalItens - somaLancada;
    return restante > 0 ? restante : 0;
  }

  Future<void> _abrirDialogAdicionarPagamento(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();
    final state = bloc.state;

    final tipoEscolhido = await showDialog<TipoOperacaoFormaPagamento>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Como será o pagamento?'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                TipoOperacaoFormaPagamento.manual,
              ),
              child: const ListTile(
                leading: Icon(Icons.local_shipping_outlined),
                title: Text('Pagamento no Ato da Entrega'),
                subtitle: Text(
                  'Dinheiro, cartão ou transferência recebidos presencialmente.',
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                TipoOperacaoFormaPagamento.online,
              ),
              child: const ListTile(
                leading: Icon(Icons.qr_code_2_outlined),
                title: Text('Pagamento Online'),
                subtitle: Text('Cobrança via integração de pagamento.'),
              ),
            ),
          ],
        );
      },
    );

    if (tipoEscolhido == null || !mounted) return;

    final valorRestante = _valorRestantePagamento(state);
    final produtosCompartilhados = state.itens
        .where((item) => item.produtoId != null)
        .map(
          (item) => ProdutoCompartilhado.create(
            produtoId: item.produtoId!,
            quantidade: (item.solicitado ?? 1).round(),
            valorUnitario: item.valorUnitario ?? 0,
            nome: item.referenciaNome ?? '',
            corNome: item.corNome ?? '',
            tamanhoNome: item.tamanhoNome ?? '',
          ),
        )
        .toList(growable: false);

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PagamentosRealizadosWidget(
          hashLista: 'pedido-${state.id}',
          resumoInicial: PagamentosRealizadosResumo(
            listaCompartilhada: null,
            produtosCompartilhados: produtosCompartilhados,
            quantidadeTotalProdutos: produtosCompartilhados.fold<int>(
              0,
              (soma, produto) => soma + produto.quantidade,
            ),
            valorTotalProdutos: valorRestante,
          ),
          pessoaId: int.tryParse(state.pessoaId ?? ''),
          permitirTaxaEntrega: false,
          formasDePagamentoSeletor:
              ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                  FormasDePagamentoSeletor(
                    modo: FormasDePagamentoSeletorModo.unica,
                    itemsSelecionadosInicial: itemsSelecionadosInicial,
                    onChanged: onChanged,
                    onlyView: onlyView ?? false,
                    titulo: 'Forma de pagamento',
                    tipoOperacaoFiltro: tipoEscolhido,
                  ),
        );
      },
    );

    if (resultado == null || !mounted) return;

    final linhas =
        (resultado['formasDePagamentoRealizadas'] as List<dynamic>? ??
                const [])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);

    if (linhas.isEmpty) return;

    if (tipoEscolhido == TipoOperacaoFormaPagamento.online) {
      final totalOnline = linhas.fold<double>(
        0,
        (soma, linha) => soma + (_toDouble(linha['valor']) ?? 0),
      );

      if (!mounted) return;
      final confirmouOnline = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pagamento online'),
            content: Text(
              'Você realmente deseja criar um pagamento online de '
              'R\$ ${totalOnline.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
      if (confirmouOnline != true || !mounted) return;
    }

    final linhasValidas = linhas
        .map((linha) {
          final formaDePagamentoId = int.tryParse(
            '${linha['formaDePagamentoId']}',
          );
          final valor = _toDouble(linha['valor']);
          return (formaDePagamentoId: formaDePagamentoId, valor: valor);
        })
        .where((linha) => linha.formaDePagamentoId != null && (linha.valor ?? 0) > 0)
        .toList(growable: false);

    if (linhasValidas.isEmpty) return;

    setState(() => _criandoPagamento = true);

    for (final linha in linhasValidas) {
      bloc.add(
        PedidoPagamentoAdicionou(
          formaDePagamentoId: linha.formaDePagamentoId!,
          valorEsperado: linha.valor!,
        ),
      );
    }
  }

  Future<void> _removerPagamento(
    BuildContext context,
    PedidoPagamento pagamento,
  ) async {
    final ehOnline = pagamento.tipo == 'controlado';
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover pagamento'),
          content: Text(
            ehOnline
                ? 'Remover esse pagamento? A cobrança online será cancelada '
                    'e o link deixará de funcionar.'
                : 'Remover esse pagamento?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted || pagamento.id == null) return;

    context.read<PedidoBloc>().add(
          PedidoPagamentoRemoveu(pagamentoId: pagamento.id!),
        );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _confirmarPagamentoManual(
    BuildContext context,
    PedidoPagamento pagamento,
  ) async {
    final valorController = TextEditingController(
      text: pagamento.valorEsperado?.toStringAsFixed(2).replaceAll('.', ',') ??
          '',
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar pagamento'),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration:
                const InputDecoration(labelText: 'Valor confirmado (R\$)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final valor = _parseValorReais(valorController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    context.read<PedidoBloc>().add(
          PedidoPagamentoConfirmou(
            pagamentoId: pagamento.id!,
            valorConfirmado: valor,
          ),
        );
  }

  Future<void> _imprimirNotaEntregaDoPedido(
    BuildContext context,
    PedidoState state,
  ) async {
    final enderecoResumo = _enderecoEntregaResumo ?? state.enderecoEntregaResumo;
    if (enderecoResumo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o endereço de entrega antes de imprimir.'),
        ),
      );
      return;
    }

    final numeroPedido = state.id ?? widget.idPedido;
    if (numeroPedido == null) return;

    await imprimirDocumentoPdf(
      context,
      titulo: 'Imprimir nota de entrega',
      nomeDocumento: 'Nota de Entrega - Pedido #$numeroPedido',
      gerarBytes: () async {
        final resultado = await NotaEntregaPdfExporter.gerarBytesParaPedido(
          numeroPedido: numeroPedido,
          pessoaNome: state.pedido?.pessoaNome,
          dataPedido: state.pedido?.criadoEm,
          empresaNome: state.pedido?.empresaNome ?? 'Empresa não identificada',
          empresaCnpj: state.pedido?.empresaCnpj,
          enderecoFormatado: enderecoResumo,
          itens: state.itens,
        );
        return resultado.bytes;
      },
    );
  }

  Future<void> _abrirConverterEmEntrega(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();
    final pessoaId = int.tryParse(_pessoaIdController.text);
    if (pessoaId == null || pessoaId <= 0) return;

    final enderecoSelecionado = await Navigator.of(context).pushNamed(
      '/selecionar_endereco',
      arguments: {
        'idPessoa': pessoaId,
        'titulo': 'Endereço de entrega',
      },
    ) as Map<String, dynamic>?;

    if (enderecoSelecionado == null || !mounted) return;

    final enderecoId = int.tryParse('${enderecoSelecionado['id']}');
    if (enderecoId == null) return;

    final valorController = TextEditingController();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Converter em entrega'),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
                labelText: 'Valor da taxa de entrega (R\$)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Converter'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final valor = _parseValorReais(valorController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    bloc.add(
      PedidoTaxaEntregaCriou(
        valorTaxaEntrega: valor,
        enderecoEntregaId: enderecoId,
      ),
    );
  }

  double? _parseValorReais(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'venda':
        return 'Venda';
      case 'compra':
        return 'Compra';
      case 'transferencia_saida':
        return 'Transferência (saída)';
      case 'transferencia_entrada':
        return 'Transferência (entrada)';
      case 'taxa_entrega':
        return 'Taxa de entrega';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidoBloc>(
      create: (_) =>
          sl<PedidoBloc>()..add(PedidoIniciou(idPedido: widget.idPedido)),
      child: BlocListener<PedidoBloc, PedidoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == PedidoStep.criado ||
              state.step == PedidoStep.salvo) {
            Navigator.of(context).pop(true);
            return;
          }

          if (state.step == PedidoStep.conferido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido conferido com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.faturado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido faturado com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.cancelado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido cancelado com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.itemAdicionado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produto adicionado ao pedido.')),
            );
            return;
          }

          if (state.step == PedidoStep.itemRemovido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item removido do pedido.')),
            );
            return;
          }

          if (state.step == PedidoStep.itemConferido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item conferido.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoAdicionado) {
            setState(() => _criandoPagamento = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento adicionado.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoRemovido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento removido.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoConfirmado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento confirmado.')),
            );
            return;
          }

          if (state.step == PedidoStep.entregadorChamado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entregador chamado.')),
            );
            return;
          }

          if (state.step == PedidoStep.entregaConfirmada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entrega confirmada.')),
            );
            return;
          }

          if (state.step == PedidoStep.taxaEntregaCriada) {
            final novoId = state.pedidoTaxaEntregaCriadoId;
            if (novoId != null) {
              Navigator.of(context).pushReplacementNamed(
                '/pedido',
                arguments: {'idPedido': novoId},
              );
            }
            return;
          }

          if (state.step == PedidoStep.validacaoInvalida ||
              state.step == PedidoStep.falha) {
            if (_criandoPagamento) {
              setState(() => _criandoPagamento = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro ?? 'Falha ao processar pedido.'),
              ),
            );
          }
        },
        child: BlocBuilder<PedidoBloc, PedidoState>(
          builder: (context, state) {
            final carregando = state.step == PedidoStep.carregando ||
                state.step == PedidoStep.salvando ||
                state.step == PedidoStep.processando;

            if (state.step != PedidoStep.carregando) {
              _sincronizarControllers(state);
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.idPedido == null
                    ? 'Novo pedido'
                    : 'Pedido #${widget.idPedido}'),
                actions: [
                  if (carregando)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: carregando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<PedidoBloc>().add(PedidoSalvou());
                        }
                      },
                child: const Icon(Icons.save),
              ),
              body: state.step == PedidoStep.carregando
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child:
                            _buildFormularioPedido(context, state, carregando),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormularioPedido(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCabecalhoPedidoCard(context, state),
        if (state.id != null) ...[
          const SizedBox(height: 16),
          _buildStatusCard(context, state),
        ],
        const SizedBox(height: 16),
        _buildDadosVinculadosCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildEntregaCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildObservacaoCard(context, carregando),
        if (state.id != null) ...[
          const SizedBox(height: 16),
          _buildItensCard(context, state, carregando),
          const SizedBox(height: 16),
          _buildPagamentosCard(context, state),
          const SizedBox(height: 16),
          _buildAcoesDoPedidoCard(context, state, carregando),
          if (state.pedido?.situacao == 'encerrado' &&
              state.modalidadeEntrega == 'retirada') ...[
            const SizedBox(height: 16),
            _buildConverterEntregaCard(context, carregando),
          ],
          const SizedBox(height: 16),
          _buildTimelineCard(context, state),
        ],
      ],
    );
  }

  Widget _buildCabecalhoPedidoCard(BuildContext context, PedidoState state) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text('${state.id ?? widget.idPedido ?? '-'}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${state.id ?? widget.idPedido ?? 'novo'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.pedido?.situacao?.trim().isNotEmpty == true
                            ? 'Situação: ${state.pedido?.situacao}'
                            : 'Situação: em edição',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'Tipo: ${_labelTipo(state.tipo ?? _tipos.first)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PedidoState state) {
    final situacaoPagamento = state.pedido?.situacaoPagamento;
    final situacaoEntrega = state.pedido?.situacaoEntrega;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(context, 'Status', Icons.info_outline),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(
                  context,
                  label:
                      'Pagamento: ${_labelSituacaoPagamento(situacaoPagamento)}',
                  cor: _corSituacaoPagamento(situacaoPagamento),
                ),
                if (state.modalidadeEntrega == 'entrega')
                  _buildStatusChip(
                    context,
                    label: 'Entrega: ${_labelSituacaoEntrega(situacaoEntrega)}',
                    cor: _corSituacaoEntrega(situacaoEntrega),
                  ),
              ],
            ),
            if (!state.podeFechar && state.pedido?.situacao != 'encerrado') ...[
              const SizedBox(height: 8),
              Text(
                state.motivoNaoPodeFechar,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: cor, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _labelSituacaoPagamento(String? situacao) {
    switch (situacao) {
      case 'pendente':
        return 'Pendente';
      case 'parcial':
        return 'Parcial';
      case 'pago':
        return 'Pago';
      default:
        return situacao ?? '-';
    }
  }

  Color _corSituacaoPagamento(String? situacao) {
    switch (situacao) {
      case 'pago':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _labelSituacaoEntrega(String? situacao) {
    switch (situacao) {
      case 'nao_aplicavel':
        return 'Não aplicável';
      case 'aguardando_chamada':
        return 'Aguardando chamada';
      case 'chamado':
        return 'Entregador chamado';
      case 'entregue':
        return 'Entregue';
      default:
        return situacao ?? '-';
    }
  }

  Color _corSituacaoEntrega(String? situacao) {
    switch (situacao) {
      case 'entregue':
        return Colors.green;
      case 'chamado':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildDadosVinculadosCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final onlyView = widget.idPedido != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Dados vinculados',
              Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            if (onlyView) ...[
              _buildInfoLinha(
                context,
                icone: Icons.person_outline,
                titulo: 'Pessoa',
                valor: _valorOuFallback(
                  state.pedido?.pessoaNome,
                  fallback: state.pessoaId?.trim().isNotEmpty == true
                      ? 'Pessoa #${state.pessoaId}'
                      : '-',
                ),
              ),
              const Divider(height: 24),
              _buildInfoLinha(
                context,
                icone: Icons.badge,
                titulo: 'Funcionário',
                valor: _valorOuFallback(
                  state.pedido?.funcionarioNome,
                  fallback: state.funcionarioId?.trim().isNotEmpty == true
                      ? 'Funcionário #${state.funcionarioId}'
                      : '-',
                ),
              ),
              const Divider(height: 24),
              _buildInfoLinha(
                context,
                icone: Icons.sell_outlined,
                titulo: 'Tabela de preço',
                valor: _valorOuFallback(
                  state.pedido?.tabelaPrecoNome,
                  fallback: state.tabelaPrecoId?.trim().isNotEmpty == true
                      ? 'Tabela de preço #${state.tabelaPrecoId}'
                      : '-',
                ),
              ),
            ] else ...[
              if (widget.pessoaSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.pessoaSeletor!.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial: _selectDataInicial(
                            idTexto: state.pessoaId,
                            nomeFallback: state.pedido?.pessoaNome ??
                                'Pessoa selecionada',
                          ) ??
                          const [],
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        pessoaId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _pessoaIdController,
                  label: 'Pessoa ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    pessoaId: value,
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.funcionarioSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.funcionarioSeletor!.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial: _selectDataInicial(
                            idTexto: state.funcionarioId,
                            nomeFallback: state.pedido?.funcionarioNome ??
                                'Funcionário selecionado',
                          ) ??
                          const [],
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        funcionarioId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _funcionarioIdController,
                  label: 'Funcionário ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    funcionarioId: value,
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.tabelaDePrecoSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.tabelaDePrecoSeletor!.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial: _selectDataInicial(
                        idTexto: state.tabelaPrecoId,
                        nomeFallback: state.pedido?.tabelaPrecoNome ??
                            'Tabela selecionada',
                      ),
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        tabelaPrecoId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _tabelaPrecoIdController,
                  label: 'Tabela de preço ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    tabelaPrecoId: value,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntregaCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Modalidade de entrega',
              Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'retirada', label: Text('Retirada')),
                ButtonSegment(value: 'entrega', label: Text('Entrega')),
              ],
              selected: {state.modalidadeEntrega},
              onSelectionChanged: carregando
                  ? null
                  : (selecao) => context.read<PedidoBloc>().add(
                        PedidoModalidadeEntregaAlterada(selecao.first),
                      ),
            ),
            if (state.modalidadeEntrega == 'entrega') ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: carregando
                    ? null
                    : () => _selecionarEnderecoEntrega(context),
                icon: const Icon(Icons.location_on_outlined),
                label: Text(
                  state.enderecoEntregaId == null
                      ? 'Selecionar endereço de entrega'
                      : (_enderecoEntregaResumo ??
                          state.enderecoEntregaResumo ??
                          'Endereço #${state.enderecoEntregaId}'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorTaxaEntregaController,
                readOnly: carregando,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Valor da taxa de entrega (R\$)',
                ),
                onChanged: (value) => _onCampoAlterado(
                  context,
                  valorTaxaEntrega: value,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObservacaoCard(BuildContext context, bool carregando) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Observação',
              Icons.edit_note_outlined,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacaoController,
              maxLines: 3,
              readOnly: carregando,
              decoration: const InputDecoration(
                labelText: 'Observação',
              ),
              onChanged: (value) => _onCampoAlterado(
                context,
                observacao: value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final podeEditarItens = state.pedido?.situacao == 'em_andamento';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTituloSecao(
                    context,
                    'Itens do pedido',
                    Icons.list_alt_outlined,
                  ),
                ),
                TextButton.icon(
                  onPressed: (carregando || !podeEditarItens)
                      ? null
                      : () => _abrirAdicionarItem(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar produto'),
                ),
              ],
            ),
            if (!podeEditarItens) ...[
              const SizedBox(height: 4),
              Text(
                'Itens só podem ser adicionados ou removidos enquanto o '
                'pedido está em andamento.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            if (state.itens.isEmpty)
              const Text('Nenhum item adicionado ainda.')
            else
              ...state.itens.asMap().entries.map(
                    (entry) => _buildItemPedido(
                      context,
                      entry.value,
                      entry.key,
                      podeEditarItens && !carregando,
                    ),
                  ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total dos itens',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'R\$ ${state.valorTotalItens.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPedido(
    BuildContext context,
    PedidoItem item,
    int index,
    bool podeEditar,
  ) {
    final theme = Theme.of(context);
    final unitario = item.valorUnitario ?? 0;
    final desconto = item.valorUnitDesconto ?? 0;
    final solicitado = item.solicitado ?? 0;
    final atendido = item.atendido ?? 0;
    final subtotal = (unitario - desconto) * solicitado;
    final corNome = item.corNome ?? '';
    final tamanhoNome = item.tamanhoNome ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.referenciaNome?.trim().isNotEmpty == true
                        ? item.referenciaNome!
                        : 'Produto #${item.produtoId ?? '-'}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (corNome.isNotEmpty || tamanhoNome.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (corNome.isNotEmpty) 'Cor: $corNome',
                        if (tamanhoNome.isNotEmpty) 'Tamanho: $tamanhoNome',
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Qtd solicitada: ${solicitado.toStringAsFixed(3)}'
                    '${atendido > 0 ? ' · Atendida: ${atendido.toStringAsFixed(3)}' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vlr. unit.: R\$ ${unitario.toStringAsFixed(2)}'
                    '${desconto > 0 ? '  •  Desconto: R\$ ${desconto.toStringAsFixed(2)}' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Qtd.', style: theme.textTheme.labelSmall),
                  Text(
                    solicitado.toStringAsFixed(3),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (podeEditar)
              IconButton(
                onPressed: () => _confirmarRemoverItem(context, item),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remover item',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirAdicionarItem(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();

    final idsSelecionados = await Navigator.of(context).pushNamed(
      '/selecionar_produtos',
    ) as List<dynamic>?;

    if (idsSelecionados == null || idsSelecionados.isEmpty || !mounted) {
      return;
    }

    final produtoIds = idsSelecionados
        .map((e) => e is int ? e : int.tryParse(e.toString()))
        .whereType<int>()
        .toList();

    if (produtoIds.isEmpty) return;

    final quantidadeController = TextEditingController(text: '1');
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            produtoIds.length == 1
                ? 'Quantidade do produto'
                : 'Quantidade para cada produto selecionado',
          ),
          content: TextField(
            controller: quantidadeController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(labelText: 'Quantidade'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final quantidade = _parseValorReais(quantidadeController.text);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }

    for (final produtoId in produtoIds) {
      bloc.add(
        PedidoItemAdicionou(produtoId: produtoId, quantidade: quantidade),
      );
    }
  }

  Future<void> _confirmarRemoverItem(
    BuildContext context,
    PedidoItem item,
  ) async {
    final bloc = context.read<PedidoBloc>();
    final quantidadeController = TextEditingController(
      text: (item.solicitado ?? 0).toStringAsFixed(3),
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remover produto #${item.produtoId}'),
          content: TextField(
            controller: quantidadeController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration:
                const InputDecoration(labelText: 'Quantidade a remover'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final quantidade = _parseValorReais(quantidadeController.text);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }

    if (item.produtoId == null || item.sequencia == null) return;

    bloc.add(
      PedidoItemRemoveu(
        produtoId: item.produtoId!,
        sequencia: item.sequencia!,
        quantidade: quantidade,
      ),
    );
  }

  Widget _buildPagamentosCard(BuildContext context, PedidoState state) {
    final valorRestante = _valorRestantePagamento(state);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTituloSecao(
                    context,
                    'Pagamentos',
                    Icons.payments_outlined,
                  ),
                ),
                TextButton.icon(
                  onPressed: _criandoPagamento
                      ? null
                      : () => _abrirDialogAdicionarPagamento(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Valor restante: R\$ ${valorRestante.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valorRestante > 0 ? Colors.orange : Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            if (state.pagamentos.isEmpty)
              const Text('Nenhum pagamento adicionado ainda.')
            else
              ...state.pagamentos.map(
                (pagamento) => _buildPagamentoItem(
                  context,
                  pagamento,
                  state.formasDePagamentoPorId,
                ),
              ),
            if (_criandoPagamento) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Criando pagamento...'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagamentoItem(
    BuildContext context,
    PedidoPagamento pagamento,
    Map<int, String> formasDePagamentoPorId,
  ) {
    final confirmado = pagamento.confirmadoEm != null;
    final ehOnline = pagamento.tipo == 'controlado';
    final label = ehOnline
        ? (confirmado
            ? 'Confirmado (pagamento online)'
            : 'Aguardando confirmação do pagamento online')
        : (confirmado ? 'Confirmado' : 'Aguardando confirmação manual');
    final nomeForma = formasDePagamentoPorId[pagamento.formaDePagamentoId] ??
        'Forma #${pagamento.formaDePagamentoId ?? '-'}';
    final cobranca = pagamento.cobranca;
    final linkCobranca = cobranca?.urlDePagamento ?? cobranca?.chavePixCopiaECola;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeForma,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Esperado: R\$ ${(pagamento.valorEsperado ?? 0).toStringAsFixed(2)}'
                      '${pagamento.valorConfirmado != null ? ' · Confirmado: R\$ ${pagamento.valorConfirmado!.toStringAsFixed(2)}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: confirmado ? Colors.green : Colors.orange,
                          ),
                    ),
                  ],
                ),
              ),
              if (!confirmado && !ehOnline)
                TextButton(
                  onPressed: () =>
                      _confirmarPagamentoManual(context, pagamento),
                  child: const Text('Confirmar'),
                ),
              if (!confirmado)
                IconButton(
                  tooltip: 'Remover pagamento',
                  onPressed: () => _removerPagamento(context, pagamento),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          if (!confirmado && ehOnline && linkCobranca != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Envie ao cliente (R\$ ${(pagamento.valorEsperado ?? 0).toStringAsFixed(2)}):',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    linkCobranca,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAcoesDoPedidoCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final podeFechar = state.podeFechar;
    // Pedido de origem "atendente_humano" (único canal existente hoje) dispensa a etapa de
    // conferência -- backend já libera faturar sem exigir situacao="conferido" pra essa origem.
    final exigeConferencia = state.pedido?.origem != 'atendente_humano';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Ações do pedido',
              Icons.bolt_outlined,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (exigeConferencia)
                  FilledButton.icon(
                    onPressed: carregando
                        ? null
                        : () {
                            context.read<PedidoBloc>().add(
                                  PedidoConferiu(),
                                );
                          },
                    icon: const Icon(Icons.fact_check),
                    label: const Text('Conferir'),
                  ),
                Tooltip(
                  message: podeFechar ? '' : state.motivoNaoPodeFechar,
                  child: FilledButton.icon(
                    onPressed: carregando || !podeFechar
                        ? null
                        : () {
                            context.read<PedidoBloc>().add(
                                  PedidoFaturou(),
                                );
                          },
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text('Faturar'),
                  ),
                ),
                if (state.modalidadeEntrega == 'entrega')
                  OutlinedButton.icon(
                    onPressed: carregando
                        ? null
                        : () => _imprimirNotaEntregaDoPedido(context, state),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Imprimir nota de entrega'),
                  ),
                if (state.pedido?.romaneioId != null)
                  OutlinedButton.icon(
                    onPressed: carregando
                        ? null
                        : () => Navigator.of(context).pushNamed(
                              '/romaneio',
                              arguments: {
                                'idRomaneio': state.pedido!.romaneioId,
                                'permitirEdicao': false,
                              },
                            ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Ver romaneio'),
                  ),
                if (state.modalidadeEntrega == 'entrega' &&
                    state.pedido?.situacaoEntrega == 'aguardando_chamada')
                  OutlinedButton.icon(
                    onPressed: carregando
                        ? null
                        : () => context
                            .read<PedidoBloc>()
                            .add(PedidoEntregadorChamou()),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Chamar entregador'),
                  ),
                if (state.modalidadeEntrega == 'entrega' &&
                    state.pedido?.situacaoEntrega == 'chamado')
                  OutlinedButton.icon(
                    onPressed: carregando
                        ? null
                        : () => context
                            .read<PedidoBloc>()
                            .add(PedidoEntregaConfirmou()),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar entrega'),
                  ),
                OutlinedButton.icon(
                  onPressed: carregando ? null : _cancelarPedido,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                ),
              ],
            ),
            if (state.pedido?.situacao != null) ...[
              const SizedBox(height: 8),
              Text('Situação atual: ${state.pedido?.situacao}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConverterEntregaCard(BuildContext context, bool carregando) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Converter em entrega',
              Icons.change_circle_outlined,
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido encerrado como retirada. Se o cliente pedir entrega '
              'depois, gere um pedido complemento com a taxa de entrega.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed:
                  carregando ? null : () => _abrirConverterEmEntrega(context),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Converter em entrega'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, PedidoState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(context, 'Histórico', Icons.history),
            const SizedBox(height: 12),
            if (state.eventos.isEmpty)
              const Text('Nenhum evento registrado ainda.')
            else
              ...state.eventos
                  .map((evento) => _buildEventoItem(context, evento)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoItem(BuildContext context, PedidoEvento evento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconeEvento(evento.tipo), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_labelEvento(evento.tipo)),
                if ((evento.observacao ?? '').trim().isNotEmpty)
                  Text(
                    evento.observacao!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (evento.criadoEm != null)
                  Text(
                    _formatarDataHoraEvento(evento.criadoEm),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarDataHoraEvento(DateTime? data) {
    if (data == null) return '-';
    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  IconData _iconeEvento(String? tipo) {
    switch (tipo) {
      case 'criado':
        return Icons.add_circle_outline;
      case 'atualizado':
        return Icons.edit_outlined;
      case 'conferido':
        return Icons.fact_check_outlined;
      case 'item_adicionado':
        return Icons.add_shopping_cart_outlined;
      case 'item_removido':
        return Icons.remove_shopping_cart_outlined;
      case 'item_conferido':
        return Icons.checklist_outlined;
      case 'pagamento_adicionado':
        return Icons.add_card_outlined;
      case 'pagamento_removido':
        return Icons.money_off_outlined;
      case 'pagamento_confirmado':
        return Icons.payments_outlined;
      case 'nota_emitida':
        return Icons.description_outlined;
      case 'entregador_chamado':
        return Icons.delivery_dining;
      case 'entrega_confirmada':
        return Icons.check_circle_outline;
      case 'encerrado':
        return Icons.lock_outline;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _labelEvento(String? tipo) {
    switch (tipo) {
      case 'criado':
        return 'Pedido criado';
      case 'atualizado':
        return 'Pedido atualizado';
      case 'conferido':
        return 'Pedido conferido';
      case 'item_adicionado':
        return 'Item adicionado';
      case 'item_removido':
        return 'Item removido';
      case 'item_conferido':
        return 'Itens conferidos';
      case 'pagamento_adicionado':
        return 'Pagamento adicionado';
      case 'pagamento_removido':
        return 'Pagamento removido';
      case 'pagamento_confirmado':
        return 'Pagamento confirmado';
      case 'nota_emitida':
        return 'Nota emitida';
      case 'entregador_chamado':
        return 'Entregador chamado';
      case 'entrega_confirmada':
        return 'Entrega confirmada';
      case 'encerrado':
        return 'Pedido encerrado';
      case 'cancelado':
        return 'Pedido cancelado';
      default:
        return tipo ?? '-';
    }
  }

  Widget _buildTituloSecao(
    BuildContext context,
    String titulo,
    IconData icone,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icone, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildInfoLinha(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String valor,
    String? complemento,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            icone,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                valor,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (complemento != null && complemento.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  complemento,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _valorOuFallback(String? valor, {String fallback = '-'}) {
    if (valor == null || valor.trim().isEmpty) {
      return fallback;
    }
    return valor.trim();
  }

  Widget _campoNumero({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatorio';
        }
        return null;
      },
    );
  }

  List<SelectData>? _selectDataInicial({
    required String? idTexto,
    required String nomeFallback,
  }) {
    final id = int.tryParse(idTexto ?? '');
    if (id == null || id <= 0) {
      return null;
    }

    return [
      SelectData(
        id: id,
        nome: nomeFallback,
        data: {'id': id, 'nome': nomeFallback},
      ),
    ];
  }

  void _sincronizarControllers(PedidoState state) {
    _sincronizarController(_pessoaIdController, state.pessoaId ?? '');
    _sincronizarController(_funcionarioIdController, state.funcionarioId ?? '');
    _sincronizarController(_tabelaPrecoIdController, state.tabelaPrecoId ?? '');
    _sincronizarController(_observacaoController, state.observacao ?? '');
    _sincronizarController(
      _valorTaxaEntregaController,
      state.valorTaxaEntrega ?? '',
    );
  }

  void _sincronizarController(TextEditingController controller, String value) {
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? pessoaId,
    String? funcionarioId,
    String? tabelaPrecoId,
    String? parcelas,
    String? intervalo,
    String? dataBasePagamento,
    String? previsaoDeFaturamento,
    String? previsaoDeEntrega,
    String? tipo,
    bool? fiscal,
    String? observacao,
    String? valorTaxaEntrega,
  }) {
    context.read<PedidoBloc>().add(
          PedidoCampoAlterado(
            pessoaId: pessoaId,
            funcionarioId: funcionarioId,
            tabelaPrecoId: tabelaPrecoId,
            parcelas: parcelas,
            intervalo: intervalo,
            dataBasePagamento: dataBasePagamento,
            previsaoDeFaturamento: previsaoDeFaturamento,
            previsaoDeEntrega: previsaoDeEntrega,
            tipo: tipo,
            fiscal: fiscal,
            observacao: observacao,
            valorTaxaEntrega: valorTaxaEntrega,
          ),
        );
  }
}
