import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:core/seletores.dart';

class RomaneioPage extends StatefulWidget {
  final int? idRomaneio;
  final bool permitirEdicao;

  final SeletorWidget tableDePrecoSeletor;
  final SeletorWidget funcionarioSeletor;
  final SeletorWidget pessoaSeletor;

  const RomaneioPage({
    super.key,
    this.idRomaneio,
    this.permitirEdicao = true,
    required this.tableDePrecoSeletor,
    required this.funcionarioSeletor,
    required this.pessoaSeletor,
  });

  @override
  State<RomaneioPage> createState() => _RomaneioPageState();
}

class _RomaneioPageState extends State<RomaneioPage> {
  static const _operacoes = TipoOperacao.values;

  final _formKey = GlobalKey<FormState>();
  final _pessoaIdController = TextEditingController();
  final _funcionarioIdController = TextEditingController();
  final _tabelaPrecoIdController = TextEditingController();
  final _observacaoController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneioBloc>(
      create: (_) => sl<RomaneioBloc>()
        ..add(RomaneioIniciou(idRomaneio: widget.idRomaneio)),
      child: BlocListener<RomaneioBloc, RomaneioState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == RomaneioStep.criado ||
              state.step == RomaneioStep.salvo) {
            Navigator.of(context).pop(true);
            return;
          }

