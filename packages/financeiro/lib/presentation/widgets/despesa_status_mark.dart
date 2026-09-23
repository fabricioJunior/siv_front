import 'package:core/tema.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:flutter/material.dart';

/// Marca de 8-10px do estado de uma ocorrência: quadrado cheio (pago),
/// vazado (pendente), vazado tracejado (prevista/virtual) ou traço (cancelado).
/// Nenhuma cor fora do aço -- o estado é a forma, não a cor.
class DespesaStatusMark extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;
  final double tamanho;

  const DespesaStatusMark({super.key, required this.ocorrencia, this.tamanho = 9});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    switch (ocorrencia.status) {
      case StatusDespesa.pago:
        return Container(width: tamanho, height: tamanho, color: cores.acoAtivo);
      case StatusDespesa.cancelado:
        return SizedBox(
          width: tamanho,
          child: Divider(height: tamanho, thickness: 1.5, color: cores.textoApoio),
        );
      case StatusDespesa.pendente:
        return CustomPaint(
          size: Size(tamanho, tamanho),
          painter: _MolduraPainter(cor: cores.aco, tracejada: ocorrencia.virtual),
        );
    }
  }
}

class _MolduraPainter extends CustomPainter {
  final Color cor;
  final bool tracejada;

  _MolduraPainter({required this.cor, required this.tracejada});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5);
    if (!tracejada) {
      canvas.drawRect(rect, paint);
      return;
    }
    const dash = 2.0, gap = 1.5;
    final path = Path()..addRect(rect);
    for (final metric in path.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metric.length) {
        final proximo = (distancia + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distancia, proximo), paint);
        distancia += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MolduraPainter oldDelegate) =>
      oldDelegate.cor != cor || oldDelegate.tracejada != tracejada;
}

/// Tag de contorno usada em "Parcela n/N", "Prevista" (contorno tracejado),
/// "Recorrente" (neutra).
class DespesaTag extends StatelessWidget {
  final String texto;
  final bool tracejada;
  final bool neutra;

  const DespesaTag(this.texto, {super.key, this.tracejada = false, this.neutra = false});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: neutra ? cores.superficieRecuada : null,
        border: neutra
            ? Border.all(color: cores.hairline)
            : (tracejada ? null : Border.all(color: cores.aco)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: tracejada
          ? CustomPaint(
              painter: _BordaTracejadaPainter(cor: cores.aco),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Text(texto, style: textos.apoio.copyWith(fontSize: 10, color: cores.acoAtivo)),
              ),
            )
          : Text(
              texto,
              style: textos.apoio.copyWith(
                fontSize: 10,
                color: neutra ? cores.textoApoio : cores.acoAtivo,
              ),
            ),
    );
  }
}

class _BordaTracejadaPainter extends CustomPainter {
  final Color cor;

  _BordaTracejadaPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(3)));
    const dash = 2.5, gap = 1.5;
    for (final metric in path.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metric.length) {
        final proximo = (distancia + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distancia, proximo), paint);
        distancia += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BordaTracejadaPainter oldDelegate) => oldDelegate.cor != cor;
}
