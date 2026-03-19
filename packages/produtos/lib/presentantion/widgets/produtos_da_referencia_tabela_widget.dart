import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ProdutosDaReferenciaTabelaidget extends StatefulWidget {
  final int referenciaId;
  final bool permitirCriacaoDeNovoProduto;

  const ProdutosDaReferenciaTabelaidget({
    super.key,
    required this.referenciaId,
    this.permitirCriacaoDeNovoProduto = false,
  });

  @override
  State<ProdutosDaReferenciaTabelaidget> createState() =>
      _ProdutosDaReferenciaTabelaidgetState();
}

class _ProdutosDaReferenciaTabelaidgetState
    extends State<ProdutosDaReferenciaTabelaidget> {
  late final ProdutosDaReferenciaBloc _bloc;
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProdutosDaReferenciaBloc>()
      ..add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
  }

  @override
  void dispose() {
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

          return Scrollbar(
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
                  columns: _buildColumns(state.tamanhos),
                  rows: _buildRows(
                    state.cores,
                    state.tamanhos,
                    state.mapaCorTamanhoParaProduto,
                    context,
                  ),
                ),
              ),
            ),
          );
        },
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
    return Icon(Icons.close, size: 18, color: Colors.grey);
  }
}
