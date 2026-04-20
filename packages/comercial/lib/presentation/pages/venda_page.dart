import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
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

  const VendaPage({
    super.key,
    required this.pessoaSeletor,
    required this.vendedoresSeletor,
    required this.tabelasDePrecoSeletor,
  });

  @override
  State<VendaPage> createState() => _VendaPageState();
}

enum _VendaAcao { finalizar, criarPedido }

class _VendaPageState extends State<VendaPage> {
  late final LeitorController _leitorController;

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
      create: (_) => sl<VendaBloc>(),
      child: BlocConsumer<VendaBloc, VendaState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.listaCompartilhadaHash !=
                    current.listaCompartilhadaHash &&
                current.listaCompartilhadaHash != null) ||
            (previous.pedidoCriadoId != current.pedidoCriadoId &&
                current.pedidoCriadoId != null),
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

          final listaCompartilhadaHash = state.listaCompartilhadaHash;
          if (listaCompartilhadaHash != null) {
            final result = await Navigator.of(context).pushNamed(
              '/criar_romaneio_por_parametros',
              arguments: {
                'listaCompartilhadaHash': listaCompartilhadaHash,
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
                  content: Text('Venda finalizada e encaminhada ao caixa.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
                    'Venda gerou o romaneio #$romaneioId, mas o encaminhamento ao caixa precisa ser concluído manualmente.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildConfiguracaoCard(context, state),
                          const SizedBox(height: 16),
                          if (state.leituraIniciada) ...[
                            _buildResumoDaVenda(context, state),
                            const SizedBox(height: 12),
                            _buildAcoes(context, state),
                            const SizedBox(height: 12),
                            LeitorWidget(
                              controller: _leitorController,
                              dataSource: sl(),
                              tabelaDePrecoId: state.tabelaDePrecoId,
                              aceitarApenasProdutosComPreco: true,
                              campoCodigoHint:
                                  'Bipe ou informe o código do produto',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iniciar venda', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Selecione o cliente, o vendedor e a tabela de preço antes de iniciar a contagem.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AbsorbPointer(
              absorbing: state.leituraIniciada || state.processando,
              child: Opacity(
                opacity: state.leituraIniciada ? 0.7 : 1,
                child: Column(
                  children: [
                    widget.pessoaSeletor.buildComParametros(
                      SeletorParamentros(
                        itemsSelecionadosInicial:
                            state.clienteSelecionado == null
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (state.clienteSelecionado != null)
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(state.clienteSelecionado!.nome),
                  ),
                if (state.vendedorSelecionado != null)
                  Chip(
                    avatar: const Icon(Icons.badge_outlined, size: 18),
                    label: Text(state.vendedorSelecionado!.nome),
                  ),
                if (state.tabelaDePrecoSelecionada != null)
                  Chip(
                    avatar: const Icon(Icons.price_change_outlined, size: 18),
                    label: Text(state.tabelaDePrecoSelecionada!.nome),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: state.leituraIniciada
                  ? TextButton.icon(
                      onPressed: state.processando
                          ? null
                          : () => bloc.add(const VendaEdicaoSolicitada()),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Alterar dados iniciais'),
                    )
                  : FilledButton.icon(
                      onPressed: state.podeIniciarLeitura
                          ? () => bloc.add(const VendaLeituraSolicitada())
                          : null,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Iniciar venda'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoDaVenda(BuildContext context, VendaState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Venda em andamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.person_outline,
                  label: 'Cliente: ${state.clienteSelecionado?.nome ?? '-'}',
                ),
                _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label: 'Vendedor: ${state.vendedorSelecionado?.nome ?? '-'}',
                ),
                _buildInfoChip(
                  icon: Icons.sell_outlined,
                  label:
                      'Tabela: ${state.tabelaDePrecoSelecionada?.nome ?? '-'}',
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
                      titulo: 'Itens distintos',
                      valor: '${_leitorController.quantidadeItensDistintos}',
                      colorScheme: colorScheme,
                    ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAcoes(BuildContext context, VendaState state) {
    return AnimatedBuilder(
      animation: _leitorController,
      builder: (context, _) {
        final temItens = _leitorController.itens.isNotEmpty;
        final labelFinalizar =
            state.processoAtual == VendaProcesso.finalizarVenda
                ? 'Encaminhando...'
                : 'Finalizar e ir ao caixa';
        final labelPedido = state.processoAtual == VendaProcesso.criarPedido
            ? 'Criando pedido...'
            : 'Criar pedido';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
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
                FilledButton.tonalIcon(
                  onPressed: temItens && !state.processando
                      ? () => _abrirConfirmacao(
                          context, state, _VendaAcao.criarPedido)
                      : null,
                  icon: state.processoAtual == VendaProcesso.criarPedido
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.receipt_long_outlined),
                  label: Text(labelPedido),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoInicial(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_checkout_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Pronto para iniciar a venda',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
    SelectData? clienteSelecionado = state.clienteSelecionado;
    SelectData? vendedorSelecionado = state.vendedorSelecionado;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: Text(
                acao == _VendaAcao.finalizar
                    ? 'Confirmar finalização da venda'
                    : 'Confirmar criação do pedido',
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Confira o resumo antes de continuar. Se necessário, ajuste o cliente ou o vendedor.',
                        style: Theme.of(dialogContext).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoChip(
                        icon: Icons.numbers_outlined,
                        label:
                            'Quantidade de produtos: ${_leitorController.quantidadeTotalLida}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoChip(
                        icon: Icons.attach_money_outlined,
                        label:
                            'Valor total do pedido: ${_formatarMoeda(_leitorController.valorTotalLido)}',
                      ),
                      const SizedBox(height: 12),
                      widget.pessoaSeletor.buildComParametros(
                        SeletorParamentros(
                          itemsSelecionadosInicial: clienteSelecionado == null
                              ? null
                              : [clienteSelecionado!],
                          onChanged: (selecionados) {
                            setStateDialog(() {
                              clienteSelecionado = selecionados.isEmpty
                                  ? null
                                  : selecionados.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      widget.vendedoresSeletor.buildComParametros(
                        SeletorParamentros(
                          itemsSelecionadosInicial: vendedorSelecionado == null
                              ? null
                              : [vendedorSelecionado!],
                          onChanged: (selecionados) {
                            setStateDialog(() {
                              vendedorSelecionado = selecionados.isEmpty
                                  ? null
                                  : selecionados.first;
                            });
                          },
                        ),
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
                  child: Text(
                    acao == _VendaAcao.finalizar
                        ? 'Finalizar venda'
                        : 'Criar pedido',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    if (clienteSelecionado != state.clienteSelecionado) {
      bloc.add(VendaClienteSelecionado(clienteSelecionado: clienteSelecionado));
    }
    if (vendedorSelecionado != state.vendedorSelecionado) {
      bloc.add(
        VendaVendedorSelecionado(vendedorSelecionado: vendedorSelecionado),
      );
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

    if (acao == _VendaAcao.finalizar) {
      bloc.add(VendaFinalizarSolicitada(itens: itens));
      return;
    }

    bloc.add(
      VendaCriarPedidoSolicitado(
        itens: itens,
        quantidadeProdutos: _leitorController.quantidadeTotalLida,
        valorTotal: _leitorController.valorTotalLido,
      ),
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

  void _reiniciarFluxo(BuildContext context) {
    _leitorController.limpar();
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
}
