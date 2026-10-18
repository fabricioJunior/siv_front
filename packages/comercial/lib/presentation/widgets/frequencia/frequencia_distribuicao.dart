import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _rotuloFaixa(String f) => f == '1' ? '1 visita' : f.replaceAll('-', '–');

/// Gráfico 2 (desktop): quantas vezes os clientes vieram, empilhado por classe.
class FrequenciaDistribuicao extends StatelessWidget {
  final FrequenciaClientesResumo resumo;
  const FrequenciaDistribuicao({super.key, required this.resumo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final faixas = resumo.distribuicaoVisitas;
    final maior = faixas.fold<int>(0, (m, f) => (f.a + f.b + f.c) > m ? f.a + f.b + f.c : m);
    final apoio = t.apoio.copyWith(fontSize: 11.5, color: c.textoApoio);

    Widget seg(int v, Color cor) =>
        v > 0 ? Expanded(flex: v, child: Container(color: cor)) : const SizedBox.shrink();

    Widget linha(FrequenciaFaixaVisitas f) {
      final total = f.a + f.b + f.c;
      return Row(
        children: [
          SizedBox(width: 70, child: Text(_rotuloFaixa(f.faixa), style: t.corpo.copyWith(fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              color: c.hairline.withValues(alpha: 0.04),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: maior == 0 ? 0 : total / maior,
                child: Row(
                  children: [
                    seg(f.a, c.acoEscuro),
                    seg(f.b, c.aco),
                    seg(f.c, c.classeCBarra),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            child: Text(
              frequenciaInt(total),
              textAlign: TextAlign.right,
              style: t.corpo.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    Widget legenda(String k, Color cor) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(width: 9, height: 9, color: cor),
          const SizedBox(width: 6),
          Text(k, style: apoio),
        ],
      ),
    );

    return SivMolduraBlueprint(
      padding: 0,
      fundo: c.superficie,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Quantas vezes vieram', style: t.secao.copyWith(fontSize: 18)),
                Flexible(
                  child: Text('Clientes por nº de visitas', overflow: TextOverflow.ellipsis, style: apoio),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < faixas.length; i++) ...[
              if (i > 0) const SizedBox(height: 11),
              linha(faixas[i]),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, color: c.hairline),
            const SizedBox(height: 12),
            Row(
              children: [
                legenda('A', c.acoEscuro),
                legenda('B', c.aco),
                legenda('C', c.classeCBarra),
                const Spacer(),
                Text(
                  '${frequenciaPct(resumo.percentualUmaVisita, resumo.percentualUmaVisita == resumo.percentualUmaVisita.roundToDouble() ? 0 : 1)} compraram uma vez só',
                  style: apoio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
