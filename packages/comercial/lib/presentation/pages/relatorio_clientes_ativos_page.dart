import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_clientes_bloc/relatorio_clientes_bloc.dart';
import 'package:comercial/presentation/relatorios/csv/relatorio_csv_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
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

String _d2(int n) => n.toString().padLeft(2, '0');

String _fmtUltimaCompra(String iso, [DateTime? agora]) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '-';
  final hoje = agora ?? DateTime.now();
  final dias = DateTime(hoje.year, hoje.month, hoje.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (dias <= 0) {
    return iso.length > 10 ? 'Hoje, ${_d2(d.hour)}:${_d2(d.minute)}' : 'Hoje';
  }
  if (dias == 1) return 'Ontem';
  if (dias <= 7) return '$dias dias atrás';
  return '${_d2(d.day)}/${_d2(d.month)}';
}

String? _local(RelatorioClienteAtivoItem i) {
  final m = i.clienteMunicipio?.trim() ?? '';
  final u = i.clienteUf?.trim() ?? '';
  if (m.isEmpty) return u.isEmpty ? null : u;
  return u.isEmpty ? m : '$m/$u';
}

String _fmtCompras(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

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
  bool _exportandoCsv = false;
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
      page: page,
    ));
  }

  Future<void> _escolherDias() async {
    final c = TextEditingController(text: '$_dias');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ativos nos últimos'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'dias'),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    final texto = c.text;
    c.dispose();
    if (ok != true) return;
    _diasController.text = texto;
    _aplicar();
  }

  Future<void> _exportarCsv() async {
    setState(() => _exportandoCsv = true);
    try {
      final caminho = await RelatorioCsvExporter.exportarClientesAtivos(
        _bloc.state.dados!.items,
      );
      if (mounted) {
        if (caminho != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Relatório salvo em $caminho')),
          );
        }
        setState(() => _exportandoCsv = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
        setState(() => _exportandoCsv = false);
      }
    }
  }

  void _abrirCliente(RelatorioClienteAtivoItem i) =>
      Navigator.of(context).pushNamed(
        '/pessoa_visualizacao',
        arguments: {'idPessoa': i.clienteId, 'aba': 'compras'},
      );

  List<Widget> _kpis(RelatorioClientesState state) {
    final r = state.dados!.resumo;
    final mobile = relatorioMobile(context);
    if (r == null) {
      return [
        RelatorioKpiCard(
          rotulo: 'CLIENTES ATIVOS',
          valor: '${state.dados!.meta.totalItems}',
          destaque: true,
        ),
      ];
    }
    return [
      RelatorioKpiCard(
        rotulo: 'CLIENTES ATIVOS',
        valor: '${r.quantidadeClientes}',
        destaque: true,
      ),
      RelatorioKpiCard(rotulo: 'TICKET MÉDIO', valor: _fmtMoeda(r.ticketMedio)),
      if (!mobile)
        RelatorioKpiCard(
          rotulo: 'COMPRAS/CLIENTE',
          valor: _fmtCompras(r.comprasPorCliente),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioClientesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioClientesBloc, RelatorioClientesState>(
        builder: (context, state) {
          final pronto =
              state.step == RelatorioClientesStep.sucesso && state.dados != null;
          final itens = pronto ? state.dados!.items : const <RelatorioClienteAtivoItem>[];
          final cores = context.sivColors;
          final textos = context.sivTextos;
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Clientes Ativos',
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Ativos nos últimos',
                    valor: '${state.dias} dias',
                    onTap: _escolherDias,
                  ),
                ],
                acoes: [
                  if (pronto)
                    _exportandoCsv
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.file_download_outlined,
                                size: 18),
                            label: const Text('Excel'),
                            onPressed: _exportarCsv,
                          ),
                ],
                carregando: state.step == RelatorioClientesStep.carregando ||
                    state.step == RelatorioClientesStep.inicial,
                erro: state.step == RelatorioClientesStep.falha
                    ? (state.erro ?? 'Falha ao carregar')
                    : null,
                onTentarDeNovo: _aplicar,
                vazio: pronto && itens.isEmpty,
                kpis: pronto ? _kpis(state) : const [],
                corpo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RelatorioTabela<RelatorioClienteAtivoItem>(
                      colunas: const [
                        RelatorioColuna(
                            id: 'cliente',
                            titulo: 'Cliente',
                            flex: 4,
                            ordenavel: false),
                        RelatorioColuna(
                            id: 'compras',
                            titulo: 'Compras',
                            numerica: true,
                            ordenavel: false),
                        RelatorioColuna(
                            id: 'total',
                            titulo: 'Total gasto',
                            numerica: true,
                            flex: 2,
                            ordenavel: false),
                        RelatorioColuna(
                            id: 'ultima',
                            titulo: 'Última compra',
                            numerica: true,
                            flex: 2,
                            ordenavel: false),
                      ],
                      itens: itens,
                      onTap: _abrirCliente,
                      celulas: (ctx, i) {
                        final local = _local(i);
                        return [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.clienteNome,
                                style: textos.corpo
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (local != null)
                                Text(local,
                                    style: textos.apoio
                                        .copyWith(color: cores.textoApoio)),
                            ],
                          ),
                          Text('${i.quantidadeCompras}', style: textos.corpo),
                          Text(
                            _fmtMoeda(i.valorTotalComprado),
                            style: textos.corpo
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _fmtUltimaCompra(i.dataUltimaCompra),
                            style: textos.corpo
                                .copyWith(color: cores.textoApoio),
                          ),
                        ];
                      },
                      itemMobile: (ctx, i) => RelatorioItemMobile(
                        titulo: i.clienteNome,
                        apoio: [
                          if (_local(i) != null) _local(i)!,
                          '${i.quantidadeCompras} compra${i.quantidadeCompras != 1 ? 's' : ''}',
                          _fmtUltimaCompra(i.dataUltimaCompra),
                        ],
                        valor: _fmtMoeda(i.valorTotalComprado),
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
                          Text('${state.page}/${state.totalPages}',
                              style: textos.corpo),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
