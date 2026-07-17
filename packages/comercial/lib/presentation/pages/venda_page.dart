import 'package:comercial/presentation.dart';
import 'package:comercial/models.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

const String _resultadoRomaneioStatusKey = 'status';
const String _resultadoRomaneioIdKey = 'romaneioId';
const String _resultadoRomaneioStatusSucesso = 'sucesso';
const String _resultadoRomaneioStatusFalha = 'falha';
const String _resultadoRomaneioStatusParcial = 'parcial';

class VendaPage extends StatefulWidget {
  final SeletorWidget pessoaSeletor;
  final SeletorWidget vendedoresSeletor;
  final SeletorWidget tabelasDePrecoSeletor;
  final SeletorWidget formasDePagamentoSeletor;

  const VendaPage({
    super.key,
    required this.pessoaSeletor,
    required this.vendedoresSeletor,
    required this.tabelasDePrecoSeletor,
    required this.formasDePagamentoSeletor,
  });

  @override
  State<VendaPage> createState() => _VendaPageState();
}

enum _VendaAcao { finalizar }

class _VendaPageState extends State<VendaPage> {
  late final LeitorController _leitorController;
  int _ultimoOrcamentoSalvoContador = 0;

  @override
  void initState() {
    super.initState();
    _leitorController = LeitorController();
  }

  @override
  void dispose() {
    _leitorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VendaBloc>(
      create: (_) => sl<VendaBloc>()
        ..add(const VendaClienteNaoCadastradoSolicitado()),
      child: BlocConsumer<VendaBloc, VendaState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.listaCompartilhadaHash !=
                    current.listaCompartilhadaHash &&
                current.listaCompartilhadaHash != null) ||
            (previous.pedidoCriadoId != current.pedidoCriadoId &&
                current.pedidoCriadoId != null) ||
            previous.orcamentoSalvoContador != current.orcamentoSalvoContador,
        listener: (context, state) async {
          final erro = state.erro;
          if (erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(erro),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state.orcamentoSalvoContador != _ultimoOrcamentoSalvoContador) {
            _ultimoOrcamentoSalvoContador = state.orcamentoSalvoContador;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Orçamento salvo com sucesso.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _reiniciarFluxo(context);
            return;
          }

          final listaCompartilhadaHash = state.listaCompartilhadaHash;
          if (listaCompartilhadaHash != null) {
            final result = await Navigator.of(context).pushNamed(
              '/criar_romaneio_por_parametros',
              arguments: {
                'listaCompartilhadaHash': listaCompartilhadaHash,
                'formasDePagamentoRealizadas':
                    state.formasDePagamentoRealizadas,
                'desconto': state.valorDesconto,
                'descontosItens': state.descontosItens,
                'incluirCpfNaNota': state.incluirCpfNaNota,
                'cpfNaNota': state.cpfNaNota,
                'pontuarFidelidade': state.pontuarFidelidade,
              },
            );

            if (!context.mounted) return;

            final resultadoStatus = result is Map<String, dynamic>
                ? result[_resultadoRomaneioStatusKey]?.toString()
                : result == true
                    ? _resultadoRomaneioStatusSucesso
                    : null;
            final resultadoRomaneioId = result is Map<String, dynamic>
                ? result[_resultadoRomaneioIdKey]
                : null;

            if (resultadoStatus == _resultadoRomaneioStatusSucesso) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Venda finalizada com sucesso.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              final orcamentoId = state.orcamentoId;
              if (orcamentoId != null) {
                context.read<VendaBloc>().add(
                      VendaOrcamentoExcluirAposFinalizarSolicitado(
                        hash: orcamentoId,
                      ),
                    );
              }
              _reiniciarFluxo(context);
              return;
            }

            if (resultadoStatus == _resultadoRomaneioStatusFalha) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível concluir a venda.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            if (resultadoStatus == _resultadoRomaneioStatusParcial) {
              final romaneioId = resultadoRomaneioId?.toString() ?? '-';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Venda gerou o romaneio #$romaneioId, mas o processamento não foi concluído automaticamente.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              final orcamentoId = state.orcamentoId;
              if (orcamentoId != null) {
                context.read<VendaBloc>().add(
                      VendaOrcamentoExcluirAposFinalizarSolicitado(
                        hash: orcamentoId,
                      ),
                    );
              }
              _reiniciarFluxo(context);
            }
          }

          final pedidoCriadoId = state.pedidoCriadoId;
          if (pedidoCriadoId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pedido #$pedidoCriadoId criado com sucesso.'),
                behavior: SnackBarBehavior.floating,
              ),
            );

