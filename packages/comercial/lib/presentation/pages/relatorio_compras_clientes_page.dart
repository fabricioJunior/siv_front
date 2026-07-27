import 'package:comercial/presentation/blocs/relatorio_compras_clientes_bloc/relatorio_compras_clientes_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
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

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

(String, String) _mesAtual() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class RelatorioComprasClientesPage extends StatefulWidget {
  const RelatorioComprasClientesPage({super.key});

  @override
  State<RelatorioComprasClientesPage> createState() =>
      _RelatorioComprasClientesPageState();
}

class _RelatorioComprasClientesPageState
    extends State<RelatorioComprasClientesPage> {
  late final RelatorioComprasClientesBloc _bloc;
  late String _dataInicial;
  late String _dataFinal;
  String _agruparPor = 'produto';
  List<int> _referenciaIdsSelecionados = [];
  List<int> _categoriaIdsSelecionados = [];
  List<int> _corIdsSelecionados = [];
  List<int> _tamanhoIdsSelecionados = [];

  @override
  void initState() {
    super.initState();
    final (ini, fim) = _mesAtual();
    _dataInicial = ini;
    _dataFinal = fim;
    _bloc = sl<RelatorioComprasClientesBloc>()
      ..add(RelatorioComprasClientesCarregar(dataInicial: ini, dataFinal: fim));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _selecionarData(bool isInicial) async {
    final initial = DateTime.tryParse(isInicial ? _dataInicial : _dataFinal);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isInicial) {
        _dataInicial = _isoDate(picked);
      } else {
        _dataFinal = _isoDate(picked);
      }
    });
    _aplicar();
  }

  void _aplicar({int page = 1}) {
    _bloc.add(RelatorioComprasClientesCarregar(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      agruparPor: _agruparPor,
      referenciaIds: _referenciaIdsSelecionados,
      categoriaIds: _categoriaIdsSelecionados,
      corIds: _corIdsSelecionados,
      tamanhoIds: _tamanhoIdsSelecionados,
      page: page,
    ));
  }

  void _onAgruparPorAlterado(String valor) {
    if (_agruparPor == valor) return;
    setState(() {
      _agruparPor = valor;
      _referenciaIdsSelecionados = [];
      _categoriaIdsSelecionados = [];
    });
    _aplicar(page: 1);
  }

  void _onReferenciaSelecionada(List<Referencia> referencias) {
    setState(() {
      _referenciaIdsSelecionados =
          referencias.map((r) => r.id).whereType<int>().toList();
    });
    _aplicar(page: 1);
  }

  void _onCategoriaSelecionada(List<Categoria> categorias) {
    setState(() {
      _categoriaIdsSelecionados =
          categorias.map((c) => c.id).whereType<int>().toList();
    });
    _aplicar(page: 1);
  }

  void _onCorSelecionada(List<Cor> cores) {
    setState(() {
      _corIdsSelecionados = cores.map((c) => c.id).whereType<int>().toList();
    });
    _aplicar(page: 1);
  }

  void _onTamanhoSelecionado(List<Tamanho> tamanhos) {
    setState(() {
      _tamanhoIdsSelecionados =
          tamanhos.map((t) => t.id).whereType<int>().toList();
    });
    _aplicar(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioComprasClientesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioComprasClientesBloc,
          RelatorioComprasClientesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Compras de Clientes')),
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
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'produto',
                                label: Text('Produto'),
                                icon: Icon(Icons.checkroom_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'referencia',
                                label: Text('Referência'),
                                icon: Icon(Icons.style_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'categoria',
                                label: Text('Categoria'),
                                icon: Icon(Icons.category_outlined, size: 16),
                              ),
                            ],
                            selected: {_agruparPor},
                            onSelectionChanged: (selecao) =>
                                _onAgruparPorAlterado(selecao.first),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DateBtn(
                                label: 'De',
                                date: _fmtData(_dataInicial),
                                onTap: () => _selecionarData(true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DateBtn(
                                label: 'Até',
                                date: _fmtData(_dataFinal),
                                onTap: () => _selecionarData(false),
                              ),
                            ),
                          ],
                        ),
                        if (_agruparPor == 'referencia') ...[
                          const SizedBox(height: 10),
                          CategoriaSeletor(
                            key: const ValueKey(
                                'categoria-seletor-compras-clientes'),
                            modo: CategoriaSeletorModo.multipla,
                            titulo: 'Filtrar por categoria',
                            onCategoriaChanged: _onCategoriaSelecionada,
                          ),
                        ] else if (_agruparPor == 'categoria') ...[
                          const SizedBox(height: 10),
                          ReferenciaSeletor(
                            key: const ValueKey(
                                'referencia-seletor-compras-clientes'),
                            modo: ReferenciaSeletorModo.multipla,
                            titulo: 'Filtrar por referência',
                            permitirCadastro: false,
                            onReferenciaChanged: _onReferenciaSelecionada,
                          ),
                        ],
                        const SizedBox(height: 10),
                        CorSeletor(
                          key: const ValueKey('cor-seletor-compras-clientes'),
                          modo: CorSeletorModo.multipla,
                          titulo: 'Filtrar por cor',
                          onCorChanged: _onCorSelecionada,
                        ),
                        const SizedBox(height: 10),
                        TamanhoSeletor(
                          key: const ValueKey(
                              'tamanho-seletor-compras-clientes'),
                          modo: TamanhoSeletorModo.multipla,
                          titulo: 'Filtrar por tamanho',
                          onTamanhosChanged: _onTamanhoSelecionado,
                        ),
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
                if (state.step == RelatorioComprasClientesStep.carregando)
                  const _EstadoCard(
                    titulo: 'Carregando compras',
                    descricao: 'Buscando compras dos clientes...',
                    loading: true,
                  )
                else if (state.step == RelatorioComprasClientesStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.step == RelatorioComprasClientesStep.inicial)
                  const _EstadoCard(
                    titulo: 'Aplique o filtro',
                    descricao: 'Selecione o período e toque em Consultar.',
                  )
                else if (state.dados != null) ...[
                  if (state.dados!.items.isEmpty)
                    const _EstadoCard(
                      titulo: 'Nenhuma compra encontrada',
                      descricao:
                          'Nenhum cliente com compra no período e filtros informados.',
                    )
                  else
                    ...state.dados!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CompraClienteCard(item: item),
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
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
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

class _DateBtn extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _DateBtn(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
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
                child: Text(date,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const Icon(Icons.calendar_today_outlined, size: 16),
            ],
          ),
        ),
      );
}

class _CompraClienteCard extends StatelessWidget {
  final dynamic item;
  const _CompraClienteCard({required this.item});

  String? get _dimensao =>
      item.produtoNome ?? item.referenciaNome ?? item.categoriaNome;

  @override
  Widget build(BuildContext context) {
    final complemento = [item.corNome, item.tamanhoNome]
        .whereType<String>()
        .join(' · ');
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
                color: Color(0xFF00695C),
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
                      backgroundColor: Color(0xFFE0F2F1),
                      child: Icon(Icons.person_outline,
                          color: Color(0xFF00695C), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (item.clienteNome as String).toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          if (_dimensao != null)
                            Text(
                              complemento.isEmpty
                                  ? _dimensao!
                                  : '$_dimensao · $complemento',
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
                          _fmtMoeda(item.valorTotalCompras as double),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${item.totalCompras} compra${(item.totalCompras as int) != 1 ? 's' : ''} · '
                          '${item.quantidadeProdutos} un.',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator.adaptive()
              else
                const Icon(Icons.shopping_bag_outlined, size: 40),
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
