import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';

class EstoqueSaldoPage extends StatefulWidget {
  final SeletorWidget seletorCores;
  final SeletorWidget seletorTamanhos;

  const EstoqueSaldoPage({
    super.key,
    required this.seletorCores,
    required this.seletorTamanhos,
  });

  @override
  State<EstoqueSaldoPage> createState() => _EstoqueSaldoPageState();
}

class _EstoqueSaldoPageState extends State<EstoqueSaldoPage> {
  late final EstoqueSaldoBloc _bloc;
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _buscaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<List<SelectData>>? _corSub;
  late final StreamSubscription<List<SelectData>>? _tamanhoSub;

  List<int> _corIds = const [];
  List<int> _tamanhoIds = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bloc = sl<EstoqueSaldoBloc>()..add(const EstoqueSaldoIniciou());
  }

  @override
  void dispose() {
    _corSub?.cancel();
    _tamanhoSub?.cancel();
    _buscaController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _recarregar() {
    _bloc.add(
      EstoqueSaldoIniciou(
        termoBusca: _buscaController.text.trim(),
        corIds: _corIds,
        tamanhoIds: _tamanhoIds,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final state = _bloc.state;
    if (state.step == EstoqueSaldoStep.carregando ||
        state.step == EstoqueSaldoStep.carregandoMais ||
        state.sincronizando ||
        !state.temMaisPaginas) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const EstoqueSaldoCarregarMaisSolicitado());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EstoqueSaldoBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Saldo de Estoque')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  controller: _buscaController,
                  hintText:
                      'Buscar por nome, produto externo ou referência externa',
                  onChanged: (_) => _debouncer.run(_recarregar),
                  onSubmitted: (_) => _recarregar(),
                ),
                const SizedBox(height: 12),
                ...[
                  widget.seletorCores.call(
                    onChanged: (dados) {
                      _corIds = dados.map((e) => e.id).toList();
                      _recarregar();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                ...[
                  widget.seletorTamanhos.call(
                    onChanged: (dados) {
                      _tamanhoIds = dados.map((e) => e.id).toList();
                      _recarregar();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: BlocBuilder<EstoqueSaldoBloc, EstoqueSaldoState>(
                    builder: (context, state) {
                      if (state.step == EstoqueSaldoStep.carregando &&
                          state.itens.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == EstoqueSaldoStep.falha &&
                          state.itens.isEmpty) {
                        return Center(
                          child: Text(
                            state.erro ?? 'Erro ao carregar estoque.',
                          ),
                        );
                      }

                      if (state.itens.isEmpty) {
                        if (state.sincronizando) {
                          return Center(child: _buildSincronizando(context));
                        }

                        return const Center(
                          child: Text(
                            'Nenhum item encontrado para os filtros informados.',
                          ),
                        );
                      }

                      final exibirLoaderFinal =
                          state.step == EstoqueSaldoStep.carregandoMais;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Text(
                                'Total encontrado: ${state.totalItems}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              if (state.sincronizando)
                                _buildSincronizando(context),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              controller: _scrollController,
                              itemCount:
                                  state.itens.length +
                                  (exibirLoaderFinal ? 1 : 0),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index >= state.itens.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  );
                                }

                                final item = state.itens[index];
                                final referenciaIdExterno =
                                    item.referenciaIdExterno
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? item.referenciaIdExterno!
                                    : '-';
                                final unidadeMedida =
                                    item.unidadeMedida?.trim().isNotEmpty ==
                                        true
                                    ? item.unidadeMedida!
                                    : '-';
                                return Card(
                                  child: ListTile(
                                    title: Text(item.nome),
                                    subtitle: Text(
                                      'Ref: $referenciaIdExterno  |  Produto: ${item.produtoIdExterno}\nCor: ${item.corNome}  •  Tam: ${item.tamanhoNome}  •  UM: $unidadeMedida',
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item.saldo.toStringAsFixed(2),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          'Atualizado: ${_formatDate(item.atualizadoEm)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSincronizando(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text('Sincronizando...', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
