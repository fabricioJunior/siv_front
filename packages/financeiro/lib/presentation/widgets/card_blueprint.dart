import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Card branco com marcas de canto (padrão "blueprint" do redesign SIV),
/// reusado no painel, calendário e cadastros de despesas.
class CardBlueprint extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CardBlueprint({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          padding: padding,
          child: child,
        ),
        _Corner(alignment: Alignment.topLeft, cor: cores.aco),
        _Corner(alignment: Alignment.topRight, cor: cores.aco),
        _Corner(alignment: Alignment.bottomLeft, cor: cores.aco),
        _Corner(alignment: Alignment.bottomRight, cor: cores.aco),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  final Color cor;

  const _Corner({required this.alignment, required this.cor});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Positioned(
      top: isTop ? -1 : null,
      bottom: isTop ? null : -1,
      left: isLeft ? -1 : null,
      right: isLeft ? null : -1,
      child: SizedBox(
        width: 10,
        height: 10,
        child: CustomPaint(painter: _CornerPainter(top: isTop, left: isLeft, cor: cor)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color cor;

  _CornerPainter({required this.top, required this.left, required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..strokeWidth = 1.5;
    final y = top ? 0.0 : size.height;
    final x = left ? 0.0 : size.width;
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
