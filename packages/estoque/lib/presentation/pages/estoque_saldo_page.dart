import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';

class EstoqueSaldoPage extends StatefulWidget {
  final ISeletor? seletorCores;
  final ISeletor? seletorTamanhos;

  const EstoqueSaldoPage({super.key, this.seletorCores, this.seletorTamanhos});

  @override
  State<EstoqueSaldoPage> createState() => _EstoqueSaldoPageState();
}

class _EstoqueSaldoPageState extends State<EstoqueSaldoPage> {
  late final EstoqueSaldoBloc _bloc;
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _buscaController = TextEditingController();

  late final StreamSubscription<List<SelectData>>? _corSub;
  late final StreamSubscription<List<SelectData>>? _tamanhoSub;

  List<int> _corIds = const [];
  List<int> _tamanhoIds = const [];

  @override
  void initState() {
    super.initState();
    _bloc = sl<EstoqueSaldoBloc>()..add(const EstoqueSaldoIniciou());

    _corSub = widget.seletorCores?.onDataSelected?.listen((dados) {
      _corIds = dados.map((e) => e.id).toList();
      _recarregar();
    });

    _tamanhoSub = widget.seletorTamanhos?.onDataSelected?.listen((dados) {
      _tamanhoIds = dados.map((e) => e.id).toList();
      _recarregar();
    });
  }

  @override
  void dispose() {
    _corSub?.cancel();
    _tamanhoSub?.cancel();
    _buscaController.dispose();
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
                if (widget.seletorCores != null) ...[
                  widget.seletorCores!,
                  const SizedBox(height: 12),
                ],
                if (widget.seletorTamanhos != null) ...[
                  widget.seletorTamanhos!,
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: BlocBuilder<EstoqueSaldoBloc, EstoqueSaldoState>(
                    builder: (context, state) {
                      if (state.step == EstoqueSaldoStep.carregando) {
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
                        return const Center(
                          child: Text(
                            'Nenhum item encontrado para os filtros informados.',
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total encontrado: ${state.totalItems}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.itens.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: FilledButton.icon(
                              onPressed: state.temMaisPaginas
                                  ? () => _bloc.add(
                                      const EstoqueSaldoCarregarMaisSolicitado(),
                                    )
                                  : null,
                              icon:
                                  state.step == EstoqueSaldoStep.carregandoMais
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: Text(
                                state.temMaisPaginas
                                    ? 'Carregar mais (página ${state.page + 1}/${state.totalPages})'
                                    : 'Fim da lista',
                              ),
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
