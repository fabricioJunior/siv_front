import 'package:comercial/presentation.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Lateral do pedido (330 px no desktop): totais + seções de dados.
class LateralPedido extends StatelessWidget {
  final PedidoState state;
  final String pagamentoLabel;

  /// Itens, desconto, endereço e taxa travados (pagamento confirmado/online gerado).
  final bool travado;
  final List<Widget> secoes;

  const LateralPedido({
    super.key,
    required this.state,
    required this.pagamentoLabel,
    required this.travado,
    required this.secoes,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    Widget linha(String r, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(r, style: textos.apoio), Text(v, style: textos.corpo)],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              linha('Itens', '${state.itens.length}'),
              linha('Pagamento', pagamentoLabel),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL', style: textos.rotulo),
                  Text(
                    'R\$ ${state.valorTotalGeral.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: textos.valor,
                  ),
                ],
              ),
              if (travado) ...[
                const SizedBox(height: 8),
                Text(
                  'Itens e endereço travam enquanto houver pagamento online gerado.',
                  style: textos.apoio,
                ),
              ],
            ],
          ),
        ),
        for (final s in secoes) ...[const SizedBox(height: 12), s],
      ],
    );
  }
}
