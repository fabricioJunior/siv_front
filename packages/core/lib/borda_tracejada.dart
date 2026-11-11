import 'package:flutter/material.dart';

/// Moldura de borda tracejada (Flutter não tem `BorderStyle.dashed`).
class BordaTracejada extends StatelessWidget {
  final Widget child;
  final Color cor;
  final Color? fundo;
  final double raio;
  final double espessura;
  final double traco;
  final double vao;

  const BordaTracejada({
    super.key,
    required this.child,
    required this.cor,
    this.fundo,
    this.raio = 4,
    this.espessura = 1,
    this.traco = 4,
    this.vao = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BordaTracejadaPainter(
        cor: cor,
        fundo: fundo,
        raio: raio,
        espessura: espessura,
        traco: traco,
        vao: vao,
      ),
      child: child,
    );
  }
}

class _BordaTracejadaPainter extends CustomPainter {
  final Color cor;
  final Color? fundo;
  final double raio;
  final double espessura;
  final double traco;
  final double vao;

  _BordaTracejadaPainter({
    required this.cor,
    required this.fundo,
    required this.raio,
    required this.espessura,
    required this.traco,
    required this.vao,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final retangulo = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(raio),
    ).deflate(espessura / 2);
    if (fundo != null) {
      canvas.drawRRect(retangulo, Paint()..color = fundo!);
    }
    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura;
    final caminho = Path()..addRRect(retangulo);
    for (final metrica in caminho.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metrica.length) {
        final fim = (distancia + traco).clamp(0, metrica.length).toDouble();
        canvas.drawPath(metrica.extractPath(distancia, fim), pincel);
        distancia += traco + vao;
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejadaPainter antigo) =>
      cor != antigo.cor ||
      fundo != antigo.fundo ||
      raio != antigo.raio ||
      espessura != antigo.espessura ||
      traco != antigo.traco ||
      vao != antigo.vao;
}
