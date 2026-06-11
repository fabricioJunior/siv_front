import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class SelecionarProdutosPage extends StatefulWidget {
  final List<int> idsSelecionadosIniciais;

  const SelecionarProdutosPage({
    super.key,
    this.idsSelecionadosIniciais = const [],
  });

  @override
  State<SelecionarProdutosPage> createState() => _SelecionarProdutosPageState();
}

class _SelecionarProdutosPageState extends State<SelecionarProdutosPage> {
  late final ProdutosBloc _produtosBloc;
  final TextEditingController _buscaController = TextEditingController();

  late Set<int> _idsSelecionados;
  Set<int> _referenciasSelecionadas = {};
  Set<int> _coresSelecionadas = {};
  Set<int> _tamanhosSelecionados = {};

  @override
  void initState() {
    super.initState();
    _idsSelecionados = widget.idsSelecionadosIniciais.toSet();
    _produtosBloc = sl<ProdutosBloc>()..add(ProdutosIniciou());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _produtosBloc.close();
    super.dispose();
  }

  void _toggleProduto(int id) {
    setState(() {
      if (_idsSelecionados.contains(id)) {
        _idsSelecionados.remove(id);
      } else {
        _idsSelecionados.add(id);
      }
    });
  }

  void _selecionarTodosDisponiveis(List<Produto> produtos) {
    final ids = produtos.map((e) => e.id).whereType<int>();
    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  void _limparSelecao() {
    setState(() {
      _idsSelecionados.clear();
    });
  }

  void _selecionarPorReferencia(List<Produto> produtos) {
    if (_referenciasSelecionadas.isEmpty) return;

    final ids = produtos
        .where((p) => p.id != null && _referenciasSelecionadas.contains(p.referenciaId))
        .map((p) => p.id!)
        .toSet();

    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  void _selecionarPorCor(List<Produto> produtos) {
    if (_coresSelecionadas.isEmpty) return;

    final ids = produtos
        .where((p) => p.id != null && _coresSelecionadas.contains(p.corId))
        .map((p) => p.id!)
        .toSet();

    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  void _selecionarPorTamanho(List<Produto> produtos) {
    if (_tamanhosSelecionados.isEmpty) return;

    final ids = produtos
        .where((p) => p.id != null && _tamanhosSelecionados.contains(p.tamanhoId))
        .map((p) => p.id!)
        .toSet();

    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  void _selecionarPorFiltrosCombinados(List<Produto> produtos) {
    final ids = produtos
        .where((p) => p.id != null)
        .where(
          (p) => _referenciasSelecionadas.isEmpty ||
              _referenciasSelecionadas.contains(p.referenciaId),
        )
        .where((p) => _coresSelecionadas.isEmpty || _coresSelecionadas.contains(p.corId))
        .where(
          (p) => _tamanhosSelecionados.isEmpty ||
              _tamanhosSelecionados.contains(p.tamanhoId),
        )
        .map((p) => p.id!)
        .toSet();

    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  List<Produto> _filtrarProdutos(List<Produto> produtos) {
    final busca = _buscaController.text.trim().toLowerCase();

    return produtos.where((p) {
      final passaReferencia = _referenciasSelecionadas.isEmpty ||
          _referenciasSelecionadas.contains(p.referenciaId);
      final passaCor = _coresSelecionadas.isEmpty || _coresSelecionadas.contains(p.corId);
      final passaTamanho =
          _tamanhosSelecionados.isEmpty || _tamanhosSelecionados.contains(p.tamanhoId);

      if (!(passaReferencia && passaCor && passaTamanho)) {
        return false;
      }

      if (busca.isEmpty) {
        return true;
      }

      final id = p.id?.toString() ?? '';
      final idExterno = p.idExterno.toLowerCase();
      final referencia = (p.referencia?.nome ?? '').toLowerCase();
      final cor = (p.cor?.nome ?? '').toLowerCase();
      final tamanho = (p.tamanho?.nome ?? '').toLowerCase();

      return id.contains(busca) ||
          idExterno.contains(busca) ||
          referencia.contains(busca) ||
          cor.contains(busca) ||
          tamanho.contains(busca);
    }).toList();
  }

  void _retornarSelecao() {
    final ids = _idsSelecionados.toList()..sort();
    Navigator.of(context).pop(ids);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProdutosBloc>.value(
      value: _produtosBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleção de Produtos'),
          actions: [
            TextButton(
              onPressed: _retornarSelecao,
              child: const Text('Concluir'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReferenciaSeletor(
                      modo: ReferenciaSeletorModo.multipla,
                      titulo: 'Filtrar por referência',
                      onReferenciaChanged: (selecionadas) {
                        setState(() {
                          _referenciasSelecionadas = selecionadas
                              .map((r) => r.id)
                              .whereType<int>()
                              .toSet();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    CorSeletor(
                      modo: CorSeletorModo.multipla,
                      titulo: 'Filtrar por cor',
                      onCorChanged: (selecionadas) {
                        setState(() {
                          _coresSelecionadas = selecionadas
                              .map((c) => c.id)
                              .whereType<int>()
                              .toSet();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TamanhoSeletor(
                      modo: TamanhoSeletorModo.multipla,
                      titulo: 'Filtrar por tamanho',
                      onTamanhosChanged: (selecionados) {
                        setState(() {
                          _tamanhosSelecionados = selecionados
                              .map((t) => t.id)
                              .whereType<int>()
                              .toSet();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      controller: _buscaController,
                      hintText: 'Buscar por ID, ID externo, referência, cor...',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ProdutosBloc, ProdutosState>(
                  builder: (context, state) {
                    final produtos = state.produtos;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: produtos.isEmpty
                              ? null
                              : () => _selecionarPorReferencia(produtos),
                          child: const Text('Selecionar por referência'),
                        ),
                        OutlinedButton(
                          onPressed: produtos.isEmpty
                              ? null
                              : () => _selecionarPorCor(produtos),
                          child: const Text('Selecionar por cor'),
                        ),
                        OutlinedButton(
                          onPressed: produtos.isEmpty
                              ? null
                              : () => _selecionarPorTamanho(produtos),
                          child: const Text('Selecionar por tamanho'),
                        ),
                        FilledButton.tonal(
                          onPressed: produtos.isEmpty
                              ? null
                              : () => _selecionarPorFiltrosCombinados(produtos),
                          child: const Text('Selecionar por filtros'),
                        ),
                        FilledButton(
                          onPressed: produtos.isEmpty
                              ? null
                              : () => _selecionarTodosDisponiveis(produtos),
                          child: const Text('Selecionar todos disponíveis'),
                        ),
                        TextButton(
                          onPressed: _idsSelecionados.isEmpty ? null : _limparSelecao,
                          child: const Text('Remover todos selecionados'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.checklist, size: 18),
                    const SizedBox(width: 8),
                    Text('Selecionados: ${_idsSelecionados.length}'),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ProdutosBloc, ProdutosState>(
                  builder: (context, state) {
                    if (state is ProdutosCarregarEmProgresso ||
                        state is ProdutosExcluirEmProgresso) {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }

                    if (state is ProdutosCarregarFalha ||
                        state is ProdutosExcluirFalha) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            const Text('Erro ao carregar produtos.'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _produtosBloc.add(ProdutosIniciou()),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    final produtosFiltrados = _filtrarProdutos(state.produtos);
                    if (produtosFiltrados.isEmpty) {
                      return const Center(
                        child: Text('Nenhum produto encontrado para os filtros informados.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: produtosFiltrados.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final produto = produtosFiltrados[index];
                        final produtoId = produto.id;
                        final selecionado = produtoId != null && _idsSelecionados.contains(produtoId);

                        return CheckboxListTile(
                          value: selecionado,
                          onChanged: produtoId == null
                              ? null
                              : (_) => _toggleProduto(produtoId),
                          title: Text(
                            'Ref: ${produto.referencia?.nome ?? '-'}',
                          ),
                          subtitle: Text(
                            'ID: ${produto.id ?? '-'} | Cor: ${produto.cor?.nome ?? '-'} | Tamanho: ${produto.tamanho?.nome ?? '-'}',
                          ),
                          secondary: Icon(
                            selecionado ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: selecionado ? Colors.green : null,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _retornarSelecao,
                    icon: const Icon(Icons.done),
                    label: const Text('Retornar IDs selecionados'),
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
