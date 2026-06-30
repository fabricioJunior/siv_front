import 'package:comercial/presentation/blocs/relatorio_clientes_bloc/relatorio_clientes_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class RelatorioClientesAtivosPage extends StatefulWidget {
  const RelatorioClientesAtivosPage({super.key});

  @override
  State<RelatorioClientesAtivosPage> createState() =>
      _RelatorioClientesAtivosPageState();
}

class _RelatorioClientesAtivosPageState
    extends State<RelatorioClientesAtivosPage> {
  late final RelatorioClientesBloc _bloc;
  int _dias = 30;
  String? _dataReferencia;
  bool _exportandoPdf = false;
  late final TextEditingController _diasController;

  @override
  void initState() {
    super.initState();
    _diasController = TextEditingController(text: '30');
    _bloc = sl<RelatorioClientesBloc>()
      ..add(RelatorioClientesCarregar(dias: 30));
  }

  @override
  void dispose() {
    _diasController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    final dias = int.tryParse(_diasController.text) ?? 30;
    setState(() => _dias = dias.clamp(1, 365));
    _bloc.add(RelatorioClientesCarregar(
      dias: _dias,
      dataReferencia: _dataReferencia,
      page: page,
    ));
  }

  Future<void> _selecionarDataRef() async {
    final initial = _dataReferencia != null
        ? DateTime.tryParse(_dataReferencia!)
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() => _dataReferencia = _isoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioClientesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioClientesBloc, RelatorioClientesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Clientes Ativos'),
              actions: [
                if (state.step == RelatorioClientesStep.sucesso &&
                    state.dados != null)
                  _exportandoPdf
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          tooltip: 'Exportar PDF',
                          onPressed: () async {
                            setState(() => _exportandoPdf = true);
                            await RelatorioPdfExporter.exportarClientesAtivos(
                              state.dados!,
                              state.dias,
                              state.dataReferencia,
                            );
                            if (mounted) {
                              setState(() => _exportandoPdf = false);
                            }
                          },
                        ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Header KPI
                if (state.step == RelatorioClientesStep.sucesso &&
                    state.dados != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.people_outline,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Clientes ativos',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '${state.dados!.meta.totalItems}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Período',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              'Últimos ${state.dias} dias',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Filtros
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtros',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _diasController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Últimos X dias',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  isDense: true,
                                  suffixText: 'dias',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: _selecionarDataRef,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('Ref: ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54)),
                                      Expanded(
                                        child: Text(
                                          _dataReferencia != null
                                              ? _fmtData(_dataReferencia!)
                                              : 'hoje',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                        ),
                                      ),
                                      const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_dataReferencia != null) ...[
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () =>
                                setState(() => _dataReferencia = null),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                            child: const Text('Usar hoje como referência'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _aplicar,
                            icon: const Icon(Icons.search),
                            label: const Text('Consultar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (state.step == RelatorioClientesStep.carregando)
                  const _EstadoCard(
                    titulo: 'Carregando clientes',
                    descricao: 'Buscando clientes ativos...',
                    loading: true,
                  )
                else if (state.step == RelatorioClientesStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.step == RelatorioClientesStep.inicial)
                  const _EstadoCard(
                    titulo: 'Aplique o filtro',
                    descricao:
                        'Informe o período em dias e toque em Consultar.',
                  )
                else if (state.dados != null) ...[
                  if (state.dados!.items.isEmpty)
                    const _EstadoCard(
                      titulo: 'Nenhum cliente encontrado',
                      descricao:
                          'Nenhum cliente com compra no período informado.',
                    )
                  else
                    ...state.dados!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ClienteCard(item: item),
                      ),
                    ),
                  // Paginação
                  if (state.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Anterior'),
                          onPressed: state.page > 1
                              ? () => _aplicar(page: state.page - 1)
                              : null,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${state.page}/${state.totalPages}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_right),
                          label: const Text('Próxima'),
                          onPressed: state.page < state.totalPages
                              ? () => _aplicar(page: state.page + 1)
                              : null,
                        ),
                      ],
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final dynamic item;
  const _ClienteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF6A1B9A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEDE7F6),
                      child: Icon(Icons.person_outline,
                          color: Color(0xFF6A1B9A), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.clienteNome as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                          Text(
                            item.empresaNome as String,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmtMoeda(item.valorTotalComprado as double),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(
                          '${item.quantidadeCompras} compra${(item.quantidadeCompras as int) != 1 ? 's' : ''} · '
                          'Últ: ${_fmtData(item.dataUltimaCompra as String)}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
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
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool loading;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.titulo,
    required this.descricao,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator.adaptive()
              else
                const Icon(Icons.people_outline, size: 40),
              const SizedBox(height: 12),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(descricao,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      );
}
