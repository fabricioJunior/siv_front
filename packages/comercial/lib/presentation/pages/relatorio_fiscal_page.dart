import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/presentation/blocs/relatorio_fiscal_bloc/relatorio_fiscal_bloc.dart';
import 'package:comercial/presentation/relatorios/csv/relatorio_csv_exporter.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

const _limitePorPagina = 25;

const _formasPagamento = ['Cartão', 'Pix', 'Dinheiro'];

const _statusOpcoes = [
  (null, 'Todos'),
  ('emitida', 'Emitida'),
  ('pendente', 'Pendente'),
  ('pendente_edicao', 'Pend. Edição'),
  ('processando', 'Processando'),
  ('falha', 'Falha'),
  ('rejeitada', 'Rejeitada'),
  ('cancelada', 'Cancelada'),
];

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

class RelatorioFiscalPage extends StatefulWidget {
  const RelatorioFiscalPage({super.key});

  @override
  State<RelatorioFiscalPage> createState() => _RelatorioFiscalPageState();
}

class _RelatorioFiscalPageState extends State<RelatorioFiscalPage> {
  late final RelatorioFiscalBloc _bloc;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _formaPagamento;
  String? _status;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<RelatorioFiscalBloc>()..add(RelatorioFiscalCarregar());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _carregar({int page = 1}) {
    _bloc.add(RelatorioFiscalCarregar(
      formaPagamento: _formaPagamento,
      status: _status,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      page: page,
    ));
  }

