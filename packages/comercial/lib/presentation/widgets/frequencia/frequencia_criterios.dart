import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _n(double v) => frequenciaDec(v, v == v.roundToDouble() ? 0 : 1);

/// Painel de critérios (desktop). Valores vêm de [resumo.parametros].
class FrequenciaCriterios extends StatelessWidget {
  final FrequenciaClientesResumo resumo;
  const FrequenciaCriterios({super.key, required this.resumo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final p = resumo.parametros;
    final itens = <(String, String)>[
      ('A', 'Clientes que, somados do maior para o menor, chegam a ${_n(p.corteA)}% do faturamento'),
      ('B', 'Os próximos clientes, até ${_n(p.corteB)}% do faturamento acumulado'),
      ('C', 'Os demais, que somam os últimos ${_n(100 - p.corteB)}% do faturamento'),
      ('Visita', 'Cada dia com compra conta 1 visita, mesmo com mais de um cupom no dia'),
      ('Compra a cada', '(última compra − primeira compra) ÷ (visitas − 1)'),
      (
        'Atrasado',
        '${p.minimoVisitasAtraso}+ visitas e sem comprar há mais de ${_n(p.fatorAtraso)}× o intervalo habitual',
      ),
    ];
    final corpo = t.corpo.copyWith(fontSize: 13, height: 1.45, color: c.tinta.withValues(alpha: 0.8));
    final negrito = corpo.copyWith(fontWeight: FontWeight.w600, color: c.tinta);

    Widget linha((String, String) i, int idx) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        idx < 3
            ? FrequenciaTag(['A', 'B', 'C'][idx], texto: 'Classe ${i.$1}')
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.superficieRecuada,
                  border: Border.all(color: c.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Text(i.$1, style: t.apoio.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600)),
              ),
        const SizedBox(width: 10),
        Expanded(child: Text(i.$2, style: corpo)),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border.all(color: c.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var l = 0; l < 2; l++) ...[
            if (l > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var k = 0; k < 3; k++) ...[
                  if (k > 0) const SizedBox(width: 32),
                  Expanded(child: linha(itens[l * 3 + k], l * 3 + k)),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: c.hairline),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: corpo.copyWith(fontSize: 13, color: c.tinta.withValues(alpha: 0.7)),
              children: [
                TextSpan(text: 'Valor acumulado:', style: negrito),
                const TextSpan(
                  text: ' vendas líquidas do cliente no período (vendas menos devoluções, canceladas fora). ',
                ),
                TextSpan(text: 'Fora do relatório:', style: negrito),
                TextSpan(
                  text: ' vendas sem cliente identificado '
                      '(${frequenciaMoeda(resumo.vendasSemCliente.valor)}, '
                      '${frequenciaPct(resumo.vendasSemCliente.percentualFaturamento)} do faturamento).',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
