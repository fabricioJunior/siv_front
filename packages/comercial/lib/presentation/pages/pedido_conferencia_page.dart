import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/pedido_bloc/pedido_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:flutter/material.dart';

// Conferência de pedido de e-commerce em 2 etapas: bipagem livre (etapa 1, cada leitura chama
// direto o endpoint de conferência por código de barras no servidor) e confirmação com destaque de
// divergências (etapa 2, dispara PedidoConferiu -- com processarComDivergencia quando o operador
// confirma seguir mesmo com solicitado != atendido).
class PedidoConferenciaPage extends StatefulWidget {
  const PedidoConferenciaPage({super.key});

  @override
  State<PedidoConferenciaPage> createState() => _PedidoConferenciaPageState();
}

class _PedidoConferenciaPageState extends State<PedidoConferenciaPage> {
  int _etapa = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidoBloc, PedidoState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Conferir pedido #${state.id ?? '-'}'),
          ),
          body: SafeArea(
            child: _etapa == 0
                ? _buildEtapaLeitura(context, state)
                : _buildEtapaConfirmacao(context, state),
          ),
        );
      },
    );
  }

  Widget _buildEtapaLeitura(BuildContext context, PedidoState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bipe os produtos do pedido para conferir a quantidade atendida.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          LeitorWidget(
            dataSource: sl(),
            buscaDataSource: sl(),
            campoCodigoHint: 'Bipe o código de barras do produto',
            onUltimoProdutoLido: (item) {
              context.read<PedidoBloc>().add(
                    PedidoItemConferiuPorCodigo(
                      codigoBarras: item.codigoDeBarras,
                      quantidade: 1,
                    ),
                  );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: state.itens.map((item) => _linhaItem(item)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _etapa = 1),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _linhaItem(PedidoItem item) {
    final solicitado = item.solicitado ?? 0;
    final atendido = item.atendido ?? 0;
    final divergente = atendido != solicitado;

    return ListTile(
      dense: true,
      leading: Icon(
        divergente ? Icons.warning_amber_outlined : Icons.check_circle_outline,
        color: divergente ? Colors.orange : Colors.green,
      ),
      title: Text(
        item.referenciaNome?.trim().isNotEmpty == true
            ? item.referenciaNome!
            : 'Produto #${item.produtoId ?? '-'}',
      ),
      subtitle: Text(
        [
          if ((item.corNome ?? '').isNotEmpty) 'Cor: ${item.corNome}',
          if ((item.tamanhoNome ?? '').isNotEmpty)
            'Tamanho: ${item.tamanhoNome}',
        ].join('  •  '),
      ),
      trailing: Text('${atendido.toStringAsFixed(0)}/${solicitado.toStringAsFixed(0)}'),
    );
  }

  Widget _buildEtapaConfirmacao(BuildContext context, PedidoState state) {
    final divergencias = state.itens
        .where((item) => (item.atendido ?? 0) != (item.solicitado ?? 0))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confira solicitado x atendido antes de confirmar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Produto')),
                    DataColumn(label: Text('Solicitado')),
                    DataColumn(label: Text('Atendido')),
                  ],
                  rows: state.itens.map((item) {
                    final solicitado = item.solicitado ?? 0;
                    final atendido = item.atendido ?? 0;
                    final divergente = atendido != solicitado;
                    return DataRow(
                      color: divergente
                          ? WidgetStateProperty.all(
                              Colors.orange.withValues(alpha: 0.1),
                            )
                          : null,
                      cells: [
                        DataCell(Text(
                          item.referenciaNome?.trim().isNotEmpty == true
                              ? item.referenciaNome!
                              : 'Produto #${item.produtoId ?? '-'}',
                        )),
                        DataCell(Text(solicitado.toStringAsFixed(0))),
                        DataCell(Text(atendido.toStringAsFixed(0))),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _etapa = 0),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _confirmarConferencia(context, divergencias),
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar conferência'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarConferencia(
    BuildContext context,
    List<PedidoItem> divergencias,
  ) async {
    final bloc = context.read<PedidoBloc>();
    var processarComDivergencia = false;

    if (divergencias.isNotEmpty) {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Divergência na conferência'),
            content: Text(
              'Há ${divergencias.length} item(ns) com quantidade solicitada '
              'diferente da atendida. Deseja processar o pedido mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Processar com divergência'),
              ),
            ],
          );
        },
      );

      if (confirmou != true) return;
      processarComDivergencia = true;
    }

    bloc.add(PedidoConferiu(processarComDivergencia: processarComDivergencia));
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
