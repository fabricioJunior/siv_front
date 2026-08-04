import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class ProdutosDaReferenciaTabelaWidget extends StatefulWidget {
  final int referenciaId;
  final bool permitirCriacaoDeNovoProduto;

  /// Alterar esse valor (ex: incrementando um contador no widget pai)
  /// força um novo fetch dos produtos, mesmo com o mesmo [referenciaId].
  final Object? refreshTrigger;

  const ProdutosDaReferenciaTabelaWidget({
    super.key,
    required this.referenciaId,
    this.permitirCriacaoDeNovoProduto = false,
    this.refreshTrigger,
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

  bool _modoSelecaoExclusao = false;
  bool _excluindo = false;
  final Set<int> _idsSelecionadosParaExclusao = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = sl<ProdutosDaReferenciaBloc>()
      ..add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
  }

  @override
  void didUpdateWidget(ProdutosDaReferenciaTabelaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referenciaId != widget.referenciaId ||
        oldWidget.refreshTrigger != widget.refreshTrigger) {
      _bloc.add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
    }
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
                    return _buildProdutosCards(
                      state.produtos,
                      state.mapaCorTamanhoParaSaldo,
                      state.saldoIndisponivel,
                    );
                  }

                  return _buildGradeTab(
                    context,
                    state.cores,
                    state.tamanhos,
                    state.mapaCorTamanhoParaProduto,
                    state.mapaCorTamanhoParaSaldo,
                    state.saldoIndisponivel,
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
    Map<String, double> mapaCorTamanhoParaSaldo,
    bool saldoIndisponivel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDisponiveisListas(cores, tamanhos),
        if (saldoIndisponivel) ...[
          const SizedBox(height: 8),
          const Text(
            'Não foi possível carregar o saldo de estoque. Exibindo "-".',
            style: TextStyle(color: Colors.orange),
          ),
        ],
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
                  mapaCorTamanhoParaSaldo,
                  saldoIndisponivel,
                  context,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProdutosCards(
    List<Produto> produtos,
    Map<String, double> mapaCorTamanhoParaSaldo,
    bool saldoIndisponivel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBarraSelecaoExclusao(),
        const SizedBox(height: 8),
        ...produtos.map(
          (produto) => _buildProdutoCard(
            produto,
            mapaCorTamanhoParaSaldo,
            saldoIndisponivel,
          ),
        ),
      ],
    );
  }

  Widget _buildProdutoCard(
    Produto produto,
    Map<String, double> mapaCorTamanhoParaSaldo,
    bool saldoIndisponivel,
  ) {
    final chave = '${produto.corId}_${produto.tamanhoId}';
    final saldo = saldoIndisponivel ? null : mapaCorTamanhoParaSaldo[chave];
    final selecionado = _idsSelecionadosParaExclusao.contains(produto.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _modoSelecaoExclusao
            ? Checkbox(
                value: selecionado,
                onChanged: produto.id == null
                    ? null
                    : (_) => _alternarSelecaoProduto(produto.id!),
              )
            : null,
        title: Text(
          '${produto.cor?.nome ?? produto.corId} • ${produto.tamanho?.nome ?? produto.tamanhoId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'ID externo: ${produto.idExterno}\nEstoque: ${_formatarSaldo(saldo)}',
        ),
        onTap: _modoSelecaoExclusao && produto.id != null
            ? () => _alternarSelecaoProduto(produto.id!)
            : null,
      ),
    );
  }

  Widget _buildBarraSelecaoExclusao() {
    if (!_modoSelecaoExclusao) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: () => setState(() => _modoSelecaoExclusao = true),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Selecionar para excluir'),
        ),
      );
    }

    return Row(
      children: [
        Text('${_idsSelecionadosParaExclusao.length} selecionado(s)'),
        const Spacer(),
        TextButton(
          onPressed: _excluindo
              ? null
              : () => setState(() {
                    _modoSelecaoExclusao = false;
                    _idsSelecionadosParaExclusao.clear();
                  }),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed:
              _idsSelecionadosParaExclusao.isEmpty || _excluindo
                  ? null
                  : _confirmarExclusaoEmLote,
          icon: _excluindo
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
          label: const Text('Excluir selecionados'),
        ),
      ],
    );
  }

  void _alternarSelecaoProduto(int produtoId) {
    setState(() {
      if (!_idsSelecionadosParaExclusao.remove(produtoId)) {
        _idsSelecionadosParaExclusao.add(produtoId);
      }
    });
  }

  Future<void> _confirmarExclusaoEmLote() async {
    final quantidade = _idsSelecionadosParaExclusao.length;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir produtos'),
        content: Text(
          'Excluir $quantidade produto(s) selecionado(s)? Só produtos sem '
          'estoque e sem movimentação em romaneios/pedidos serão excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _excluindo = true);
    try {
      final resultado = await sl<ExcluirProdutosEmLote>().call(
        _idsSelecionadosParaExclusao.toList(),
      );

      if (!mounted) return;

      setState(() {
        _modoSelecaoExclusao = false;
        _idsSelecionadosParaExclusao.clear();
      });

      _bloc.add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));

      final mensagem = resultado.rejeitados.isEmpty
          ? '${resultado.excluidos.length} produto(s) excluído(s).'
          : '${resultado.excluidos.length} produto(s) excluído(s). '
              '${resultado.rejeitados.length} não puderam ser excluídos.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));

      if (resultado.rejeitados.isNotEmpty) {
        _mostrarProdutosRejeitados(resultado.rejeitados);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao excluir produtos: $e')),
      );
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  void _mostrarProdutosRejeitados(List<ProdutoRejeitadoExclusao> rejeitados) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Produtos não excluídos'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: rejeitados
                .map(
                  (rejeitado) => ListTile(
                    dense: true,
                    title: Text('Produto #${rejeitado.produtoId}'),
                    subtitle: Text(rejeitado.motivo),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
    Map<String, double> mapaCorTamanhoParaSaldo,
    bool saldoIndisponivel,
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
                    ? Text(
                        saldoIndisponivel
                            ? '-'
                            : _formatarSaldo(mapaCorTamanhoParaSaldo[chave]),
                      )
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

  String _formatarSaldo(double? saldo) {
    if (saldo == null) return '-';
    if (saldo == saldo.truncateToDouble()) {
      return saldo.toInt().toString();
    }
    return saldo.toStringAsFixed(2).replaceAll('.', ',');
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
        onPressed: () async {
          final criou = await Navigator.of(context).pushNamed(
            '/produto',
            arguments: {
              'referenciaId': widget.referenciaId,
              'corId': corId,
              'tamanhoId': tamanhoId,
            },
          );

          if (criou == true) {
            _bloc.add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
          }
        },
      );
    }
    return const Icon(Icons.close, size: 18, color: Colors.grey);
  }
}
