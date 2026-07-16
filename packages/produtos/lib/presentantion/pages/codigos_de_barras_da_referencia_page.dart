import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class CodigosDeBarrasDaReferenciaPage extends StatefulWidget {
  final int referenciaId;

  const CodigosDeBarrasDaReferenciaPage({
    super.key,
    required this.referenciaId,
  });

  @override
  State<CodigosDeBarrasDaReferenciaPage> createState() =>
      _CodigosDeBarrasDaReferenciaPageState();
}

class _CodigosDeBarrasDaReferenciaPageState
    extends State<CodigosDeBarrasDaReferenciaPage> {
  late final CodigosDeBarrasDaReferenciaBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bloc = sl<CodigosDeBarrasDaReferenciaBloc>()
      ..add(
        CodigosDeBarrasDaReferenciaIniciou(referenciaId: widget.referenciaId),
      );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    if (state.step == CodigosDeBarrasDaReferenciaStep.carregando ||
        state.step == CodigosDeBarrasDaReferenciaStep.carregandoMais ||
        !state.temMaisPaginas) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const CodigosDeBarrasDaReferenciaCarregarMaisSolicitado());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CodigosDeBarrasDaReferenciaBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Códigos de barras da referência')),
        body: SafeArea(
          child: BlocBuilder<CodigosDeBarrasDaReferenciaBloc,
              CodigosDeBarrasDaReferenciaState>(
            builder: (context, state) {
              if (state.step == CodigosDeBarrasDaReferenciaStep.carregando &&
                  state.itens.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state.step == CodigosDeBarrasDaReferenciaStep.falha &&
                  state.itens.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.erro ?? 'Erro ao carregar códigos de barras.',
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          _bloc.add(
                            CodigosDeBarrasDaReferenciaIniciou(
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

              if (state.itens.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum código de barras cadastrado para esta referência.',
                  ),
                );
              }

              final agrupado = state.codigosPorProduto;
              final produtoIds = agrupado.keys.toList()
                ..sort((a, b) => a.compareTo(b));

              final exibirLoaderFinal =
                  state.step == CodigosDeBarrasDaReferenciaStep.carregandoMais;

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: produtoIds.length + (exibirLoaderFinal ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= produtoIds.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }

                  final produtoId = produtoIds[index];
                  final produto = state.mapaProdutos[produtoId];
                  final codigos = agrupado[produtoId] ?? const [];

                  return _ProdutoCodigosCard(
                    produtoId: produtoId,
                    produto: produto,
                    codigos: codigos,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProdutoCodigosCard extends StatelessWidget {
  final int produtoId;
  final Produto? produto;
  final List<CodigoBarrasResumo> codigos;

  const _ProdutoCodigosCard({
    required this.produtoId,
    required this.produto,
    required this.codigos,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final identificacao = produto == null
        ? 'Produto #$produtoId'
        : 'Produto #$produtoId  •  ${produto!.idExterno}'
            '${produto!.cor != null ? ' • ${produto!.cor!.nome}' : ''}'
            '${produto!.tamanho != null ? ' • ${produto!.tamanho!.nome}' : ''}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              identificacao,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: codigos
                  .map(
                    (codigo) => Chip(
                      avatar: const Icon(Icons.barcode_reader, size: 16),
                      label: Text(codigo.codigo),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
