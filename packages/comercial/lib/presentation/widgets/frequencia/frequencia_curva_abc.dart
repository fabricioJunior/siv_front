import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _enxuto(double v) => frequenciaPct(v, v == v.roundToDouble() ? 0 : 1);

/// Gráfico 1 (desktop): curva ABC de clientes (% clientes x % faturamento).
class FrequenciaCurvaAbc extends StatelessWidget {
  final FrequenciaClientesResumo resumo;
  const FrequenciaCurvaAbc({super.key, required this.resumo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final p = resumo.parametros;
    FrequenciaClasseResumo cl(String k) => resumo.classes.firstWhere(
      (e) => e.classe == k,
      orElse: () => FrequenciaClasseResumo(classe: k),
    );
    final a = cl('A');
    final b = cl('B');
    final cc = cl('C');
    final xA = a.percentualClientes;
    final xB = a.percentualClientes + b.percentualClientes;
    const altura = 190.0;
    final apoio = t.apoio.copyWith(fontSize: 10.5, color: c.textoApoio);

    Widget rotuloY(double pct) => Positioned(
      right: 0,
      top: altura * (1 - pct / 100) - 6,
      child: Text(_enxuto(pct), style: apoio),
    );

    final somaFlex = a.percentualClientes + b.percentualClientes + cc.percentualClientes;
    int flex(FrequenciaClasseResumo e) =>
        somaFlex <= 0 ? 1 : (e.percentualClientes * 100).round().clamp(1, 1000000);

    Widget coluna(FrequenciaClasseResumo e, {required bool borda}) => Expanded(
      flex: flex(e),
      child: Container(
        padding: EdgeInsets.fromLTRB(borda ? 8 : 0, 6, 8, 0),
        decoration: borda
            ? BoxDecoration(border: Border(left: BorderSide(color: c.hairline)))
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${e.classe} · ${frequenciaPct(e.percentualClientes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.secao.copyWith(fontSize: 15, color: frequenciaCorTexto(c, e.classe)),
            ),
            Text(
              '${frequenciaInt(e.clientes)} clientes · ${_enxuto(e.percentualFaturamento)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: apoio.copyWith(fontSize: 11.5),
            ),
          ],
        ),
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
                Text('Curva ABC', style: t.secao.copyWith(fontSize: 18)),
                Flexible(
                  child: Text(
                    '% acumulado do faturamento × % de clientes',
                    overflow: TextOverflow.ellipsis,
                    style: apoio.copyWith(fontSize: 11.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  height: altura,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      rotuloY(100),
                      rotuloY(p.corteB),
                      rotuloY(p.corteA),
                      rotuloY(0),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: altura,
                    child: CustomPaint(
                      painter: _CurvaPainter(
                        pontos: resumo.curva,
                        xA: xA,
                        xB: xB,
                        corteA: p.corteA,
                        corteB: p.corteB,
                        escuro: c.acoEscuro,
                        medio: c.aco,
                        guia: c.tinta.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      coluna(a, borda: false),
                      coluna(b, borda: true),
                      coluna(cc, borda: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvaPainter extends CustomPainter {
  final List<FrequenciaCurvaPonto> pontos;
  final double xA, xB, corteA, corteB;
  final Color escuro, medio, guia;

  _CurvaPainter({
    required this.pontos,
    required this.xA,
    required this.xB,
    required this.corteA,
    required this.corteB,
    required this.escuro,
    required this.medio,
    required this.guia,
  });

  @override
  void paint(Canvas canvas, Size s) {
    double px(double pct) => s.width * pct / 100;
    double py(double pct) => s.height * (1 - pct / 100);
    final fill = Paint();
    canvas.drawRect(
      Rect.fromLTRB(0, 0, px(xA), s.height),
      fill..color = escuro.withValues(alpha: 0.07),
    );
    canvas.drawRect(
      Rect.fromLTRB(px(xA), 0, px(xB), s.height),
      fill..color = medio.withValues(alpha: 0.07),
    );
    final linha = Paint()
      ..color = guia
      ..strokeWidth = 1;
    for (final x in [xA, xB]) {
      canvas.drawLine(Offset(px(x), 0), Offset(px(x), s.height), linha);
    }
    for (final y in [corteA, corteB]) {
      for (var x = 0.0; x < s.width; x += 7) {
        canvas.drawLine(Offset(x, py(y)), Offset((x + 3).clamp(0, s.width), py(y)), linha);
      }
    }
    canvas.drawLine(Offset(0, s.height), Offset(s.width, s.height), linha);
    if (pontos.length > 1) {
      final path = Path()..moveTo(px(pontos.first.percentualClientes), py(pontos.first.percentualFaturamento));
      for (final p in pontos.skip(1)) {
        path.lineTo(px(p.percentualClientes), py(p.percentualFaturamento));
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = escuro
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.drawCircle(Offset(px(xA), py(corteA)), 3.5, Paint()..color = escuro);
    canvas.drawCircle(Offset(px(xB), py(corteB)), 3.5, Paint()..color = medio);
  }

  @override
  bool shouldRepaint(_CurvaPainter o) =>
      o.pontos != pontos ||
      o.xA != xA ||
      o.xB != xB ||
      o.corteA != corteA ||
      o.corteB != corteB ||
      o.escuro != escuro;
}
