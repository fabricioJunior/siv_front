import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PedidoPage extends StatefulWidget {
  final int? idPedido;
  final SeletorWidget? funcionarioSeletor;
  final SeletorWidget? tabelaDePrecoSeletor;

  const PedidoPage({
    super.key,
    this.idPedido,
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
  ];

  final _formKey = GlobalKey<FormState>();
  final _pessoaIdController = TextEditingController();
  final _funcionarioIdController = TextEditingController();
  final _tabelaPrecoIdController = TextEditingController();
  final _parcelasController = TextEditingController(text: '1');
  final _intervaloController = TextEditingController(text: '30');
  final _dataBaseController = TextEditingController();
  final _previsaoFaturamentoController = TextEditingController();
  final _previsaoEntregaController = TextEditingController();
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
    _parcelasController.dispose();
    _intervaloController.dispose();
    _dataBaseController.dispose();
    _previsaoFaturamentoController.dispose();
    _previsaoEntregaController.dispose();
    _observacaoController.dispose();
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

          if (state.step == PedidoStep.validacaoInvalida ||
              state.step == PedidoStep.falha) {
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
                        child: _buildFormularioPedido(context, state, carregando),
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
        const SizedBox(height: 16),
        _buildDadosVinculadosCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildCondicoesCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildDatasCard(context, carregando),
        const SizedBox(height: 16),
        _buildObservacaoCard(context, carregando),
        if (state.id != null) ...[
          const SizedBox(height: 16),
          _buildAcoesDoPedidoCard(context, state, carregando),
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
                  label: 'Tipo: ${state.tipo ?? _tipos.first}',
                ),
                _buildInfoChip(
                  context,
                  icon: Icons.receipt_long_outlined,
                  label: 'Parcelas: ${state.parcelas ?? '-'}',
                ),
                _buildInfoChip(
                  context,
                  icon: Icons.event_repeat_outlined,
                  label: 'Intervalo: ${state.intervalo ?? '-'} dias',
                ),
                _buildInfoChip(
                  context,
                  icon: Icons.shield_outlined,
                  label: (state.fiscal ?? false) ? 'Fiscal: sim' : 'Fiscal: não',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDadosVinculadosCard(
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
              'Dados vinculados',
              Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
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
                          nomeFallback: 'Funcionário selecionado',
                        ) ??
                        const [],
                    onlyView: widget.idPedido != null,
                    onChanged: (selecionados) => _onCampoAlterado(
                      context,
                      funcionarioId:
                          selecionados.isEmpty ? '' : '${selecionados.first.id}',
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
                      nomeFallback: 'Tabela selecionada',
                    ),
                    onlyView: widget.idPedido != null,
                    onChanged: (selecionados) => _onCampoAlterado(
                      context,
                      tabelaPrecoId:
                          selecionados.isEmpty ? '' : '${selecionados.first.id}',
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
        ),
      ),
    );
  }

  Widget _buildCondicoesCard(
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
              'Condições do pedido',
              Icons.tune_rounded,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue:
                  _tipos.contains(state.tipo) ? state.tipo : _tipos.first,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: _tipos
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ),
                  )
                  .toList(),
              onChanged: carregando
                  ? null
                  : (value) => _onCampoAlterado(
                        context,
                        tipo: value,
                      ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _campoNumero(
                    controller: _parcelasController,
                    label: 'Parcelas',
                    onChanged: (value) => _onCampoAlterado(
                      context,
                      parcelas: value,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _campoNumero(
                    controller: _intervaloController,
                    label: 'Intervalo (dias)',
                    onChanged: (value) => _onCampoAlterado(
                      context,
                      intervalo: value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: state.fiscal ?? false,
              onChanged: carregando
                  ? null
                  : (value) => _onCampoAlterado(
                        context,
                        fiscal: value,
                      ),
              title: const Text('Fiscal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasCard(BuildContext context, bool carregando) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Datas',
              Icons.event_note_outlined,
            ),
            const SizedBox(height: 12),
            _campoTexto(
              controller: _dataBaseController,
              label: 'Data base pagamento (YYYY-MM-DD)',
              onChanged: (value) => _onCampoAlterado(
                context,
                dataBasePagamento: value,
              ),
            ),
            const SizedBox(height: 12),
            _campoTexto(
              controller: _previsaoFaturamentoController,
              label: 'Previsão faturamento (YYYY-MM-DD)',
              onChanged: (value) => _onCampoAlterado(
                context,
                previsaoDeFaturamento: value,
              ),
            ),
            const SizedBox(height: 12),
            _campoTexto(
              controller: _previsaoEntregaController,
              label: 'Previsão entrega (YYYY-MM-DD)',
              onChanged: (value) => _onCampoAlterado(
                context,
                previsaoDeEntrega: value,
              ),
            ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a observação';
                }
                return null;
              },
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

  Widget _buildAcoesDoPedidoCard(
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
              'Ações do pedido',
              Icons.bolt_outlined,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
                FilledButton.icon(
                  onPressed: carregando
                      ? null
                      : () {
                          context.read<PedidoBloc>().add(
                                PedidoFaturou(),
                              );
                        },
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Faturar'),
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

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
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

  void _sincronizarControllers(PedidoState state) {
    _sincronizarController(_pessoaIdController, state.pessoaId ?? '');
    _sincronizarController(_funcionarioIdController, state.funcionarioId ?? '');
    _sincronizarController(_tabelaPrecoIdController, state.tabelaPrecoId ?? '');
    _sincronizarController(_parcelasController, state.parcelas ?? '1');
    _sincronizarController(_intervaloController, state.intervalo ?? '30');
    _sincronizarController(
      _dataBaseController,
      state.dataBasePagamento ?? '',
    );
    _sincronizarController(
      _previsaoFaturamentoController,
      state.previsaoDeFaturamento ?? '',
    );
    _sincronizarController(
      _previsaoEntregaController,
      state.previsaoDeEntrega ?? '',
    );
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
          ),
        );
  }
}
