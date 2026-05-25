import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class ImpressaoDeEtiquetasPage extends StatelessWidget {
  final SeletorWidget tabelasDePrecoSeletor;

  const ImpressaoDeEtiquetasPage({
    super.key,
    required this.tabelasDePrecoSeletor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImpressaoEtiquetasBloc>(
      create: (_) => sl<ImpressaoEtiquetasBloc>()..add(ImpressaoEtiquetasIniciou()),
      child: _ImpressaoDeEtiquetasView(
        tabelasDePrecoSeletor: tabelasDePrecoSeletor,
      ),
    );
  }
}

class _ImpressaoDeEtiquetasView extends StatefulWidget {
  final SeletorWidget tabelasDePrecoSeletor;

  const _ImpressaoDeEtiquetasView({required this.tabelasDePrecoSeletor});

  @override
  State<_ImpressaoDeEtiquetasView> createState() =>
      _ImpressaoDeEtiquetasViewState();
}

class _ImpressaoDeEtiquetasViewState extends State<_ImpressaoDeEtiquetasView> {
  final Map<int, TextEditingController> _quantidadeControllers = {};

  @override
  void dispose() {
    for (final controller in _quantidadeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImpressaoEtiquetasBloc, ImpressaoEtiquetasState>(
      listenWhen: (previous, current) =>
          previous.erro != current.erro || previous.sucesso != current.sucesso,
      listener: (context, state) {
        final mensagem = state.erro ?? state.sucesso;
        if (mensagem == null || mensagem.trim().isEmpty) {
          return;
        }

        final isErro = state.erro != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensagem,
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isErro ? Colors.redAccent.shade700 : null,
          ),
        );
      },
      builder: (context, state) {
        final bloc = context.read<ImpressaoEtiquetasBloc>();

        return Scaffold(
          appBar: AppBar(title: const Text('Impressao de etiquetas')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Selecao inicial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      EtiquetaSeletor(
                        modo: EtiquetaSeletorModo.unica,
                        onEtiquetaChanged: (selecionadas) {
                          bloc.add(
                            ImpressaoEtiquetasEtiquetaSelecionada(
                              etiqueta: selecionadas.isEmpty
                                  ? null
                                  : selecionadas.first,
                            ),
                          );
                        },
                        titulo: 'Etiqueta da impressao',
                      ),
                      const SizedBox(height: 12),
                      widget.tabelasDePrecoSeletor.buildComParametros(
                        SeletorParamentros(
                          onChanged: (selecionadas) {
                            bloc.add(
                              ImpressaoEtiquetasTabelaSelecionada(
                                tabela: selecionadas.isEmpty
                                    ? null
                                    : selecionadas.first,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ReferenciaSeletor(
                        modo: ReferenciaSeletorModo.unica,
                        onReferenciaChanged: (selecionadas) {
                          bloc.add(
                            ImpressaoEtiquetasReferenciaSelecionada(
                              referencia: selecionadas.isEmpty
                                  ? null
                                  : selecionadas.first,
                            ),
                          );
                        },
                        titulo: 'Referencia',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Grade de produtos da referencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preencha a quantidade em cada combinacao e toque em adicionar etiquetas.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      if (state.carregandoGrade)
                        const Center(child: CircularProgressIndicator.adaptive())
                      else if (state.referenciaSelecionada == null)
                        const Text('Selecione uma referencia para visualizar a grade.')
                      else if (state.produtos.isEmpty)
                        const Text('Nenhum produto encontrado para a referencia selecionada.')
                      else
                        _buildGradeQuantidade(context, state),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          FilledButton.icon(
                            onPressed: state.processando || !state.podeAdicionarEtiquetas
                                ? null
                                : () {
                                    bloc.add(ImpressaoEtiquetasAdicionarSolicitado());
                                  },
                            icon: state.processando
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.playlist_add_outlined),
                            label: Text(
                              state.processando
                                  ? 'Processando...'
                                  : 'Adicionar etiquetas',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Pilha de impressao (${state.pilhaImpressao.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (state.pilhaImpressao.isEmpty)
                        const Text('Nenhuma etiqueta adicionada na pilha.')
                      else
                        ...state.pilhaImpressao
                            .take(8)
                            .map(
                              (item) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.print_outlined, size: 18),
                                title: Text(item.descricao),
                              ),
                            ),
                      if (state.pilhaImpressao.length > 8)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '...e mais ${state.pilhaImpressao.length - 8} etiqueta(s) na pilha.',
                          ),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: state.pilhaImpressao.isEmpty
                                ? null
                                : () {
                                    bloc.add(ImpressaoEtiquetasPilhaLimpaSolicitada());
                                  },
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: const Text('Limpar pilha de impressao'),
                          ),
                          FilledButton.icon(
                            onPressed: state.imprimindo || state.pilhaImpressao.isEmpty
                                ? null
                                : () {
                                    Navigator.of(context).pushNamed(
                                      '/impressao_progress',
                                      arguments: {
                                        'itens': state.pilhaImpressao,
                                      },
                                    );
                                  },
                            icon: const Icon(Icons.print),
                            label: const Text('Imprimir etiquetas'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradeQuantidade(
    BuildContext context,
    ImpressaoEtiquetasState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Cor \\ Tamanho')),
          ...state.tamanhos
              .map((tamanho) => DataColumn(label: Text(tamanho.nome)))
              .toList(growable: false),
        ],
        rows: state.cores.map((cor) {
          return DataRow(
            cells: [
              DataCell(Text(cor.nome)),
              ...state.tamanhos.map((tamanho) {
                final chave = '${cor.id}_${tamanho.id}';
                final produto = state.mapaCorTamanhoParaProduto[chave];

                if (produto?.id == null) {
                  return const DataCell(Center(child: Text('-')));
                }

                final produtoId = produto!.id!;
                final controller = _getController(
                  produtoId,
                  state.quantidadesPorProdutoId[produtoId] ?? 0,
                );

                return DataCell(
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim()) ?? 0;
                        context.read<ImpressaoEtiquetasBloc>().add(
                              ImpressaoEtiquetasQuantidadeAlterada(
                                produtoId: produtoId,
                                quantidade: parsed,
                              ),
                            );
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(growable: false),
      ),
    );
  }

  TextEditingController _getController(int produtoId, int valorAtual) {
    final existente = _quantidadeControllers[produtoId];
    if (existente != null) {
      final textoAtual = valorAtual == 0 ? '' : valorAtual.toString();
      if (existente.text != textoAtual) {
        existente.text = textoAtual;
      }
      return existente;
    }

    final controller = TextEditingController(
      text: valorAtual == 0 ? '' : valorAtual.toString(),
    );
    _quantidadeControllers[produtoId] = controller;
    return controller;
  }
}