          if (state.step == RomaneioStep.observacaoAtualizada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Observacao atualizada com sucesso.'),
              ),
            );
            return;
          }

          if (state.step == RomaneioStep.envioPendenciaConcluido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Envio dos itens pendentes concluído com sucesso.'),
              ),
            );
            return;
          }

          if (state.step == RomaneioStep.envioPendenciaIncompleto) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.erro ??
                      'Ainda existem itens pendentes para envio deste romaneio.',
                ),
              ),
            );
            return;
          }

          if (state.step == RomaneioStep.validacaoInvalida ||
              state.step == RomaneioStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro ?? 'Falha ao processar romaneio.'),
              ),
            );
          }
        },
        child: BlocBuilder<RomaneioBloc, RomaneioState>(
          builder: (context, state) {
            final carregando = state.step == RomaneioStep.carregando ||
                state.step == RomaneioStep.salvando ||
                state.step == RomaneioStep.processando;
            final somenteVisualizacao = !widget.permitirEdicao;

            if (state.step != RomaneioStep.carregando) {
              _sincronizarControllers(state);
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.idRomaneio == null
                    ? 'Novo romaneio'
                    : somenteVisualizacao
                        ? 'Visualizar romaneio #${widget.idRomaneio}'
                        : 'Romaneio #${widget.idRomaneio}'),
                actions: [
                  if (somenteVisualizacao)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.visibility_outlined),
                    ),
                ],
              ),
              floatingActionButton: somenteVisualizacao
                  ? null
                  : FloatingActionButton(
                      onPressed: carregando
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<RomaneioBloc>().add(
                                      RomaneioSalvou(),
                                    );
                              }
                            },
                      child: const Icon(Icons.save),
                    ),
              body: state.step == RomaneioStep.carregando
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: somenteVisualizacao
                            ? _buildVisualizacaoContent(context, state)
                            : _buildFormularioEdicao(
                                context,
                                state,
                                carregando,
                              ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormularioEdicao(
    BuildContext context,
    RomaneioState state,
    bool carregando,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.possuiPendenciaDeEnvio) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTituloSecao(
                    context,
                    'Pendências de envio',
                    Icons.cloud_off_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Existem ${state.quantidadeItensPendentes} item(ns) não enviados para o servidor.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: carregando
                        ? null
                        : () {
                            context.read<RomaneioBloc>().add(
                                  RomaneioContinuarEnvioSolicitado(),
                                );
                          },
                    icon: const Icon(Icons.sync),
                    label: const Text('Continuar envio deste romaneio'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTituloSecao(
                  context,
                  'Dados do romaneio',
                  Icons.description_outlined,
                ),
                const SizedBox(height: 16),
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.pessoaSeletor(
                    itemsSelecionadosInicial: state.pessoaId != null
                        ? [
                            SelectData(
                              id: state.pessoaId!,
                              nome: state.romaneio?.pessoaNome
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? state.romaneio!.pessoaNome!
                                  : 'Pessoa #${state.pessoaId}',
                              data: {
                                'id': state.pessoaId,
                                'nome': state.romaneio?.pessoaNome,
                              },
                            ),
                          ]
                        : const [],
                    onlyView: false,
                    onChanged: (selecionados) {
                      final id = selecionados.isNotEmpty
                          ? selecionados.first.id
                          : null;
                      _onCampoAlterado(
                        context,
                        pessoaId: id,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.funcionarioSeletor(
                    onlyView: false,
                    itemsSelecionadosInicial: state.funcionarioId != null
                        ? [
                            SelectData(
                              id: state.funcionarioId!,
                              nome: state.romaneio?.funcionarioNome
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? state.romaneio!.funcionarioNome!
                                  : 'Funcionário #${state.funcionarioId}',
                              data: {
                                'id': state.funcionarioId,
                                'nome': state.romaneio?.funcionarioNome,
                              },
                            ),
                          ]
                        : const [],
                    onChanged: (selecionados) {
                      final id = selecionados.isNotEmpty
                          ? selecionados.first.id
                          : null;
                      _onCampoAlterado(
                        context,
                        funcionarioId: id,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.tableDePrecoSeletor(
                    onlyView: false,
                    itemsSelecionadosInicial: state.tabelaPrecoId != null
                        ? [
                            SelectData(
                              id: state.tabelaPrecoId!,
                              nome: 'Tabela de preço #${state.tabelaPrecoId}',
                              data: {
                                'id': state.tabelaPrecoId,
                              },
                            ),
                          ]
                        : const [],
                    onChanged: (selecionados) {
                      final id = selecionados.isNotEmpty
                          ? selecionados.first.id
                          : null;
                      _onCampoAlterado(
                        context,
                        tabelaPrecoId: id,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TipoOperacao>(
                  initialValue: state.operacao ?? TipoOperacao.venda,
                  decoration: const InputDecoration(labelText: 'Operacao'),
                  items: _operacoes
                      .map(
                        (op) => DropdownMenuItem<TipoOperacao>(
                          value: op,
                          child: Text(op.descricao),
                        ),
                      )
                      .toList(),
                  onChanged: carregando
                      ? null
                      : (value) => _onCampoAlterado(
                            context,
                            operacao: value,
                          ),
                ),
              ],
            ),
          ),
        ),
        if (state.id != null) ...[
          const SizedBox(height: 16),
          Card(
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
                    readOnly: carregando,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observacao',
                    ),
                    onChanged: (value) => _onCampoAlterado(
                      context,
                      observacao: value,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: carregando
                          ? null
                          : () {
                              context.read<RomaneioBloc>().add(
                                    RomaneioObservacaoAtualizada(
                                      observacao: _observacaoController.text,
                                    ),
                                  );
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar observação'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildItensRomaneioCard(context, state),
        ],
      ],
    );
  }

  Widget _buildVisualizacaoContent(BuildContext context, RomaneioState state) {
    final romaneio = state.romaneio;
    final observacao = (state.observacao ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.possuiPendenciaDeEnvio) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTituloSecao(
                    context,
                    'Pendências de envio',
                    Icons.cloud_off_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Existem ${state.quantidadeItensPendentes} item(ns) pendentes para envio deste romaneio.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<RomaneioBloc>().add(
                            RomaneioContinuarEnvioSolicitado(),
                          );
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Continuar envio'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
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
                      child: Text('${state.id ?? widget.idRomaneio ?? '-'}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Romaneio #${state.id ?? widget.idRomaneio ?? '-'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarData(
                              romaneio?.data ??
                                  romaneio?.atualizadoEm ??
                                  romaneio?.criadoEm,
                            ),
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
                      icon: Icons.swap_horiz_rounded,
                      label:
                          state.operacao?.descricao ?? 'Operação não informada',
                    ),
                    if ((romaneio?.situacao ?? '').trim().isNotEmpty)
                      _buildInfoChip(
                        context,
                        icon: Icons.inventory_2_outlined,
                        label: romaneio!.situacao!,
                      ),
                    if ((romaneio?.modalidade ?? '').trim().isNotEmpty)
                      _buildInfoChip(
                        context,
                        icon: Icons.local_offer_outlined,
                        label: romaneio!.modalidade!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTituloSecao(
          context,
          'Resumo',
          Icons.bar_chart_rounded,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 160,
              child: _buildMetricaCard(
                context,
                titulo: 'Itens',
                valor: '${state.itens.length}',
                icone: Icons.list_alt_outlined,
              ),
            ),
            SizedBox(
              width: 160,
              child: _buildMetricaCard(
                context,
                titulo: 'Quantidade',
                valor: _formatarQuantidade(romaneio?.quantidade),
                icone: Icons.straighten_outlined,
              ),
            ),
            SizedBox(
              width: 160,
              child: _buildMetricaCard(
                context,
                titulo: 'Valor bruto',
                valor: _formatarValorMonetario(romaneio?.valorBruto),
                icone: Icons.attach_money_outlined,
              ),
            ),
            SizedBox(
              width: 160,
              child: _buildMetricaCard(
                context,
                titulo: 'Valor líquido',
                valor: _formatarValorMonetario(romaneio?.valorLiquido),
                icone: Icons.payments_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
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
                _buildInfoLinha(
                  context,
                  icone: Icons.person_outline,
                  titulo: 'Pessoa',
                  valor: _valorOuFallback(
                    romaneio?.pessoaNome,
                    fallback: state.pessoaId != null
                        ? 'Pessoa #${state.pessoaId}'
                        : '-',
                  ),
                  complemento:
                      state.pessoaId != null ? 'ID ${state.pessoaId}' : null,
                ),
                const Divider(height: 24),
                _buildInfoLinha(
                  context,
                  icone: Icons.badge,
                  titulo: 'Funcionário',
                  valor: _valorOuFallback(
                    romaneio?.funcionarioNome,
                    fallback: state.funcionarioId != null
                        ? 'Funcionário #${state.funcionarioId}'
                        : '-',
                  ),
                  complemento: state.funcionarioId != null
                      ? 'ID ${state.funcionarioId}'
                      : null,
                ),
                const Divider(height: 24),
                _buildInfoLinha(
                  context,
                  icone: Icons.sell_outlined,
                  titulo: 'Tabela de preço',
                  valor: state.tabelaPrecoId != null
                      ? 'Tabela de preço #${state.tabelaPrecoId}'
                      : '-',
                  complemento: romaneio?.valorDesconto != null
                      ? 'Desconto ${_formatarValorMonetario(romaneio?.valorDesconto)}'
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (observacao.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTituloSecao(
                    context,
                    'Observação',
                    Icons.sticky_note_2_outlined,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    observacao,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildItensRomaneioCard(context, state),
      ],
    );
  }

  Widget _buildItensRomaneioCard(BuildContext context, RomaneioState state) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Itens do romaneio',
              Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 4),
            Text(
              'Total de itens: ${state.itens.length}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (state.itens.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Nenhum item cadastrado neste romaneio.'),
              )
            else
              ListView.separated(
                itemCount: state.itens.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = state.itens[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
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
                              const SizedBox(height: 6),
                              Text(
                                'Ref.: ${item.referenciaId ?? '-'}  •  Produto: ${item.produtoId ?? '-'}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cor: ${item.corNome ?? '-'}  •  Tamanho: ${item.tamanhoNome ?? '-'}',
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
                              Text(
                                'Qtd.',
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(
                                _formatarQuantidade(item.quantidade),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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

  Widget _buildMetricaCard(
    BuildContext context, {
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(titulo, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              valor,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _valorOuFallback(String? valor, {String fallback = '-'}) {
    if (valor == null || valor.trim().isEmpty) {
      return fallback;
    }
    return valor.trim();
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Data não informada';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  String _formatarValorMonetario(double? valor) {
    if (valor == null) return '-';
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarQuantidade(double? quantidade) {
    if (quantidade == null) return '-';
    if (quantidade == quantidade.truncateToDouble()) {
      return quantidade.toInt().toString();
    }
    return quantidade.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _sincronizarControllers(RomaneioState state) {
    _sincronizarController(
        _pessoaIdController, state.pessoaId?.toString() ?? '');
    _sincronizarController(
        _funcionarioIdController, state.funcionarioId?.toString() ?? '');
    _sincronizarController(
        _tabelaPrecoIdController, state.tabelaPrecoId?.toString() ?? '');
    _sincronizarController(_observacaoController, state.observacao ?? '');
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
    int? pessoaId,
    int? funcionarioId,
    int? tabelaPrecoId,
    TipoOperacao? operacao,
    String? observacao,
  }) {
    context.read<RomaneioBloc>().add(
          RomaneioCampoAlterado(
            pessoaId: pessoaId,
            funcionarioId: funcionarioId,
            tabelaPrecoId: tabelaPrecoId,
            operacao: operacao,
            observacao: observacao,
          ),
        );
  }
}
