import 'package:core/injecoes.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/bloc.dart';
import 'package:estoque/presentation/bloc/lote/lote_bloc.dart';
import 'package:flutter/material.dart';

class DetalhesLoteBalancoPage extends StatefulWidget {
  final int balancoId;
  final int loteId;
  final bool balancoFinalizado;

  const DetalhesLoteBalancoPage({
    Key? key,
    required this.balancoId,
    required this.loteId,
    required this.balancoFinalizado,
  }) : super(key: key);

  @override
  State<DetalhesLoteBalancoPage> createState() =>
      _DetalhesLoteBalancoPageState();
}

class _DetalhesLoteBalancoPageState extends State<DetalhesLoteBalancoPage> {
  final LeitorController _leitorController = LeitorController();
  List<ProdutosPreCarregado>? _produtosPreCarregados;
  bool _estadoInicialSincronizado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoteBloc>().add(
        CarregarItensDoLoteEvent(
          balancoId: widget.balancoId,
          loteId: widget.loteId,
        ),
      );
    });
  }

  @override
  void dispose() {
    _leitorController.dispose();
    super.dispose();
  }

  void _sincronizarEstadoInicialComLote(LoteState state) {
    if (_estadoInicialSincronizado || state.status != LoteStatus.ready) {
      return;
    }

    _estadoInicialSincronizado = true;
    _produtosPreCarregados = state.itens
        .map(
          (item) => ProdutosPreCarregado(
            id: item.produtoId,
            quantidade: item.quantidadeContada.round(),
          ),
        )
        .where((item) => item.quantidade > 0)
        .toList(growable: false);
    setState(() {});
  }

  void _atualizarBaseAposSucesso(LoteState state) {
    if (state.status != LoteStatus.success) return;
  }

  void _salvarItensLidos() {
    final loteBloc = context.read<LoteBloc>();
    if (loteBloc.state.status == LoteStatus.loading) {
      return;
    }

    loteBloc.add(
      SalvarLeituraDoLoteEvent(
        balancoId: widget.balancoId,
        loteId: widget.loteId,
        itensLidos: _leitorController.itens
            .where((item) => item.quantidadeLida > 0)
            .map(
              (item) => LoteLeituraItem(
                produtoId: item.id,
                quantidadeContada: item.quantidadeLida.toDouble(),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LoteBloc, LoteState>(
          builder: (context, state) {
            final descricaoLote = state.lote?.lote;
            if (descricaoLote != null && descricaoLote.trim().isNotEmpty) {
              return Text(descricaoLote);
            }
            return Text('Lote #${widget.loteId}');
          },
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _leitorController,
        builder: (context, _) {
          return BlocBuilder<LoteBloc, LoteState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final podeSalvar =
                  _leitorController.itens.isNotEmpty || state.itens.isNotEmpty;
              if (!podeSalvar || widget.balancoFinalizado) {
                return const SizedBox.shrink();
              }

              final carregando = state.status == LoteStatus.loading;

              return FloatingActionButton(
                onPressed: carregando ? null : _salvarItensLidos,
                child: carregando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.check),
              );
            },
          );
        },
      ),
      body: BlocListener<LoteBloc, LoteState>(
        listener: (context, state) {
          _sincronizarEstadoInicialComLote(state);
          _atualizarBaseAposSucesso(state);

          if (state.status == LoteStatus.error && state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          } else if (state.status == LoteStatus.success &&
              state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        child: BlocBuilder<LoteBloc, LoteState>(
          builder: (context, state) {
            return Stack(
              children: [
                CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    if (state.status == LoteStatus.loading &&
                        state.itens.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Descrição: ${state.lote?.lote ?? '-'}',
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      ListenableBuilder(
                                        listenable: _leitorController,
                                        builder: (context, _) {
                                          final contados = _leitorController.itens
                                              .where((i) => i.quantidadeLida > 0)
                                              .length;
                                          if (contados == 0) return const SizedBox.shrink();
                                          return Chip(
                                            label: Text('$contados produto(s)'),
                                            avatar: const Icon(Icons.check_circle_outline, size: 16),
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Observação: ${state.lote?.observacao?.trim().isNotEmpty == true ? state.lote!.observacao : '-'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!(state.status == LoteStatus.loading &&
                        state.itens.isEmpty))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: LeitorWidget(
                            controller: _leitorController,
                            dataSource: sl<ILeitorDataDatasource>(),
                            buscaDataSource: sl<ILeitorBuscaDataDatasource>(),
                            controlarQuantidade: false,
                            aceitarApenasProdutosComPreco: false,
                            desativado: widget.balancoFinalizado,
                            produtosPreCarregados: _produtosPreCarregados,
                            campoCodigoHint:
                                'Bipe ou informe o código do produto',
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
                if (state.status == LoteStatus.loading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withOpacity(0.08),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