            _reiniciarFluxo(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Venda')),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      12 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!state.leituraIniciada) ...[
                            _buildConfiguracaoCard(context, state),
                            const SizedBox(height: 10),
                          ],
                          if (state.leituraIniciada) ...[
                            _buildResumoDaVenda(context, state),
                            const SizedBox(height: 10),
                            LeitorWidget(
                              controller: _leitorController,
                              dataSource: sl(),
                              buscaDataSource: sl(),
                              tabelaDePrecoId: state.tabelaDePrecoId,
                              aceitarApenasProdutosComPreco: true,
                              controlarQuantidade: true,
                              campoCodigoHint:
                                  'Bipe ou informe o código do produto',
                              produtosPreCarregados: state
                                      .orcamentoItensPreCarregados.isEmpty
                                  ? null
                                  : state.orcamentoItensPreCarregados
                                      .map(
                                        (item) => ProdutosPreCarregado(
                                          id: item.produtoId,
                                          quantidade: item.quantidade,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ] else
                            _buildEstadoInicial(context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfiguracaoCard(BuildContext context, VendaState state) {
    final bloc = context.read<VendaBloc>();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iniciar venda', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AbsorbPointer(
              absorbing: state.processando,
              child: Column(
                children: [
                  widget.pessoaSeletor.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial: state.clienteSelecionado == null
                          ? null
                          : [state.clienteSelecionado!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaClienteSelecionado(
                            clienteSelecionado: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.vendedoresSeletor.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial:
                          state.vendedorSelecionado == null
                              ? null
                              : [state.vendedorSelecionado!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaVendedorSelecionado(
                            vendedorSelecionado: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.tabelasDePrecoSeletor.buildComParametros(
                    SeletorParamentros(
                      itemsSelecionadosInicial:
                          state.tabelaDePrecoSelecionada == null
                              ? null
                              : [state.tabelaDePrecoSelecionada!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaTabelaDePrecoSelecionada(
                            tabelaDePrecoSelecionada: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: state.estadoInicial
                      ? () => _abrirOrcamentos(context)
                      : null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Orçamentos'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.podeIniciarLeitura
                      ? () => bloc.add(const VendaLeituraSolicitada())
                      : null,
                  icon: state.verificandoCaixa
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_outlined),
                  label: Text(
                    state.verificandoCaixa
                        ? 'Verificando caixa...'
                        : 'Iniciar venda',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoDaVenda(BuildContext context, VendaState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<VendaBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.person_outline,
                        label:
                            'Cliente: ${state.clienteSelecionado?.nome ?? '-'}',
                      ),
                      _buildInfoChip(
                        icon: Icons.badge_outlined,
                        label:
                            'Vendedor: ${state.vendedorSelecionado?.nome ?? '-'}',
                      ),
                      _buildInfoChip(
                        icon: Icons.sell_outlined,
                        label:
                            'Tabela: ${state.tabelaDePrecoSelecionada?.nome ?? '-'}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Alterar cliente, vendedor ou tabela de preço',
                  onPressed: state.processando
                      ? null
                      : () => bloc.add(const VendaEdicaoSolicitada()),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _leitorController,
              builder: (context, _) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusBox(
                      context,
                      titulo: 'Quantidade total',
                      valor: '${_leitorController.quantidadeTotalLida}',
                      colorScheme: colorScheme,
                    ),
                    _buildStatusBox(
                      context,
                      titulo: 'Valor total',
                      valor: _formatarMoeda(_leitorController.valorTotalLido),
                      colorScheme: colorScheme,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _leitorController,
              builder: (context, _) {
                final temItens = _leitorController.itens.isNotEmpty;
                final labelFinalizar =
                    state.processoAtual == VendaProcesso.finalizarVenda
                        ? 'Encaminhando...'
                        : 'Finalizar e ir ao caixa';

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: temItens && !state.processando
                          ? () => _confirmarReinicio(context)
                          : null,
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('Reiniciar contagem'),
                    ),
                    OutlinedButton.icon(
                      onPressed: temItens && !state.processando
                          ? () => _salvarOrcamento(context)
                          : null,
                      icon: state.processoAtual == VendaProcesso.salvarOrcamento
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Salvar orçamento'),
                    ),
                    FilledButton.icon(
                      onPressed: temItens && !state.processando
                          ? () => _abrirConfirmacao(
                              context, state, _VendaAcao.finalizar)
                          : null,
                      icon: state.processoAtual == VendaProcesso.finalizarVenda
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.point_of_sale_outlined),
                      label: Text(labelFinalizar),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoInicial(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_checkout_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Pronto para iniciar a venda',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Defina o cliente, o vendedor e a tabela de preço para começar a leitura dos produtos.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirConfirmacao(
    BuildContext context,
    VendaState state,
    _VendaAcao acao,
  ) async {
    final bloc = context.read<VendaBloc>();
    final clienteSelecionado = state.clienteSelecionado;
    final vendedorSelecionado = state.vendedorSelecionado;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar finalização da venda'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confira o resumo antes de continuar.',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoChip(
                    icon: Icons.person_outline,
                    label: 'Cliente: ${clienteSelecionado?.nome ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.badge_outlined,
                    label: 'Vendedor: ${vendedorSelecionado?.nome ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.numbers_outlined,
                    label:
                        'Quantidade de produtos: ${_leitorController.quantidadeTotalLida}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.payments_outlined,
                    label:
                        'Valor total do pedido: ${_formatarMoeda(_leitorController.valorTotalLido)}',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Finalizar venda'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    final itens = _leitorController.itens
        .map(
          (item) => {
            'produtoId': item.id,
            'quantidade': item.quantidadeLida,
            'valorUnitario': item.valorUnitario,
            'nome': item.descricao,
            'corNome': item.cor,
            'tamanhoNome': item.tamanho,
          },
        )
        .toList(growable: false);

    final pagamentoResultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PagamentosRealizadosWidget(
          hashLista: state.listaCompartilhadaHash ?? '',
          resumoInicial: PagamentosRealizadosResumo(
            listaCompartilhada: null,
            produtosCompartilhados: _leitorController.itens
                .map(
                  (item) => ProdutoCompartilhado.create(
                    produtoId: item.id,
                    quantidade: item.quantidadeLida,
                    valorUnitario: item.valorUnitario ?? 0,
                    nome: item.descricao,
                    corNome: item.cor,
                    tamanhoNome: item.tamanho,
                  ),
                )
                .toList(),
            quantidadeTotalProdutos: _leitorController.quantidadeTotalLida,
            valorTotalProdutos: _leitorController.valorTotalLido,
          ),
          pessoaId: clienteSelecionado?.id,
          cpfClienteInicial: clienteSelecionado?.data['documento']?.toString(),
          clienteGenerico: clienteSelecionado?.data['generica'] == true,
          formasDePagamentoSeletor: widget.formasDePagamentoSeletor,
          exibirCheckboxFidelidade: true,
        );
      },
    );

    if (pagamentoResultado == null) {
      return;
    }

    final formasDePagamentoRaw =
        pagamentoResultado['formasDePagamentoRealizadas'] as List<dynamic>? ??
            const [];
    final formasDePagamentoRealizadas = formasDePagamentoRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final valorDesconto = _toDouble(pagamentoResultado['desconto']) ?? 0;
    final descontosItensRaw =
        pagamentoResultado['descontosItens'] as List<dynamic>? ?? const [];
    final descontosItens = descontosItensRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final incluirCpfNaNota =
        pagamentoResultado['incluirCpfNaNota'] as bool? ?? true;
    final cpfNaNota = pagamentoResultado['cpfNaNota']?.toString() ?? '';
    final pontuarFidelidade =
        pagamentoResultado['pontuarFidelidade'] as bool? ?? false;

    final confirmouEmissao = await _abrirConfirmacaoEmissao(
      context,
      pagamentoResultado: pagamentoResultado,
      valorDesconto: valorDesconto,
    );

    if (confirmouEmissao != true) {
      return;
    }

    bloc.add(
      VendaFinalizarSolicitada(
        itens: itens,
        formasDePagamentoRealizadas: formasDePagamentoRealizadas,
        valorDesconto: valorDesconto,
        descontosItens: descontosItens,
        incluirCpfNaNota: incluirCpfNaNota,
        cpfNaNota: cpfNaNota,
        pontuarFidelidade: pontuarFidelidade,
      ),
    );
  }

  Future<bool?> _abrirConfirmacaoEmissao(
    BuildContext context, {
    required Map<String, dynamic> pagamentoResultado,
    required double valorDesconto,
  }) {
    final resumoFormasRaw =
        pagamentoResultado['resumoFormasDePagamento'] as List<dynamic>? ??
            const [];
    final resumoFormas = resumoFormasRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => (
            nome: item['nome']?.toString() ?? '-',
            valor: _toDouble(item['valor']) ?? 0,
          ),
        )
        .toList(growable: false);
    final valorTotalRecebido =
        _toDouble(pagamentoResultado['valorTotalRecebido']) ?? 0;
    final valorTroco = _toDouble(pagamentoResultado['valorTroco']) ?? 0;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar pagamento e emitir romaneio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao confirmar, o romaneio será gerado e o estoque baixado. Confira o pagamento:',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoChip(
                    icon: Icons.receipt_long_outlined,
                    label:
                        'Valor total do pedido: ${_formatarMoeda(_leitorController.valorTotalLido)}',
                  ),
                  const SizedBox(height: 12),
                  ...resumoFormas.map(
                    (forma) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildInfoChip(
                        icon: Icons.payments_outlined,
                        label: '${forma.nome}: ${_formatarMoeda(forma.valor)}',
                      ),
                    ),
                  ),
                  if (valorDesconto > 0) ...[
                    const Divider(height: 16),
                    _buildInfoChip(
                      icon: Icons.discount_outlined,
                      label: 'Desconto aplicado: ${_formatarMoeda(valorDesconto)}',
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const Divider(height: 16),
                  _buildInfoChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Total recebido: ${_formatarMoeda(valorTotalRecebido)}',
                  ),
                  if (valorTroco > 0) ...[
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      icon: Icons.currency_exchange_outlined,
                      label: 'Troco: ${_formatarMoeda(valorTroco)}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar e emitir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarReinicio(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reiniciar contagem'),
          content: const Text(
            'Deseja realmente limpar os itens lidos e reiniciar a contagem desta venda?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      _leitorController.limpar();
    }
  }

  void _salvarOrcamento(BuildContext context) {
    final itens = _leitorController.itens
        .map(
          (item) => {
            'produtoId': item.id,
            'quantidade': item.quantidadeLida,
            'valorUnitario': item.valorUnitario,
            'nome': item.descricao,
            'corNome': item.cor,
            'tamanhoNome': item.tamanho,
          },
        )
        .toList(growable: false);

    context.read<VendaBloc>().add(VendaOrcamentoSalvarSolicitado(itens: itens));
  }

  Future<void> _abrirOrcamentos(BuildContext context) async {
    final bloc = context.read<VendaBloc>();
    final hashSelecionado = await Navigator.of(context).pushNamed(
      '/orcamentos',
    );

    if (hashSelecionado is String && hashSelecionado.isNotEmpty) {
      bloc.add(VendaOrcamentoCarregarSolicitado(hash: hashSelecionado));
    }
  }

  void _reiniciarFluxo(BuildContext context) {
    _leitorController.limpar();
    _ultimoOrcamentoSalvoContador = 0;
    context.read<VendaBloc>().add(const VendaResetSolicitado());
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildStatusBox(
    BuildContext context, {
    required String titulo,
    required String valor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            valor,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
