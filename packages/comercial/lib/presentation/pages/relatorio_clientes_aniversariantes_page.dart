import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_clientes_aniversariantes_bloc/relatorio_clientes_aniversariantes_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String _fmtData(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class RelatorioClientesAniversariantesPage extends StatefulWidget {
  const RelatorioClientesAniversariantesPage({super.key});

  @override
  State<RelatorioClientesAniversariantesPage> createState() =>
      _RelatorioClientesAniversariantesPageState();
}

class _RelatorioClientesAniversariantesPageState
    extends State<RelatorioClientesAniversariantesPage> {
  late final RelatorioClientesAniversariantesBloc _bloc;
  late int _mes;
  String? _dataUltimaCompraInicial;
  String? _dataUltimaCompraFinal;

  @override
  void initState() {
    super.initState();
    _mes = DateTime.now().month;
    _bloc = sl<RelatorioClientesAniversariantesBloc>()
      ..add(RelatorioClientesAniversariantesCarregar(mes: _mes));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    _bloc.add(RelatorioClientesAniversariantesCarregar(
      mes: _mes,
      dataUltimaCompraInicial: _dataUltimaCompraInicial,
      dataUltimaCompraFinal: _dataUltimaCompraFinal,
      page: page,
    ));
  }

  Future<void> _abrirFiltroPeriodoUltimaCompra() async {
    final agora = DateTime.now();
    final resultado = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual:
          DateTime.tryParse(_dataUltimaCompraInicial ?? '') ?? agora,
      dataFimAtual: DateTime.tryParse(_dataUltimaCompraFinal ?? '') ?? agora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      permitirHora: false,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _dataUltimaCompraInicial = _isoDate(resultado.dataInicio);
      _dataUltimaCompraFinal = _isoDate(resultado.dataFim);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioClientesAniversariantesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioClientesAniversariantesBloc,
          RelatorioClientesAniversariantesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Clientes Aniversariantes')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
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
                        DropdownButtonFormField<int>(
                          value: _mes,
                          decoration: InputDecoration(
                            labelText: 'Mês',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                          ),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(_meses[i]),
                            ),
                          ),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _mes = v);
                          },
                        ),
                        const SizedBox(height: 10),
                        Text('Última compra entre',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        _CampoData(
                          label: 'Período',
                          valorInicial: _dataUltimaCompraInicial,
                          valorFinal: _dataUltimaCompraFinal,
                          onTap: _abrirFiltroPeriodoUltimaCompra,
                        ),
                        if (_dataUltimaCompraInicial != null ||
                            _dataUltimaCompraFinal != null) ...[
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => setState(() {
                              _dataUltimaCompraInicial = null;
                              _dataUltimaCompraFinal = null;
                            }),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                            child: const Text('Limpar filtro de data'),
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
                if (state.step == RelatorioClientesAniversariantesStep.carregando)
                  const _EstadoCard(
                    titulo: 'Carregando clientes',
                    descricao: 'Buscando aniversariantes...',
                    loading: true,
                  )
                else if (state.step == RelatorioClientesAniversariantesStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.dados != null) ...[
                  if (state.dados!.items.isEmpty)
                    const _EstadoCard(
                      titulo: 'Nenhum cliente encontrado',
                      descricao: 'Nenhum aniversariante no período informado.',
                    )
                  else
                    ...state.dados!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ClienteCard(
                          item: item,
                          onTap: () => Navigator.of(context).pushNamed(
                            '/cliente_compras',
                            arguments: {
                              'pessoaId': item.pessoaId,
                              'nome': item.nome,
                            },
                          ),
                        ),
                      ),
                    ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${state.page}/${state.totalPages}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
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

class _CampoData extends StatelessWidget {
  final String label;
  final String? valorInicial;
  final String? valorFinal;
  final VoidCallback onTap;

  const _CampoData({
    required this.label,
    this.valorInicial,
    this.valorFinal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final valor = valorInicial == null && valorFinal == null
        ? '-'
        : '${_fmtData(valorInicial)} - ${_fmtData(valorFinal)}';
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Expanded(
              child: Text(
                valor,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final RelatorioClienteAniversarianteItem item;
  final VoidCallback onTap;

  const _ClienteCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFF57C00),
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
                        backgroundColor: Color(0xFFFFF3E0),
                        child: Icon(Icons.cake_outlined,
                            color: Color(0xFFF57C00), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.nome.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            if ((item.contato ?? '').isNotEmpty)
                              Text(
                                item.contato!,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54),
                              ),
                            if ((item.email ?? '').isNotEmpty)
                              Text(
                                item.email!,
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
                            'Nasc: ${_fmtData(item.nascimento)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            'Últ. compra: ${_fmtData(item.dataUltimaCompra)}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, size: 18),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator.adaptive()
              else
                const Icon(Icons.cake_outlined, size: 40),
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
