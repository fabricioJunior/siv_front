import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rolagem horizontal com setas ‹ › para quem não rola com o mouse/trackpad.
/// As setas só aparecem quando [larguraConteudo] não cabe na largura disponível.
class RolagemHorizontalComSetas extends StatefulWidget {
  final double larguraConteudo;
  final Widget child;

  const RolagemHorizontalComSetas({
    super.key,
    required this.larguraConteudo,
    required this.child,
  });

  @override
  State<RolagemHorizontalComSetas> createState() => _RolagemHorizontalComSetasState();
}

class _RolagemHorizontalComSetasState extends State<RolagemHorizontalComSetas> {
  static const double _larguraSeta = 36;

  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rolar(int sentido) {
    final p = _controller.position;
    final destino = (p.pixels + sentido * p.viewportDimension * 0.8).clamp(0.0, p.maxScrollExtent);
    _controller.animateTo(destino, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Widget _seta(IconData icone, String dica, int sentido, bool Function(ScrollPosition) habilitada) {
    return SizedBox(
      width: _larguraSeta,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (_, __) {
          final pos = _controller.hasClients && _controller.position.hasContentDimensions ? _controller.position : null;
          // Antes do 1º layout ainda não há posição: só a seta da direita começa habilitada.
          final ativa = pos == null ? sentido > 0 : habilitada(pos);
          return IconButton(
            tooltip: dica,
            icon: Icon(icone),
            padding: EdgeInsets.zero,
            onPressed: ativa ? () => _rolar(sentido) : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        if (widget.larguraConteudo <= c.maxWidth) {
          return SizedBox(width: c.maxWidth, child: widget.child);
        }
        final area = c.maxWidth - 2 * _larguraSeta;
        return Row(
          children: [
            _seta(Icons.chevron_left, 'Rolar para a esquerda', -1, (p) => p.pixels > 0),
            Expanded(
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: math.max(area, widget.larguraConteudo), child: widget.child),
              ),
            ),
            _seta(Icons.chevron_right, 'Rolar para a direita', 1, (p) => p.pixels < p.maxScrollExtent),
          ],
        );
      },
    );
  }
}
