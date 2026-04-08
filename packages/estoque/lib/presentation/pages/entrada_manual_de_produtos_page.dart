import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/seletores.dart';
import 'package:estoque/presentation/blocs/entrada_manual_de_produtos_bloc/entrada_manual_de_produtos_bloc.dart';
import 'package:flutter/material.dart';

class EntradaManulDeProdutosPage extends StatefulWidget {
  final SeletorWidget tabelasDePrecoSeletor;
  final SeletorWidget funcionariosSeletor;

  const EntradaManulDeProdutosPage({
    super.key,
    required this.tabelasDePrecoSeletor,
    required this.funcionariosSeletor,
  });

  @override
  State<EntradaManulDeProdutosPage> createState() =>
      _EntradaManulDeProdutosPageState();
}

class _EntradaManulDeProdutosPageState
    extends State<EntradaManulDeProdutosPage> {
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
    return BlocProvider<EntradaManualDeProdutosBloc>(
      create: (_) => sl<EntradaManualDeProdutosBloc>(),
      child:
          BlocConsumer<
            EntradaManualDeProdutosBloc,
            EntradaManualDeProdutosState
          >(
            listenWhen: (previous, current) =>
                previous.erro != current.erro && current.erro != null,
            listener: (context, state) {
              final erro = state.erro;
              if (erro == null) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(erro),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: const Text('Entrada Manual de Produtos')),
                floatingActionButton: state.leituraIniciada
                    ? AnimatedBuilder(
                        animation: _leitorController,
                        builder: (context, _) {
                          if (_leitorController.itens.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return FloatingActionButton.extended(
                            onPressed: () async {
                              final itens = _leitorController.itens
                                  .map(
                                    (e) => {
                                      'produtoId': e.id,
                                      'quantidade': e.quantidadeLida,
                                      'valorUnitario': e.valorUnitario,
                                    },
                                  )
                                  .toList();
                              if (itens.isEmpty) {
                                return;
                              }

                              final result = await Navigator.of(context)
                                  .pushNamed(
                                    '/criar_romaneio_por_parametros',
                                    arguments: {
                                      'funcionarioId':
                                          state.funcionarioSelecionado?.id,
                                      'tabelaPrecoId':
                                          state.tabelaDePrecoSelecionada?.id,
                                      'operacao': 'transferencia_entrada',
                                      'itens': itens,
                                    },
                                  );

                              if (result == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Romaneio criado com sucesso.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Criar romaneio'),
                          );
                        },
                      )
                    : null,
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
                                _buildResumoDaLeitura(context, state),
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

  Widget _buildConfiguracaoCard(
    BuildContext context,
    EntradaManualDeProdutosState state,
  ) {
    final bloc = context.read<EntradaManualDeProdutosBloc>();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Configuração inicial', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Selecione o funcionário e a tabela de preços antes de iniciar a leitura.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AbsorbPointer(
              absorbing: state.leituraIniciada,
              child: Opacity(
                opacity: state.leituraIniciada ? 0.7 : 1,
                child: Column(
                  children: [
                    widget.funcionariosSeletor(
                      itemsSelecionadosInicial:
                          state.funcionarioSelecionado == null
                          ? null
                          : [state.funcionarioSelecionado!],
                      onChanged: (selecionados) {
                        bloc.add(
                          EntradaManualFuncionarioSelecionado(
                            funcionarioSelecionado: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    widget.tabelasDePrecoSeletor(
                      itemsSelecionadosInicial:
                          state.tabelaDePrecoSelecionada == null
                          ? null
                          : [state.tabelaDePrecoSelecionada!],
                      onChanged: (selecionados) {
                        bloc.add(
                          EntradaManualTabelaDePrecoSelecionada(
                            tabelaDePrecoSelecionada: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
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
                if (state.funcionarioSelecionado != null)
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(state.funcionarioSelecionado!.nome),
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
                      onPressed: () {
                        bloc.add(const EntradaManualEdicaoSolicitada());
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Alterar dados iniciais'),
                    )
                  : FilledButton.icon(
                      onPressed: state.podeIniciarLeitura
                          ? () {
                              bloc.add(const EntradaManualLeituraSolicitada());
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Iniciar leitura'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoDaLeitura(
    BuildContext context,
    EntradaManualDeProdutosState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Leitura em andamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label:
                      'Funcionário: ${state.funcionarioSelecionado?.nome ?? '-'}',
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

  Widget _buildEstadoInicial(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'A leitura será habilitada após a seleção do funcionário e da tabela de preços.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }

  Widget _buildStatusBox(
    BuildContext context, {
    required String titulo,
    required String valor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            valor,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
