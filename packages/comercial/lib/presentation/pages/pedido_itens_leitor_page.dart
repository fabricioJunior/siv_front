import 'package:comercial/presentation/blocs/pedido_bloc/pedido_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:flutter/material.dart';

// Tela dedicada pra adicionar/remover produtos do pedido via leitor de código de barras --
// substitui os antigos fluxos separados (dialog "Adicionar produto" + botão de excluir por linha
// em pedido_page). O usuário bipa/ajusta livremente no LeitorWidget (que já sabe lidar com
// adição/remoção local) e só ao confirmar é que a diferença entre o estado original do pedido e o
// estado final do leitor vira chamadas reais de PedidoItemAdicionou/PedidoItemRemoveu.
class PedidoItensLeitorPage extends StatefulWidget {
  const PedidoItensLeitorPage({super.key});

  @override
  State<PedidoItensLeitorPage> createState() => _PedidoItensLeitorPageState();
}

class _PedidoItensLeitorPageState extends State<PedidoItensLeitorPage> {
  late final LeitorController _leitorController;
  Map<int, int> _quantidadesOriginais = {};
  bool _preCarregado = false;
  bool _aplicando = false;

  @override
  void initState() {
    super.initState();
    _leitorController = LeitorController();
  }

  @override
  void dispose() {
    _leitorController.dispose();
    super.dispose();
  }

