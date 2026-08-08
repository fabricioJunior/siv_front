import 'package:flutter/material.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Reaproveitado no form de promocao e no form de cupom -- os dois tem o
// mesmo shape de regra de desconto (tipoDesconto + campos condicionais).
class RegraDescontoFormWidget extends StatelessWidget {
  final TipoDesconto tipoDesconto;
  final double? valorPercentual;
  final double? valorDescontoMaximo;
  final double? valorFixo;
  final double? valorMinimoCompra;
  final int? quantidadeMinima;
  final double? precoFixo;
  final ValueChanged<TipoDesconto> onTipoDescontoChanged;
  final ValueChanged<double?> onValorPercentualChanged;
  final ValueChanged<double?> onValorDescontoMaximoChanged;
  final ValueChanged<double?> onValorFixoChanged;
  final ValueChanged<double?> onValorMinimoCompraChanged;
  final ValueChanged<int?> onQuantidadeMinimaChanged;
  final ValueChanged<double?> onPrecoFixoChanged;

  const RegraDescontoFormWidget({
    super.key,
    required this.tipoDesconto,
    this.valorPercentual,
    this.valorDescontoMaximo,
    this.valorFixo,
    this.valorMinimoCompra,
    this.quantidadeMinima,
    this.precoFixo,
    required this.onTipoDescontoChanged,
    required this.onValorPercentualChanged,
    required this.onValorDescontoMaximoChanged,
    required this.onValorFixoChanged,
    required this.onValorMinimoCompraChanged,
    required this.onQuantidadeMinimaChanged,
    required this.onPrecoFixoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de desconto', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<TipoDesconto>(
          segments: const [
            ButtonSegment(
              value: TipoDesconto.percentual,
              label: Text('Percentual'),
            ),
            ButtonSegment(
              value: TipoDesconto.valorFixo,
              label: Text('Valor fixo'),
            ),
            ButtonSegment(
              value: TipoDesconto.precoFixo,
              label: Text('Preço fixo'),
            ),
          ],
          selected: {tipoDesconto},
          onSelectionChanged: (selecionados) =>
              onTipoDescontoChanged(selecionados.first),
        ),
        const SizedBox(height: 12),
        if (tipoDesconto == TipoDesconto.percentual) ...[
          TextFormField(
            key: ValueKey('valorPercentual-$valorPercentual'),
            initialValue: valorPercentual?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Percentual de desconto (%)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (double.tryParse(value ?? '') == null) {
                return 'Informe um percentual válido';
              }
              return null;
            },
            onChanged: (value) =>
                onValorPercentualChanged(double.tryParse(value)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('valorDescontoMaximo-$valorDescontoMaximo'),
            initialValue: valorDescontoMaximo?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Teto de desconto (R\$) - opcional',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) =>
                onValorDescontoMaximoChanged(double.tryParse(value)),
          ),
        ],
        if (tipoDesconto == TipoDesconto.valorFixo) ...[
          TextFormField(
            key: ValueKey('valorFixo-$valorFixo'),
            initialValue: valorFixo?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Valor fixo de desconto (R\$)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (double.tryParse(value ?? '') == null) {
                return 'Informe um valor válido';
              }
              return null;
            },
            onChanged: (value) => onValorFixoChanged(double.tryParse(value)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('valorMinimoCompra-$valorMinimoCompra'),
            initialValue: valorMinimoCompra?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Valor mínimo de compra (R\$) - opcional',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) =>
                onValorMinimoCompraChanged(double.tryParse(value)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('quantidadeMinima-$quantidadeMinima'),
            initialValue: quantidadeMinima?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Quantidade mínima - opcional',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                onQuantidadeMinimaChanged(int.tryParse(value)),
          ),
        ],
        if (tipoDesconto == TipoDesconto.precoFixo)
          TextFormField(
            key: ValueKey('precoFixo-$precoFixo'),
            initialValue: precoFixo?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Preço fixo (R\$)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (double.tryParse(value ?? '') == null) {
                return 'Informe um preço válido';
              }
              return null;
            },
            onChanged: (value) => onPrecoFixoChanged(double.tryParse(value)),
          ),
      ],
    );
  }
}
