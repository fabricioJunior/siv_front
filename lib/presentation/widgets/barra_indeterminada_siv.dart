import 'package:flutter/material.dart';

/// Barra de progresso fina e indeterminada: um segmento de 40% atravessa a trilha
/// da esquerda para a direita, em laço. Com animações desligadas (acessibilidade)
/// o segmento fica parado no centro.
class BarraIndeterminadaSiv extends StatefulWidget {
  final double altura;
  final Color cor;
  final Color trilha;

  const BarraIndeterminadaSiv({
    super.key,
    this.altura = 2,
    required this.cor,
    required this.trilha,
  });

  @override
  State<BarraIndeterminadaSiv> createState() => _BarraIndeterminadaSivState();
}

class _BarraIndeterminadaSivState extends State<BarraIndeterminadaSiv>
    with SingleTickerProviderStateMixin {
  static const _largura = 0.4;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _curva = CurvedAnimation(
    parent: _controller,
    curve: const Cubic(0.45, 0, 0.2, 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parado = MediaQuery.disableAnimationsOf(context);
    return ClipRect(
      child: Container(
        height: widget.altura,
        color: widget.trilha,
        child: AnimatedBuilder(
          animation: _curva,
          builder: (context, filho) {
            // Em múltiplos da largura do segmento: -1 (fora, à esquerda) até
            // 2,5 (fora, à direita). Parado: centrado ((1 - 0,4) / 2 / 0,4 = 0,75).
            final dx = parado ? 0.75 : -1 + 3.5 * _curva.value;
            return FractionallySizedBox(
              widthFactor: _largura,
              alignment: Alignment.centerLeft,
              child: FractionalTranslation(
                translation: Offset(dx, 0),
                child: filho,
              ),
            );
          },
          child: ColoredBox(color: widget.cor),
        ),
      ),
    );
  }
}
