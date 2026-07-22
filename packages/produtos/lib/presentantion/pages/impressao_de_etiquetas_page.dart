import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
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
      create: (_) =>
          sl<ImpressaoEtiquetasBloc>()..add(ImpressaoEtiquetasIniciou()),
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
  final Map<String, TextEditingController> _pilhaQuantidadeControllers = {};

  @override
  void dispose() {
    for (final controller in _quantidadeControllers.values) {
      controller.dispose();
    }
    for (final controller in _pilhaQuantidadeControllers.values) {
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
        final gruposPilha = _agruparPilha(state.pilhaImpressao);

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
                        permitirCadastro: false,
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
                        const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      else if (state.referenciaSelecionada == null)
                        const Text(
                          'Selecione uma referencia para visualizar a grade.',
                        )
                      else if (state.produtos.isEmpty)
                        const Text(
                          'Nenhum produto encontrado para a referencia selecionada.',
                        )
                      else
                        _buildGradeQuantidade(context, state),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          FilledButton.icon(
                            onPressed:
                                state.processando ||
                                    !state.podeAdicionarEtiquetas
                                ? null
                                : () {
                                    bloc.add(
                                      ImpressaoEtiquetasAdicionarSolicitado(),
                                    );
                                  },
                            icon: state.processando
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                      if (state.pilhaImpressao.isNotEmpty) ...[
                        DropdownButtonFormField<PilhaImpressaoOrdenacao>(
                          value: state.pilhaOrdenacao,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Ordenar pilha por',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.insercao,
                              child: Text('Ordem de insercao'),
                            ),
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.referencia,
                              child: Text('Referencia'),
                            ),
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.referenciaCor,
                              child: Text('Referencia + Cor'),
                            ),
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.referenciaTamanho,
                              child: Text('Referencia + Tamanho'),
                            ),
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.cor,
                              child: Text('Cor'),
                            ),
                            DropdownMenuItem(
                              value: PilhaImpressaoOrdenacao.tamanho,
                              child: Text('Tamanho'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            bloc.add(
                              ImpressaoEtiquetasPilhaOrdenacaoAlterada(
                                ordenacao: value,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (state.pilhaImpressao.isEmpty)
                        const Text('Nenhuma etiqueta adicionada na pilha.')
                      else ...[
                        ...gruposPilha
                            .take(8)
                            .map(
                              (grupo) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.print_outlined,
                                  size: 18,
                                ),
                                title: Text(
                                  '${grupo.referencia} | Cor: ${grupo.cor} | Tam: ${grupo.tamanho}',
                                ),
                                subtitle: Text(
                                  '${grupo.quantidade} etiqueta(s)',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      child: TextField(
                                        controller:
                                            _getPilhaQuantidadeController(
                                              grupo.chave,
                                              grupo.quantidade,
                                            ),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Qtd',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          // Campo vazio = usuario apagando pra digitar outro
                                          // numero (edicao em andamento), nao "quero zero" --
                                          // "quero zero" so conta quando ele efetivamente digita
                                          // 0. Sem essa checagem, apagar o texto disparava
                                          // quantidade=0 e removia o item da pilha no meio da
                                          // edicao (bug reportado).
                                          if (value.trim().isEmpty) {
                                            return;
                                          }

                                          final parsed = int.tryParse(
                                            value.trim(),
                                          );
                                          if (parsed == null) {
                                            return;
                                          }

                                          bloc.add(
                                            ImpressaoEtiquetasPilhaQuantidadeAlterada(
                                              referencia: grupo.referencia,
                                              cor: grupo.cor,
                                              tamanho: grupo.tamanho,
                                              quantidade: parsed,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () {
                                        bloc.add(
                                          ImpressaoEtiquetasPilhaItemRemovido(
                                            referencia: grupo.referencia,
                                            cor: grupo.cor,
                                            tamanho: grupo.tamanho,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                      if (gruposPilha.length > 8)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '...e mais ${gruposPilha.length - 8} combinacao(oes) na pilha.',
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
                                    bloc.add(
                                      ImpressaoEtiquetasPilhaLimpaSolicitada(),
                                    );
                                  },
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: const Text('Limpar pilha de impressao'),
                          ),
                          FilledButton.icon(
                            onPressed:
                                state.imprimindo || state.pilhaImpressao.isEmpty
                                ? null
                                : () {
                                    Navigator.of(context).pushNamed(
                                      '/impressao_progress',
                                      arguments: {
                                        'itens': state.pilhaImpressao,
                                        'quantidadeDeVias':
                                            state
                                                .etiquetaSelecionada
                                                ?.vias
                                                .length ??
                                            1,
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
          ...state.tamanhos.map(
            (tamanho) => DataColumn(label: Text(tamanho.nome)),
          ),
        ],
        rows: state.cores
            .map((cor) {
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
            })
            .toList(growable: false),
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

  TextEditingController _getPilhaQuantidadeController(
    String chave,
    int valorAtual,
  ) {
    final existente = _pilhaQuantidadeControllers[chave];
    if (existente != null) {
      final textoAtual = valorAtual <= 0 ? '' : valorAtual.toString();
      if (existente.text != textoAtual) {
        existente.text = textoAtual;
      }
      return existente;
    }

    final controller = TextEditingController(
      text: valorAtual <= 0 ? '' : valorAtual.toString(),
    );
    _pilhaQuantidadeControllers[chave] = controller;
    return controller;
  }

  List<_PilhaGrupoResumo> _agruparPilha(List<EtiquetaImpressaoItem> itens) {
    final grupos = <String, _PilhaGrupoResumo>{};

    for (final item in itens) {
      final chave = '${item.referencia}__${item.cor}__${item.tamanho}';
      final existente = grupos[chave];

      if (existente == null) {
        grupos[chave] = _PilhaGrupoResumo(
          chave: chave,
          referencia: item.referencia,
          cor: item.cor,
          tamanho: item.tamanho,
          quantidade: 1,
        );
      } else {
        grupos[chave] = existente.copyWith(
          quantidade: existente.quantidade + 1,
        );
      }
    }

    final chavesAtivas = grupos.keys.toSet();
    final chavesParaRemover = _pilhaQuantidadeControllers.keys
        .where((chave) => !chavesAtivas.contains(chave))
        .toList(growable: false);
    for (final chave in chavesParaRemover) {
      _pilhaQuantidadeControllers.remove(chave)?.dispose();
    }

    return grupos.values.toList(growable: false);
  }
}

class _PilhaGrupoResumo {
  final String chave;
  final String referencia;
  final String cor;
  final String tamanho;
  final int quantidade;

  const _PilhaGrupoResumo({
    required this.chave,
    required this.referencia,
    required this.cor,
    required this.tamanho,
    required this.quantidade,
  });

  _PilhaGrupoResumo copyWith({
    String? chave,
    String? referencia,
    String? cor,
    String? tamanho,
    int? quantidade,
  }) {
    return _PilhaGrupoResumo(
      chave: chave ?? this.chave,
      referencia: referencia ?? this.referencia,
      cor: cor ?? this.cor,
      tamanho: tamanho ?? this.tamanho,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}
