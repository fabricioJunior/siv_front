import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:flutter/material.dart';

class DevolucaoPage extends StatefulWidget {
  const DevolucaoPage({super.key});

  @override
  State<DevolucaoPage> createState() => _DevolucaoPageState();
}

class _DevolucaoPageState extends State<DevolucaoPage> {
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
    return BlocProvider<DevolucaoBloc>(
      create: (_) => sl<DevolucaoBloc>()..add(const DevolucaoIniciou()),
      child: BlocConsumer<DevolucaoBloc, DevolucaoState>(
        listenWhen: (previous, current) =>
            previous.erro != current.erro ||
            previous.romaneioDevolucaoId != current.romaneioDevolucaoId,
        listener: (context, state) {
          final erro = state.erro;
          if (erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(erro),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          final romaneioDevolucaoId = state.romaneioDevolucaoId;
          if (romaneioDevolucaoId != null && !state.fluxoParcial) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Devolucao concluida com sucesso. Romaneio #$romaneioDevolucaoId recebido no caixa.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _leitorController.limpar();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Devolucao de mercadorias')),
            body: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRomaneioOriginalCard(context, state),
                    const SizedBox(height: 12),
                    if (state.leituraIniciada) ...[
                      _buildResumoDaLeitura(state),
                      const SizedBox(height: 12),
                      _buildAcoes(context, state),
                      const SizedBox(height: 12),
                      LeitorWidget(
                        controller: _leitorController,
                        dataSource: sl(),
                        buscaDataSource: sl(),
                        tabelaDePrecoId: state.romaneioOriginal?.tabelaPrecoId,
                        controlarQuantidade: true,
                        aceitarApenasProdutosComPreco: false,
                        campoCodigoHint:
                            'Bipe ou informe o codigo do produto para devolucao',
                      ),
                    ] else
                      _buildEstadoInicial(),
                  ],
                ),
              ),
            ),
            floatingActionButton: state.romaneioDevolucaoId != null
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/romaneio',
                        arguments: {
                          'idRomaneio': state.romaneioDevolucaoId,
                          'permitirEdicao': false,
                        },
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir romaneio'),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildRomaneioOriginalCard(
      BuildContext context, DevolucaoState state) {
    final bloc = context.read<DevolucaoBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '1. Selecione o romaneio original',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um romaneio de venda do cliente para vincular a devolucao.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: state.carregandoRomaneios || state.processando
                  ? null
                  : () async {
                      final selecionado = await _abrirBuscaRomaneioOriginal(
                        context,
                        state.romaneiosDeVenda,
                      );

                      if (!context.mounted || selecionado == null) {
                        return;
                      }

                      bloc.add(
                        DevolucaoRomaneioOriginalSelecionado(
                          romaneio: selecionado,
                        ),
                      );
                    },
              icon: state.carregandoRomaneios
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                state.carregandoRomaneios
                    ? 'Carregando romaneios...'
                    : 'Buscar romaneio',
              ),
            ),
            if (state.romaneioOriginal != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.receipt_long,
                    label: 'Romaneio #${state.romaneioOriginal!.id ?? '-'}',
                  ),
                  _buildInfoChip(
                    icon: Icons.person_outline,
                    label:
                        'Cliente: ${state.romaneioOriginal!.pessoaNome ?? state.romaneioOriginal!.pessoaId ?? '-'}',
                  ),
                  _buildInfoChip(
                    icon: Icons.inventory_2_outlined,
                    label:
                        'Produtos elegiveis: ${state.itensDoRomaneioOriginalPorProduto.length}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: state.leituraIniciada
                  ? TextButton.icon(
                      onPressed: state.processando ||
                              state.carregandoItensDoOriginal
                          ? null
                          : () => bloc.add(const DevolucaoEdicaoSolicitada()),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Alterar romaneio original'),
                    )
                  : FilledButton.icon(
                      onPressed: state.podeIniciarLeitura &&
                              !state.processando &&
                              !state.carregandoItensDoOriginal
                          ? () => bloc.add(const DevolucaoLeituraSolicitada())
                          : null,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: Text(
                        state.carregandoItensDoOriginal
                            ? 'Carregando itens do romaneio...'
                            : '2. Iniciar leitura da devolucao',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoDaLeitura(DevolucaoState state) {
    return AnimatedBuilder(
      animation: _leitorController,
      builder: (context, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBox(
                  context,
                  titulo: 'Itens distintos',
                  valor: '${_leitorController.quantidadeItensDistintos}',
                ),
                _buildStatusBox(
                  context,
                  titulo: 'Quantidade total',
                  valor: '${_leitorController.quantidadeTotalLida}',
                ),
                _buildStatusBox(
                  context,
                  titulo: 'Valor lido',
                  valor: _formatarMoeda(_leitorController.valorTotalLido),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcoes(BuildContext context, DevolucaoState state) {
    final bloc = context.read<DevolucaoBloc>();

    return AnimatedBuilder(
      animation: _leitorController,
      builder: (context, _) {
        final temItens = _leitorController.itens.isNotEmpty;

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
                  label: const Text('Reiniciar leitura'),
                ),
                FilledButton.icon(
                  onPressed: temItens && !state.processando
                      ? () {
                          final itens = _leitorController.itens
                              .map(
                                (item) => {
                                  'produtoId': item.id,
                                  'quantidade': item.quantidadeLida,
                                  'nome': item.descricao,
                                  'corNome': item.cor,
                                  'tamanhoNome': item.tamanho,
                                },
                              )
                              .toList(growable: false);

                          bloc.add(
                            DevolucaoConfirmacaoSolicitada(itens: itens),
                          );
                        }
                      : null,
                  icon: state.processando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.assignment_turned_in_outlined),
                  label: Text(
                    state.processando
                        ? 'Processando devolucao...'
                        : '3. Confirmar devolucao',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoInicial() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.assignment_return_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Fluxo de devolucao',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione um romaneio de venda, leia os itens devolvidos e confirme para criar e receber o romaneio de venda_devolucao.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<Romaneio?> _abrirBuscaRomaneioOriginal(
    BuildContext context,
    List<Romaneio> romaneios,
  ) async {
    return showModalBottomSheet<Romaneio>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        var filtro = '';

        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final texto = filtro.trim().toLowerCase();
            final filtrados = texto.isEmpty
                ? romaneios
                : romaneios.where((romaneio) {
                    final id = romaneio.id?.toString() ?? '';
                    final cliente = (romaneio.pessoaNome ?? '').toLowerCase();
                    final pessoaId = romaneio.pessoaId?.toString() ?? '';
                    return id.contains(texto) ||
                        cliente.contains(texto) ||
                        pessoaId.contains(texto);
                  }).toList(growable: false);

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(dialogContext).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(dialogContext).size.height * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Selecionar romaneio de venda',
                        style: Theme.of(dialogContext).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Buscar por romaneio, cliente ou id',
                        ),
                        onChanged: (value) {
                          setStateDialog(() {
                            filtro = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtrados.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum romaneio de venda encontrado para o filtro informado.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtrados.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final romaneio = filtrados[index];
                                  return ListTile(
                                    leading: const Icon(Icons.receipt_long),
                                    title:
                                        Text('Romaneio #${romaneio.id ?? '-'}'),
                                    subtitle: Text(
                                      'Cliente: ${romaneio.pessoaNome ?? romaneio.pessoaId ?? '-'}',
                                    ),
                                    onTap: () => Navigator.of(dialogContext)
                                        .pop(romaneio),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarReinicio(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reiniciar leitura'),
          content: const Text(
            'Deseja realmente limpar os itens lidos nesta devolucao?',
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
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
