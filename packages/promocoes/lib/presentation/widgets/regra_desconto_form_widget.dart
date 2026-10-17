import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

import 'form_promocional_layout.dart';

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
  final bool ocultarCamposDeValor;
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
    this.ocultarCamposDeValor = false,
    required this.onTipoDescontoChanged,
    required this.onValorPercentualChanged,
    required this.onValorDescontoMaximoChanged,
    required this.onValorFixoChanged,
    required this.onValorMinimoCompraChanged,
    required this.onQuantidadeMinimaChanged,
    required this.onPrecoFixoChanged,
  });

  Widget _campo({
    required String chave,
    required String rotulo,
    required Object? valor,
    required ValueChanged<String> onChanged,
    String? sufixo,
    bool inteiro = false,
    String? erro,
  }) {
    return RotuloCampo(
      rotulo: rotulo,
      filho: TextFormField(
        key: ValueKey('$chave-$valor'),
        initialValue: valor?.toString() ?? '',
        decoration: InputDecoration(suffixText: sufixo),
        keyboardType: inteiro
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        validator: erro == null
            ? null
            : (v) => double.tryParse(v ?? '') == null ? erro : null,
        onChanged: onChanged,
      ),
    );
  }

  // Duas colunas no desktop, empilhado no mobile.
  Widget _linha(BuildContext context, List<Widget> campos) {
    final duas =
        MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;
    if (!duas) {
      return Column(
        children: [
          for (final c in campos)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: c,
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: i < campos.length ? campos[i] : const SizedBox()),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mostra = !ocultarCamposDeValor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloCampo(
          rotulo: 'Tipo de desconto',
          filho: SegmentoOpcoes<TipoDesconto>(
            opcoes: const {
              TipoDesconto.percentual: 'Percentual',
              TipoDesconto.valorFixo: 'Valor fixo',
              TipoDesconto.precoFixo: 'Preço fixo',
            },
            selecionado: tipoDesconto,
            onChanged: onTipoDescontoChanged,
          ),
        ),
        if (mostra && tipoDesconto == TipoDesconto.percentual)
          _linha(context, [
            _campo(
              chave: 'valorPercentual',
              rotulo: 'Valor do desconto',
              valor: valorPercentual,
              sufixo: '%',
              erro: 'Informe um percentual válido',
              onChanged: (v) => onValorPercentualChanged(double.tryParse(v)),
            ),
            _campo(
              chave: 'valorDescontoMaximo',
              rotulo: 'Teto de desconto (opcional)',
              valor: valorDescontoMaximo,
              sufixo: 'R\$',
              onChanged: (v) =>
                  onValorDescontoMaximoChanged(double.tryParse(v)),
            ),
          ]),
        if (mostra && tipoDesconto == TipoDesconto.valorFixo) ...[
          _linha(context, [
            _campo(
              chave: 'valorFixo',
              rotulo: 'Valor do desconto',
              valor: valorFixo,
              sufixo: 'R\$',
              erro: 'Informe um valor válido',
              onChanged: (v) => onValorFixoChanged(double.tryParse(v)),
            ),
            _campo(
              chave: 'valorMinimoCompra',
              rotulo: 'Pedido mínimo (opcional)',
              valor: valorMinimoCompra,
              sufixo: 'R\$',
              onChanged: (v) => onValorMinimoCompraChanged(double.tryParse(v)),
            ),
          ]),
          _linha(context, [
            _campo(
              chave: 'quantidadeMinima',
              rotulo: 'Quantidade mínima (opcional)',
              valor: quantidadeMinima,
              inteiro: true,
              onChanged: (v) => onQuantidadeMinimaChanged(int.tryParse(v)),
            ),
          ]),
        ],
        if (mostra && tipoDesconto == TipoDesconto.precoFixo)
          _linha(context, [
            _campo(
              chave: 'precoFixo',
              rotulo: 'Preço fixo',
              valor: precoFixo,
              sufixo: 'R\$',
              erro: 'Informe um preço válido',
              onChanged: (v) => onPrecoFixoChanged(double.tryParse(v)),
            ),
          ]),
      ],
    );
  }
}
