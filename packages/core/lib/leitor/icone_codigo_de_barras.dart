import 'package:flutter/widgets.dart';

/// Ícone de código de barras (6 traços verticais, um mais curto) usado no
/// campo de bipagem -- desenhado à mão pra bater exato com o traço do mock,
/// em vez de aproximar com um ícone genérico do Material.
class IconeCodigoDeBarras extends StatelessWidget {
  final Color cor;
  final double tamanho;

  const IconeCodigoDeBarras({super.key, required this.cor, this.tamanho = 26});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(painter: _IconeCodigoDeBarrasPainter(cor)),
    );
  }
}

class _IconeCodigoDeBarrasPainter extends CustomPainter {
  _IconeCodigoDeBarrasPainter(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final sx = size.width / 24;
    final sy = size.height / 24;
    final alturasCheias = [0.0, 0.0, 0.0, 0.0, 4.0, 0.0];
    final xs = [3.0, 6.0, 9.5, 13.0, 16.5, 20.0];
    for (var i = 0; i < xs.length; i++) {
      final x = xs[i] * sx;
      final topo = 5.0 * sy;
      final base = (19.0 - alturasCheias[i]) * sy;
      canvas.drawLine(Offset(x, topo), Offset(x, base), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IconeCodigoDeBarrasPainter oldDelegate) =>
      oldDelegate.cor != cor;
}
