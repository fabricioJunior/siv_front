import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/presentation/blocs/relatorio_produtos_defasados_bloc/relatorio_produtos_defasados_bloc.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final p = iso.split('T').first.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

class RelatorioProdutosDefasadosPage extends StatefulWidget {
  const RelatorioProdutosDefasadosPage({super.key});

  @override
  State<RelatorioProdutosDefasadosPage> createState() =>
      _RelatorioProdutosDefasadosPageState();
}

class _RelatorioProdutosDefasadosPageState
    extends State<RelatorioProdutosDefasadosPage> {
  late final RelatorioProdutosDefasadosBloc _bloc;
  late final TextEditingController _diasController;
  late final TextEditingController _buscaController;
  String _tipoMovimentacao = 'ambas';
  String _visualizacao = 'produto';
  List<Cor> _cores = [];
  List<Tamanho> _tamanhos = [];
  ModoAgrupamentoReferencia _modoAgrupamento =
      ModoAgrupamentoReferencia.todos;

  @override
  void initState() {
    super.initState();
    _diasController = TextEditingController(text: '90');
    _buscaController = TextEditingController();
    _bloc = sl<RelatorioProdutosDefasadosBloc>()
      ..add(RelatorioProdutosDefasadosCarregar());
  }

  @override
  void dispose() {
    _diasController.dispose();
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    final dias = int.tryParse(_diasController.text) ?? 90;
    setState(() {});
    _bloc.add(RelatorioProdutosDefasadosCarregar(
      dias: dias.clamp(1, 3650),
      tipoMovimentacao: _tipoMovimentacao,
      visualizacao: _visualizacao,
      corIds: _cores.isEmpty
          ? null
          : _cores.map((c) => c.id!).toList(),
      tamanhoIds: _tamanhos.isEmpty
          ? null
          : _tamanhos.map((t) => t.id!).toList(),
      modoAgrupamentoReferencia: _modoAgrupamento,
      busca: _buscaController.text.trim().isEmpty
          ? null
          : _buscaController.text.trim(),
      page: page,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioProdutosDefasadosBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioProdutosDefasadosBloc,
          RelatorioProdutosDefasadosState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Produtos Defasados')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (state.step == RelatorioProdutosDefasadosStep.sucesso &&
                    state.dados != null)
                  _ResumoCard(resumo: state.dados!.resumo),

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
                        TextField(
                          controller: _diasController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Dias sem movimentação',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                            suffixText: 'dias',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _buscaController,
                          decoration: InputDecoration(
                            labelText: 'Buscar',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Tipo de movimentação',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'entrada',
                              icon: Icon(Icons.arrow_downward),
                              label: Text('Entrada'),
                            ),
                            ButtonSegment<String>(
                              value: 'saida',
                              icon: Icon(Icons.arrow_upward),
                              label: Text('Saída'),
                            ),
                            ButtonSegment<String>(
                              value: 'ambas',
                              icon: Icon(Icons.swap_vert),
                              label: Text('Ambas'),
                            ),
                          ],
                          selected: {_tipoMovimentacao},
                          onSelectionChanged: (selection) {
                            setState(
                                () => _tipoMovimentacao = selection.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        CorSeletor(
                          modo: CorSeletorModo.multipla,
                          coresSelecionadasIniciais: _cores,
                          onCorChanged: (cores) =>
                              setState(() => _cores = cores),
                        ),
                        const SizedBox(height: 12),
                        TamanhoSeletor(
                          modo: TamanhoSeletorModo.multipla,
                          tamanhosSelecionadosIniciais: _tamanhos,
                          onTamanhosChanged: (tamanhos) =>
                              setState(() => _tamanhos = tamanhos),
                        ),
                        const SizedBox(height: 12),
                        Text('Visualização',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'produto',
                              icon: Icon(Icons.inventory_2_outlined),
                              label: Text('Por produto'),
                            ),
                            ButtonSegment<String>(
                              value: 'referencia',
                              icon: Icon(Icons.category_outlined),
                              label: Text('Por referência'),
                            ),
                          ],
                          selected: {_visualizacao},
                          onSelectionChanged: (selection) {
                            setState(() => _visualizacao = selection.first);
                          },
                        ),
                        if (_visualizacao == 'referencia') ...[
                          const SizedBox(height: 12),
                          Text('Quando a referência conta como defasada',
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          SegmentedButton<ModoAgrupamentoReferencia>(
                            segments: const [
                              ButtonSegment<ModoAgrupamentoReferencia>(
                                value: ModoAgrupamentoReferencia.todos,
                                label: Text('Todos os produtos defasados'),
                              ),
                              ButtonSegment<ModoAgrupamentoReferencia>(
                                value: ModoAgrupamentoReferencia.qualquer,
                                label:
                                    Text('Pelo menos um produto defasado'),
                              ),
                            ],
                            selected: {_modoAgrupamento},
                            onSelectionChanged: (selection) {
                              setState(
                                  () => _modoAgrupamento = selection.first);
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
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

                if (state.step == RelatorioProdutosDefasadosStep.carregando)
                  const _EstadoCard(
                    titulo: 'Carregando produtos',
                    descricao: 'Buscando produtos defasados...',
                    loading: true,
                  )
                else if (state.step == RelatorioProdutosDefasadosStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.step == RelatorioProdutosDefasadosStep.inicial)
                  const _EstadoCard(
                    titulo: 'Aplique o filtro',
                    descricao: 'Informe os filtros e toque em Consultar.',
                  )
                else if (state.dados != null) ...[
                  if (state.dados!.items.isEmpty)
                    const _EstadoCard(
                      titulo: 'Nenhum produto encontrado',
                      descricao:
                          'Nenhum produto defasado com os filtros informados.',
                    )
                  else
                    ...state.dados!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ProdutoDefasadoCard(item: item),
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

class _ResumoCard extends StatelessWidget {
  final dynamic resumo;
  const _ResumoCard({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final percentual = (resumo.percentualDefasado as double);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.warning_amber_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Produtos defasados',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '${resumo.quantidadeDefasados}',
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
                  const Text('% do estoque',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '${percentual.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Valor total defasado: ${_fmtMoeda(resumo.valorTotalDefasado as double)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            'Total em estoque: ${resumo.totalEmEstoque}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProdutoDefasadoCard extends StatelessWidget {
  final dynamic item;
  const _ProdutoDefasadoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dias = item.diasSemMovimentacao as int?;
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
                color: Color(0xFFB71C1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.referenciaNome} · ${item.corNome} · ${item.tamanhoNome}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Text(
                          _fmtMoeda(item.valorTotal as double),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Saldo: ${item.saldo} · Últ. entrada: ${_fmtData(item.ultimaEntrada as String?)} · '
                            'Últ. saída: ${_fmtData(item.ultimaSaida as String?)}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ),
                        if (dias != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$dias dias',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB71C1C)),
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
                const Icon(Icons.inventory_2_outlined, size: 40),
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