  Future<void> _abrirFiltroPeriodo() async {
    final resultado = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: _dataInicio ?? DateTime.now(),
      dataFimAtual: _dataFim ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      permitirHora: false,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _dataInicio = resultado.dataInicio;
      _dataFim = resultado.dataFim;
    });
    _carregar();
  }

  Future<void> _exportar(
    Future<void> Function(List<DocumentoFiscal>, dynamic) exportar,
    RelatorioFiscalState state,
  ) async {
    if (state.resumo == null) return;
    setState(() => _exportando = true);
    await exportar(state.items, state.resumo);
    if (mounted) setState(() => _exportando = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioFiscalBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioFiscalBloc, RelatorioFiscalState>(
        builder: (context, state) {
          final temDados =
              state.step == RelatorioFiscalStep.sucesso && state.resumo != null;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Relatório Fiscal'),
              actions: [
                if (temDados)
                  _exportando
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.table_chart_outlined),
                              tooltip: 'Exportar CSV',
                              onPressed: () => _exportar(
                                (items, resumo) => RelatorioCsvExporter
                                    .exportarRelatorioFiscalCsv(items, resumo),
                                state,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              tooltip: 'Exportar PDF',
                              onPressed: () => _exportar(
                                (items, resumo) =>
                                    RelatorioPdfExporter.exportarRelatorioFiscalPdf(
                                  items,
                                  resumo,
                                  _dataInicio?.toIso8601String() ?? '',
                                  _dataFim?.toIso8601String() ?? '',
                                ),
                                state,
                              ),
                            ),
                          ],
                        ),
              ],
            ),
            body: Column(
              children: [
                _FiltrosCard(
                  dataInicio: _dataInicio,
                  dataFim: _dataFim,
                  formaPagamento: _formaPagamento,
                  status: _status,
                  onSelecionarPeriodo: _abrirFiltroPeriodo,
                  onFormaPagamentoChanged: (v) {
                    setState(() => _formaPagamento = v);
                    _carregar();
                  },
                  onStatusChanged: (v) {
                    setState(() => _status = v);
                    _carregar();
                  },
                ),
                if (temDados) _ResumoHeader(resumo: state.resumo!),
                const Divider(height: 1),
                Expanded(
                  child: state.step == RelatorioFiscalStep.carregando
                      ? const Center(child: CircularProgressIndicator())
                      : state.step == RelatorioFiscalStep.falha
                          ? Center(child: Text(state.erro ?? 'Erro desconhecido'))
                          : state.items.isEmpty
                              ? const Center(
                                  child: Text('Nenhuma nota encontrada.'),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async => _carregar(page: state.page),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: state.items.length,
                                    itemBuilder: (context, i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _DocumentoCard(documento: state.items[i]),
                                    ),
                                  ),
                                ),
                ),
                if (temDados && state.total > _limitePorPagina)
                  _Paginador(
                    page: state.page,
                    total: state.total,
                    onAnterior: state.page > 1
                        ? () => _carregar(page: state.page - 1)
                        : null,
                    onProximo:
                        state.page * _limitePorPagina < state.total
                            ? () => _carregar(page: state.page + 1)
                            : null,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FiltrosCard extends StatelessWidget {
  const _FiltrosCard({
    required this.dataInicio,
    required this.dataFim,
    required this.formaPagamento,
    required this.status,
    required this.onSelecionarPeriodo,
    required this.onFormaPagamentoChanged,
    required this.onStatusChanged,
  });

  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? formaPagamento;
  final String? status;
  final VoidCallback onSelecionarPeriodo;
  final ValueChanged<String?> onFormaPagamentoChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(
              dataInicio != null && dataFim != null
                  ? '${formatarData(dataInicio)} - ${formatarData(dataFim)}'
                  : 'Selecionar período',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: onSelecionarPeriodo,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: formaPagamento,
                  decoration: const InputDecoration(
                    labelText: 'Forma de pagamento',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    for (final f in _formasPagamento)
                      DropdownMenuItem(value: f, child: Text(f)),
                  ],
                  onChanged: onFormaPagamentoChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final op in _statusOpcoes)
                      DropdownMenuItem(value: op.$1, child: Text(op.$2)),
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumoHeader extends StatelessWidget {
  const _ResumoHeader({required this.resumo});

  final dynamic resumo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: _KpiBox(
              label: 'Saldo consolidado',
              valor: _fmtMoeda(resumo.saldoConsolidado as double),
              cor: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiBox(
              label: 'Saldo pendente',
              valor: _fmtMoeda(resumo.saldoPendente as double),
              cor: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  const _KpiBox({required this.label, required this.valor, required this.cor});

  final String label;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }
}

class _Paginador extends StatelessWidget {
  const _Paginador({
    required this.page,
    required this.total,
    required this.onAnterior,
    required this.onProximo,
  });

  final int page;
  final int total;
  final VoidCallback? onAnterior;
  final VoidCallback? onProximo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: onAnterior,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
          ),
          Text('Página $page'),
          TextButton.icon(
            onPressed: onProximo,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Próxima'),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _DocumentoCard extends StatelessWidget {
  const _DocumentoCard({required this.documento});

  final DocumentoFiscal documento;

  Color get _corStatus => switch (documento.status) {
        'emitida' => Colors.green,
        'pendente' => Colors.amber.shade700,
        'pendente_edicao' => Colors.orange,
        'processando' => Colors.blue,
        'falha' => Colors.red,
        'rejeitada' => Colors.red,
        'cancelada' => Colors.grey,
        _ => Colors.blueGrey,
      };

  String get _labelStatus => switch (documento.status) {
        'emitida' => 'Emitida',
        'pendente' => 'Pendente',
        'pendente_edicao' => 'Pendente Edição',
        'processando' => 'Processando',
        'falha' => 'Falha',
        'rejeitada' => 'Rejeitada',
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
                              _fmtMoeda(documento.valorLiquido),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _labelStatus,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        documento.tipoDocumentoLabel,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        documento.clienteMascarado,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Romaneio #${documento.romaneioId}'
                            '${documento.pedidoId != null ? ' · Pedido #${documento.pedidoId}' : ''}',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const Spacer(),
                          Text(
                            documento.createdAt != null
                                ? formatarDataHora(documento.createdAt)
                                : '',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
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