  void _preCarregarSeNecessario(PedidoState state) {
    if (_preCarregado) return;
    _preCarregado = true;

    final agrupado = <int, int>{};
    for (final item in state.itens) {
      final produtoId = item.produtoId;
      if (produtoId == null) continue;
      agrupado[produtoId] =
          (agrupado[produtoId] ?? 0) + (item.solicitado ?? 0).round();
    }
    _quantidadesOriginais = agrupado;

    if (agrupado.isEmpty) return;
    _leitorController.preCarregarProdutos(
      agrupado.entries
          .map((e) => ProdutosPreCarregado(id: e.key, quantidade: e.value))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidoBloc, PedidoState>(
      builder: (context, state) {
        _preCarregarSeNecessario(state);

        return PopScope(
          canPop: !_aplicando,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Produtos do pedido #${state.id ?? '-'}'),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCabecalho(context, state),
                          const SizedBox(height: 12),
                          LeitorWidget(
                            controller: _leitorController,
                            dataSource: sl(),
                            buscaDataSource: sl(),
                            desativado: _aplicando,
                            tabelaDePrecoId:
                                int.tryParse(state.tabelaPrecoId ?? ''),
                            aceitarApenasProdutosComPreco: true,
                            controlarQuantidade: true,
                            campoCodigoHint:
                                'Bipe ou informe o código do produto',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCabecalho(BuildContext context, PedidoState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  Icons.person_outline,
                  'Cliente: ${(state.pedido?.pessoaNome ?? '-').toUpperCase()}',
                ),
                _chip(
                  Icons.receipt_long_outlined,
                  'Pedido #${state.id ?? '-'}',
                ),
                _chip(
                  Icons.badge_outlined,
                  'Funcionário: ${(state.pedido?.funcionarioNome ?? '-').toUpperCase()}',
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                    onPressed: _aplicando
                        ? null
                        : () => _confirmarAlteracoes(context, state),
                    child: _aplicando
                        ? const CircularProgressIndicator.adaptive()
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Salvar Alterações'),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(Icons.save)
                            ],
                          ))
              ],
            )
          ],
        ),
      ),
    );
  }
  // floatingActionButton: FloatingActionButton(
  //   onPressed: _aplicando
  //       ? null
  //       : () => _confirmarAlteracoes(context, state),
  //   child: _aplicando
  //       ? const SizedBox(
  //           width: 18,
  //           height: 18,
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2,
  //           ),
  //         )
  //       : const Icon(Icons.check),
  // ),

  Widget _chip(IconData icon, String label) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }

  // Nome/tamanho/cor pra exibir no saldo de confirmação -- busca primeiro no leitor (cobre
  // adições e itens que ainda estão na leitura), senão cai pro item original do pedido (cobre
  // remoção total, onde o produto já não aparece mais no leitor).
  String _descricaoProduto(int produtoId, PedidoState state) {
    for (final item in _leitorController.itens) {
      if (item.id == produtoId) {
        return _formatarDescricaoProduto(
          item.descricao,
          tamanho: item.tamanho,
          cor: item.cor,
        );
      }
    }

    for (final item in state.itens) {
      if (item.produtoId == produtoId) {
        return _formatarDescricaoProduto(
          item.referenciaNome?.trim().isNotEmpty == true
              ? item.referenciaNome!
              : 'Produto #$produtoId',
          tamanho: item.tamanhoNome ?? '',
          cor: item.corNome ?? '',
        );
      }
    }

    return 'Produto #$produtoId';
  }

  String _formatarDescricaoProduto(
    String nome, {
    required String tamanho,
    required String cor,
  }) {
    final detalhes = [
      if (cor.trim().isNotEmpty) 'Cor: ${cor.trim()}',
      if (tamanho.trim().isNotEmpty) 'Tam: ${tamanho.trim()}',
    ].join('  •  ');

    return detalhes.isEmpty ? nome : '$nome ($detalhes)';
  }

  Future<void> _confirmarAlteracoes(
    BuildContext context,
    PedidoState state,
  ) async {
    final bloc = context.read<PedidoBloc>();

    final atuais = <int, int>{
      for (final item in _leitorController.itens) item.id: item.quantidadeLida,
    };

    final produtoIds = {..._quantidadesOriginais.keys, ...atuais.keys};
    final adicoes = <int, int>{};
    final remocoes = <int, int>{};
    for (final produtoId in produtoIds) {
      final delta =
          (atuais[produtoId] ?? 0) - (_quantidadesOriginais[produtoId] ?? 0);
      if (delta > 0) adicoes[produtoId] = delta;
      if (delta < 0) remocoes[produtoId] = -delta;
    }

    if (adicoes.isEmpty && remocoes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar alterações no pedido'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (adicoes.isNotEmpty) ...[
                    const Text(
                      'Adicionar:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ...adicoes.entries.map(
                      (e) => Text(
                        '${_descricaoProduto(e.key, state)}: +${e.value}',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (remocoes.isNotEmpty) ...[
                    const Text(
                      'Remover:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ...remocoes.entries.map(
                      (e) => Text(
                        '${_descricaoProduto(e.key, state)}: -${e.value}',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    setState(() => _aplicando = true);

    var falhou = false;

    for (final entry in adicoes.entries) {
      bloc.add(
        PedidoItemAdicionou(
          produtoId: entry.key,
          quantidade: entry.value.toDouble(),
        ),
      );
      final resultado = await bloc.stream.firstWhere(
        (s) =>
            s.step == PedidoStep.itemAdicionado || s.step == PedidoStep.falha,
      );
      if (resultado.step == PedidoStep.falha) {
        falhou = true;
        break;
      }
    }

    if (!falhou) {
      for (final entry in remocoes.entries) {
        var restante = entry.value;
        final linhas = state.itens
            .where((i) => i.produtoId == entry.key && (i.solicitado ?? 0) > 0)
            .toList();

        for (final linha in linhas) {
          if (restante <= 0) break;
          if (linha.sequencia == null) continue;

          final disponivel = (linha.solicitado ?? 0).round();
          final remover = restante < disponivel ? restante : disponivel;
          if (remover <= 0) continue;

          bloc.add(
            PedidoItemRemoveu(
              produtoId: entry.key,
              sequencia: linha.sequencia!,
              quantidade: remover.toDouble(),
            ),
          );
          final resultado = await bloc.stream.firstWhere(
            (s) =>
                s.step == PedidoStep.itemRemovido || s.step == PedidoStep.falha,
          );
          if (resultado.step == PedidoStep.falha) {
            falhou = true;
            break;
          }
          restante -= remover;
        }
        if (falhou) break;
      }
    }

    if (!mounted) return;
    setState(() => _aplicando = false);

    if (falhou) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bloc.state.erro ?? 'Falha ao aplicar alterações no pedido.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }
}
