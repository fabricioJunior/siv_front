import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/data_source/leitor_busca_restrita_data_source.dart';
import 'package:core/leitor/data_source/leitor_restrito_data_source.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class DevolucaoPage extends StatefulWidget {
  const DevolucaoPage({super.key});

  @override
  State<DevolucaoPage> createState() => _DevolucaoPageState();
}

class _DevolucaoPageState extends State<DevolucaoPage> {
  late final LeitorController _leitorController;
  bool _ehTroca = false;

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
            final ehTroca = _ehTroca;
            _ehTroca = false;
            _leitorController.limpar();
            context.read<DevolucaoBloc>().add(const DevolucaoResetSolicitado());

            if (ehTroca) {
              Navigator.of(context).pushNamed('/venda');
            } else {
              _mostrarConfirmacaoSucesso(context, romaneioDevolucaoId);
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Troca e devolução')),
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
                        // Bipagem e "Busca manual" restritas aos produtos do
                        // romaneio original -- produto fora do romaneio vira
                        // "não encontrado"/some da busca em vez de só ser
                        // barrado tardiamente em _validarItensDevolucao.
                        dataSource: LeitorRestritoDataSource(
                          origem: sl(),
                          saldosDisponiveis:
                              state.itensDoRomaneioOriginalPorProduto,
                        ),
                        buscaDataSource: LeitorBuscaRestritaDataSource(
                          origem: sl(),
                          saldosDisponiveis:
                              state.itensDoRomaneioOriginalPorProduto,
                        ),
                        tabelaDePrecoId: state.romaneioOriginal?.tabelaPrecoId,
                        controlarQuantidade: true,
                        aceitarApenasProdutosComPreco: false,
                        campoCodigoHint:
                            'Bipe ou informe o código do produto para devolução',
                        rotuloQuantidadeDisponivel: 'Disponível no romaneio',
                        mensagemQuantidadeIndisponivel: (_) =>
                            'Produto não disponível no romaneio.',
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
              'Escolha um romaneio de venda do cliente para vincular a devolução.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: state.carregandoRomaneios || state.processando
                  ? null
                  : () async {
                      final selecionado = await _abrirBuscaRomaneioOriginal(
                        context,
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
                        'Produtos elegíveis: ${state.itensDoRomaneioOriginalPorProduto.length}',
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
                            : '2. Iniciar leitura da devolução',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _ehTroca,
                  onChanged: state.processando
                      ? null
                      : (value) => setState(() => _ehTroca = value),
                  title: const Text('É uma troca?'),
                  subtitle: const Text(
                    'Ao confirmar, você será direcionado para iniciar a venda do produto de troca.',
                  ),
                ),
                Wrap(
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
                            ? 'Processando devolução...'
                            : '3. Confirmar devolução',
                      ),
                    ),
                  ],
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
              'Fluxo de troca e devolução',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione um romaneio de venda, leia os itens devolvidos e confirme para criar e receber o romaneio de devolução no caixa.',
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
  ) async {
    return showModalBottomSheet<Romaneio>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider<DevolucaoBloc>.value(
        value: context.read<DevolucaoBloc>(),
        child: const _BuscaRomaneioOriginalSheet(),
      ),
    );
  }

  Future<void> _confirmarReinicio(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reiniciar leitura'),
          content: const Text(
            'Deseja realmente limpar os itens lidos nesta devolução?',
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

  Future<void> _mostrarConfirmacaoSucesso(
    BuildContext context,
    int romaneioDevolucaoId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Devolução concluída'),
        content: Text(
          'Romaneio #$romaneioDevolucaoId recebido no caixa com sucesso.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

class _BuscaRomaneioOriginalSheet extends StatefulWidget {
  const _BuscaRomaneioOriginalSheet();

  @override
  State<_BuscaRomaneioOriginalSheet> createState() =>
      _BuscaRomaneioOriginalSheetState();
}

class _BuscaRomaneioOriginalSheetState extends State<_BuscaRomaneioOriginalSheet> {
  final Debouncer _debouncer = Debouncer(milliseconds: 350);
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DevolucaoBloc>().add(
          const DevolucaoBuscaRomaneiosSolicitada(searchTerm: ''),
        );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  void _onBuscaAlterada(String value) {
    setState(() {});
    _debouncer.run(() {
      context.read<DevolucaoBloc>().add(
            DevolucaoBuscaRomaneiosSolicitada(searchTerm: value),
          );
    });
  }

  void _limparBusca() {
    _debouncer.cancel();
    _buscaController.clear();
    setState(() {});
    context.read<DevolucaoBloc>().add(
          const DevolucaoBuscaRomaneiosSolicitada(searchTerm: ''),
        );
  }

  Future<void> _selecionarPeriodo(
    BuildContext context,
    DevolucaoState state,
  ) async {
    final agora = DateTime.now();
    final selecionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: DateTime(agora.year + 1),
      initialDateRange: state.dataInicialBuscaRomaneios != null &&
              state.dataFinalBuscaRomaneios != null
          ? DateTimeRange(
              start: state.dataInicialBuscaRomaneios!,
              end: state.dataFinalBuscaRomaneios!,
            )
          : null,
    );

    if (selecionado == null || !context.mounted) return;

    context.read<DevolucaoBloc>().add(
          DevolucaoBuscaRomaneiosSolicitada(
            searchTerm: state.termoBuscaRomaneios,
            dataInicial: selecionado.start,
            dataFinal: DateTime(
              selecionado.end.year,
              selecionado.end.month,
              selecionado.end.day,
              23,
              59,
              59,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevolucaoBloc, DevolucaoState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selecionar romaneio de venda',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por romaneio, cliente ou id',
                      suffixIcon: _buscaController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _limparBusca,
                              icon: const Icon(Icons.close),
                              tooltip: 'Limpar busca',
                            ),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _onBuscaAlterada,
                    onSubmitted: (value) {
                      _debouncer.cancel();
                      context.read<DevolucaoBloc>().add(
                            DevolucaoBuscaRomaneiosSolicitada(
                              searchTerm: value,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _selecionarPeriodo(context, state),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Período: ${_formatarDataCurta(state.dataInicialBuscaRomaneios)} até ${_formatarDataCurta(state.dataFinalBuscaRomaneios)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: state.carregandoBuscaRomaneios
                        ? const Center(child: CircularProgressIndicator())
                        : state.erroBuscaRomaneios != null
                            ? Center(
                                child: Text(
                                  state.erroBuscaRomaneios!,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : state.romaneiosBuscaDeVenda.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Nenhum romaneio de venda encontrado para o filtro informado.',
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount:
                                        state.romaneiosBuscaDeVenda.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final romaneio =
                                          state.romaneiosBuscaDeVenda[index];
                                      return ListTile(
                                        leading:
                                            const Icon(Icons.receipt_long),
                                        title: Text(
                                          'Romaneio #${romaneio.id ?? '-'} · ${_formatarDataCurta(romaneio.data)}',
                                        ),
                                        subtitle: Text(
                                          'Cliente: ${romaneio.pessoaNome ?? romaneio.pessoaId ?? '-'}\n'
                                          'Valor: ${_formatarMoedaItem(romaneio.valorBruto)}',
                                        ),
                                        isThreeLine: true,
                                        onTap: () =>
                                            Navigator.of(context).pop(romaneio),
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
  }
}

String _formatarDataCurta(DateTime? data) {
  if (data == null) return '-';
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  return '$dia/$mes/${local.year}';
}

String _formatarMoedaItem(double? valor) {
  if (valor == null) return '-';
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
