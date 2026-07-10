import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/presentation/blocs/documentos_fiscais_bloc/documentos_fiscais_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class DocumentosFiscaisPage extends StatefulWidget {
  const DocumentosFiscaisPage({super.key});

  @override
  State<DocumentosFiscaisPage> createState() => _DocumentosFiscaisPageState();
}

class _DocumentosFiscaisPageState extends State<DocumentosFiscaisPage> {
  late final DocumentosFiscaisBloc _bloc;
  final _buscaController = TextEditingController();
  final _buscaDebouncer = Debouncer(milliseconds: 400);
  final _formaPagamentoController = TextEditingController();
  String? _statusFiltro;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _filtrosAbertos = false;

  static const _statusOpcoes = [
    (null, 'Todos'),
    ('emitida', 'Emitida'),
    ('pendente', 'Pendente'),
    ('pendente_edicao', 'Pend. Edição'),
    ('processando', 'Processando'),
    ('falha', 'Falha'),
    ('cancelada', 'Cancelada'),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = sl<DocumentosFiscaisBloc>()..add(DocumentosFiscaisCarregar());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _buscaDebouncer.cancel();
    _formaPagamentoController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _carregar({int page = 1}) {
    final busca = _buscaController.text.trim();
    final numero = int.tryParse(busca);

    _bloc.add(DocumentosFiscaisCarregar(
      romaneioId: numero,
      pedidoId: numero,
      cliente: numero == null && busca.isNotEmpty ? busca : null,
      status: _statusFiltro,
      formaPagamento: _formaPagamentoController.text.trim().isNotEmpty
          ? _formaPagamentoController.text.trim()
          : null,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      page: page,
    ));
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (inicio ? _dataInicio : _dataFim) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (inicio) {
        _dataInicio = picked;
      } else {
        _dataFim = picked;
      }
    });
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentosFiscaisBloc>.value(
      value: _bloc,
      child: BlocConsumer<DocumentosFiscaisBloc, DocumentosFiscaisState>(
        listener: (context, state) {
          if (state.step == DocumentosFiscaisStep.falha &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Documentos Fiscais'),
              actions: [
                IconButton(
                  icon: Icon(
                    _filtrosAbertos
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                  ),
                  onPressed: () =>
                      setState(() => _filtrosAbertos = !_filtrosAbertos),
                  tooltip: 'Filtros',
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText:
                          'Buscar por cliente, nº romaneio ou nº pedido...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscaController.clear();
                                setState(() {});
                                _carregar();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                      _buscaDebouncer.run(() => _carregar());
                    },
                    onSubmitted: (_) => _carregar(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    children: _statusOpcoes.map((op) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(op.$2),
                          selected: _statusFiltro == op.$1,
                          onSelected: (_) {
                            setState(() => _statusFiltro = op.$1);
                            _carregar();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _FiltrosExtras(
                    dataInicio: _dataInicio,
                    dataFim: _dataFim,
                    formaPagamentoController: _formaPagamentoController,
                    onSelecionarDataInicio: () =>
                        _selecionarData(inicio: true),
                    onSelecionarDataFim: () =>
                        _selecionarData(inicio: false),
                    onFormaPagamentoChanged: (_) => _carregar(),
                    onLimpar: () {
                      setState(() {
                        _dataInicio = null;
                        _dataFim = null;
                        _formaPagamentoController.clear();
                      });
                      _carregar();
                    },
                  ),
                  crossFadeState: _filtrosAbertos
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.step == DocumentosFiscaisStep.carregando
                      ? const Center(child: CircularProgressIndicator())
                      : state.items.isEmpty
                          ? const Center(
                              child: Text('Nenhum documento encontrado.'),
                            )
                          : RefreshIndicator(
                              onRefresh: () async => _carregar(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: state.items.length,
                                itemBuilder: (context, i) {
                                  final doc = state.items[i];
                                  final reprocessando =
                                      state.reprocessando.contains(doc.id);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _DocumentoFiscalCard(
                                      documento: doc,
                                      reprocessando: reprocessando,
                                      onReprocessar: () => _bloc.add(
                                        DocumentosFiscaisReprocessar(doc.id),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _fmtData(DateTime d) => formatarData(d);

String _fmtDataHora(DateTime d) => formatarDataHora(d);

class _FiltrosExtras extends StatelessWidget {
  const _FiltrosExtras({
    required this.dataInicio,
    required this.dataFim,
    required this.formaPagamentoController,
    required this.onSelecionarDataInicio,
    required this.onSelecionarDataFim,
    required this.onFormaPagamentoChanged,
    required this.onLimpar,
  });

  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TextEditingController formaPagamentoController;
  final VoidCallback onSelecionarDataInicio;
  final VoidCallback onSelecionarDataFim;
  final ValueChanged<String> onFormaPagamentoChanged;
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    dataInicio != null
                        ? 'De: ${_fmtData(dataInicio!)}'
                        : 'Data início',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: onSelecionarDataInicio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    dataFim != null
                        ? 'Até: ${_fmtData(dataFim!)}'
                        : 'Data fim',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: onSelecionarDataFim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: formaPagamentoController,
                  decoration: const InputDecoration(
                    labelText: 'Forma de pagamento',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: onFormaPagamentoChanged,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onLimpar,
                child: const Text('Limpar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentoFiscalCard extends StatelessWidget {
  const _DocumentoFiscalCard({
    required this.documento,
    required this.reprocessando,
    required this.onReprocessar,
  });

  final DocumentoFiscal documento;
  final bool reprocessando;
  final VoidCallback onReprocessar;

  bool get _podeReprocessar =>
      documento.status == 'falha' ||
      documento.status == 'pendente_edicao';

  Color get _corStatus => switch (documento.status) {
        'emitida' => Colors.green,
        'pendente' => Colors.amber.shade700,
        'pendente_edicao' => Colors.orange,
        'processando' => Colors.blue,
        'falha' => Colors.red,
        'cancelada' => Colors.grey,
        _ => Colors.blueGrey,
      };

  String get _labelStatus => switch (documento.status) {
        'emitida' => 'Emitida',
        'pendente' => 'Pendente',
        'pendente_edicao' => 'Pendente Edição',
        'processando' => 'Processando',
        'falha' => 'Falha',
        'cancelada' => 'Cancelada',
        _ => documento.status,
      };

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          '/documento_fiscal',
          arguments: {'id': documento.id},
        ),
        child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            documento.pessoaNome ?? 'Sem cliente',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _labelStatus,
                            style: TextStyle(
                              fontSize: 11,
                              color: cor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.receipt_long,
                          label: 'Romaneio #${documento.romaneioId}',
                        ),
                        if (documento.pedidoId != null) ...[
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.shopping_cart,
                            label: 'Pedido #${documento.pedidoId}',
                          ),
                        ],
                      ],
                    ),
                    if (documento.erroMensagem != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        documento.erroMensagem!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            documento.createdAt != null
                                ? _fmtDataHora(documento.createdAt!)
                                : '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (_podeReprocessar)
                          reprocessando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextButton.icon(
                                  icon: const Icon(
                                    Icons.replay,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Reemitir',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: onReprocessar,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
