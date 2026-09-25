import 'package:core/bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/presentantion/widgets/adicionar_variacoes_painel.dart';

class ReferenciaProdutosTab extends StatefulWidget {
  final int referenciaId;

  const ReferenciaProdutosTab({super.key, required this.referenciaId});

  @override
  State<ReferenciaProdutosTab> createState() => _ReferenciaProdutosTabState();
}

class _ReferenciaProdutosTabState extends State<ReferenciaProdutosTab> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      builder: (context, state) {
        if (state.step == ProdutosDaReferenciaStep.carregando ||
            state.step == ProdutosDaReferenciaStep.inicial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.step == ProdutosDaReferenciaStep.falha) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Falha ao carregar produtos da referência.'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final criando = state.step == ProdutosDaReferenciaStep.criandoProdutos;
        final linhas = state.linhas;
        final totalFaltantes = state.todosOsFaltantes.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBarra(context, state, totalFaltantes, criando),
            const SizedBox(height: 12),
            Expanded(
              child: linhas.isEmpty
                  ? const Center(child: Text('Nenhuma combinação encontrada.'))
                  : Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      child: ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 40,
                            columns: [
                              const DataColumn(label: Text('COR')),
                              const DataColumn(label: Text('ESTAMPA')),
                              ...state.tamanhos.map(
                                (t) => DataColumn(label: Text(t.nome)),
                              ),
                              const DataColumn(label: Text('AÇÃO')),
                            ],
                            rows: linhas.map((linha) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(linha.cor.nome)),
                                  DataCell(Text(linha.estampa.nome)),
                                  ...state.tamanhos.map((tamanho) {
                                    final produto = state.mapaProduto[chaveComboGrade(
                                      linha.cor.id,
                                      tamanho.id,
                                      linha.estampa.id,
                                    )];
                                    if (produto != null) {
                                      final codigo = produto.codigosBarras
                                          .isNotEmpty
                                          ? produto.codigosBarras.first
                                          : '';
                                      final fim = codigo.length > 4
                                          ? codigo.substring(codigo.length - 4)
                                          : codigo;
                                      return DataCell(
                                        Tooltip(
                                          message: codigo,
                                          child: Text('…$fim'),
                                        ),
                                      );
                                    }
                                    return DataCell(
                                      InkWell(
                                        onTap: criando
                                            ? null
                                            : () => context
                                                  .read<ProdutosDaReferenciaBloc>()
                                                  .add(
                                                    ProdutosDaReferenciaCriouCombinacoes(
                                                      combinacoes: [
                                                        ComboDeGrade(
                                                          corId: linha.cor.id,
                                                          tamanhoId: tamanho.id,
                                                          estampaId:
                                                              linha.estampa.id,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0x2E26282A),
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: const Text(
                                            'criar',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  DataCell(
                                    linha.faltantes.isEmpty
                                        ? const SizedBox.shrink()
                                        : TextButton(
                                            onPressed: criando
                                                ? null
                                                : () => context
                                                      .read<ProdutosDaReferenciaBloc>()
                                                      .add(
                                                        ProdutosDaReferenciaCriouCombinacoes(
                                                          combinacoes: linha
                                                              .faltantes
                                                              .map(
                                                                (t) => ComboDeGrade(
                                                                  corId: linha.cor.id,
                                                                  tamanhoId: t.id,
                                                                  estampaId:
                                                                      linha.estampa.id,
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                            child: Text(
                                              'Criar ${linha.faltantes.length}',
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Célula preenchida = produto criado · tracejada = faltando. '
              'Linha = cor × estampa, coluna = tamanho.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarra(
    BuildContext context,
    ProdutosDaReferenciaState state,
    int totalFaltantes,
    bool criando,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Buscar por cor, estampa ou tamanho',
              prefixIcon: Icon(Icons.search, size: 18),
            ),
            onChanged: (texto) => context.read<ProdutosDaReferenciaBloc>().add(
              ProdutosDaReferenciaBuscouAlterou(busca: texto),
            ),
          ),
        ),
        SegmentedButton<FiltroProdutosDaReferencia>(
          segments: const [
            ButtonSegment(
              value: FiltroProdutosDaReferencia.todos,
              label: Text(rotuloFiltroTodos),
            ),
            ButtonSegment(
              value: FiltroProdutosDaReferencia.faltando,
              label: Text(rotuloFiltroFaltando),
            ),
          ],
          selected: {state.filtro},
          onSelectionChanged: (selecionados) => context
              .read<ProdutosDaReferenciaBloc>()
              .add(ProdutosDaReferenciaFiltroAlterou(filtro: selecionados.first)),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final bloc = context.read<ProdutosDaReferenciaBloc>();
            final criouAlgo = await AdicionarVariacoesPainel.show(
              context: context,
              referenciaId: widget.referenciaId,
              corIdsNaGrade: state.cores.map((c) => c.id).toSet(),
              tamanhoIdsNaGrade: state.tamanhos.map((t) => t.id).toSet(),
              estampaIdsNaGrade: state.estampas
                  .where((e) => e.id != null)
                  .map((e) => e.id!)
                  .toSet(),
              chavesNaGrade: state.mapaProduto.keys.toSet(),
            );
            if (criouAlgo == true) {
              bloc.add(
                ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId),
              );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar variações'),
        ),
        if (totalFaltantes > 0)
          FilledButton(
            onPressed: criando
                ? null
                : () => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaCriouCombinacoes(
                      combinacoes: state.todosOsFaltantes,
                    ),
                  ),
            child: Text('Criar todos os faltantes ($totalFaltantes)'),
          ),
        if (criando)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
