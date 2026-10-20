import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/domain/models/promocao.dart';

import 'form_promocional_layout.dart';

/// Chips Loja / E-commerce sobre [PromocaoCanal]; os dois marcados = ambos.
/// O ultimo chip marcado nao pode ser desmarcado.
class CanaisChips extends StatelessWidget {
  final PromocaoCanal canal;
  final ValueChanged<PromocaoCanal> onChanged;

  const CanaisChips({super.key, required this.canal, required this.onChanged});

  void _alternar({required bool loja}) {
    final novaLoja = loja
        ? canal == PromocaoCanal.ecommerce
        : canal != PromocaoCanal.ecommerce;
    final novaEco =
        loja ? canal != PromocaoCanal.loja : canal == PromocaoCanal.loja;
    if (!novaLoja && !novaEco) return;
    onChanged(
      novaLoja && novaEco
          ? PromocaoCanal.ambos
          : novaLoja
              ? PromocaoCanal.loja
              : PromocaoCanal.ecommerce,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selecao = context.sivColors.selecaoFundo;
    return RotuloCampo(
      rotulo: 'Canais',
      filho: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('Loja'),
            selected: canal != PromocaoCanal.ecommerce,
            selectedColor: selecao,
            onSelected: (_) => _alternar(loja: true),
          ),
          FilterChip(
            label: const Text('E-commerce'),
            selected: canal != PromocaoCanal.loja,
            selectedColor: selecao,
            onSelected: (_) => _alternar(loja: false),
          ),
        ],
      ),
    );
  }
}
