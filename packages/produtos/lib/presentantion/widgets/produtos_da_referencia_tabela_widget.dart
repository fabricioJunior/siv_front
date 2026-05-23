import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ProdutosDaReferenciaTabelaWidget extends StatefulWidget {
  final int referenciaId;
  final bool permitirCriacaoDeNovoProduto;

  const ProdutosDaReferenciaTabelaWidget({
    super.key,
    required this.referenciaId,
    this.permitirCriacaoDeNovoProduto = false,
  });

  @override
  State<ProdutosDaReferenciaTabelaWidget> createState() =>
      _ProdutosDaReferenciaTabelaWidgetState();
}

class _ProdutosDaReferenciaTabelaWidgetState
    extends State<ProdutosDaReferenciaTabelaWidget>
    with SingleTickerProviderStateMixin {
  late final ProdutosDaReferenciaBloc _bloc;
  late final TabController _tabController;
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = sl<ProdutosDaReferenciaBloc>()
      ..add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _horizontalController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProdutosDaReferenciaBloc>.value(
      value: _bloc,
      child: BlocBuilder<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
        builder: (context, state) {
          if (state is ProdutosDaReferenciaCarregarEmProgresso ||
              state is ProdutosDaReferenciaInitial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is ProdutosDaReferenciaCarregarFalha) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Falha ao carregar produtos da referência.'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      _bloc.add(
                        ProdutosDaReferenciaIniciou(
                          referenciaId: widget.referenciaId,
                        ),
                      );
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state.produtos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado para esta referência.'),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Grade'),
                  Tab(text: 'Produtos'),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 1) {
                    return _buildProdutosCards(state.produtos);
                  }

                  return _buildGradeTab(
                    context,
                    state.cores,
                    state.tamanhos,
                    state.mapaCorTamanhoParaProduto,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradeTab(
    BuildContext context,
    List<Cor> cores,
    List<Tamanho> tamanhos,
    Map<String, Produto> mapaCorTamanhoParaProduto,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDisponiveisListas(cores, tamanhos),
        const SizedBox(height: 12),
        Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: DataTable(
                columns: _buildColumns(tamanhos),
                rows: _buildRows(
                  cores,
                  tamanhos,
                  mapaCorTamanhoParaProduto,
                  context,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProdutosCards(List<Produto> produtos) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: produtos
          .map(
            (produto) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('Produto #${produto.id ?? '-'}'),
                subtitle: Text(
                  'ID externo: ${produto.idExterno}\nCor: ${produto.cor?.nome ?? produto.corId} • Tamanho: ${produto.tamanho?.nome ?? produto.tamanhoId}',
                ),
                trailing: IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Exclusão pendente de alinhamento com backend',
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildDisponiveisListas(List<Cor> cores, List<Tamanho> tamanhos) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildListaDisponivelCard(
          titulo: 'Cores disponíveis',
          icone: Icons.palette_outlined,
          itens: cores.map((cor) => cor.nome).toList(growable: false),
        ),
        _buildListaDisponivelCard(
          titulo: 'Tamanhos disponíveis',
          icone: Icons.straighten_outlined,
          itens: tamanhos.map((tamanho) => tamanho.nome).toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildListaDisponivelCard({
    required String titulo,
    required IconData icone,
    required List<String> itens,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 18),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: itens
                .map(
                  (item) => Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(item),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(List<Tamanho> tamanhos) {
    return [
      const DataColumn(label: Center(child: Text('Cor \\ Tamanho'))),
      ...tamanhos.map(
        (tamanho) => DataColumn(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: Text(tamanho.nome, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildRows(
    List<Cor> cores,
    List<Tamanho> tamanhos,
    Map<String, Produto> mapaCorTamanhoParaProduto,
    BuildContext context,
  ) {
    return cores.map((cor) {
      return DataRow(
        cells: [
          DataCell(Text(cor.nome)),
          ...tamanhos.map((tamanho) {
            final chave = '${cor.id}_${tamanho.id}';
            final existe = mapaCorTamanhoParaProduto.containsKey(chave);
            return DataCell(
              Center(
                child: existe
                    ? const Text('0')
                    : _buildeActionProdutoInesistente(
                        existe,
                        context,
                        cor.id!,
                        tamanho.id!,
                      ),
              ),
            );
          }),
        ],
      );
    }).toList();
  }

  Widget _buildeActionProdutoInesistente(
    bool existe,
    BuildContext context,
    int corId,
    int tamanhoId,
  ) {
    if (!existe && widget.permitirCriacaoDeNovoProduto) {
      return IconButton(
        icon: const Icon(Icons.add, size: 18),
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/produto',
            arguments: {
              'referenciaId': widget.referenciaId,
              'corId': corId,
              'tamanhoId': tamanhoId,
            },
          );
        },
      );
    }
    return const Icon(Icons.close, size: 18, color: Colors.grey);
  }
}
