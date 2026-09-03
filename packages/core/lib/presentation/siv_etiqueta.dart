import 'package:flutter/material.dart';

import '../tema.dart';

/// Situações de pedido reconhecidas pelo [SivEtiqueta].
enum SivEtiquetaSituacao {
  emAndamento,
  conferido,
  faturado,
  encerrado,
  cancelado,
  pago,
}

/// Etiqueta de situação de pedido. Cada [SivEtiquetaSituacao] tem uma
/// aparência fixa definida pelo design system -- não é configurável por
/// cor solta.
class SivEtiqueta extends StatelessWidget {
  final SivEtiquetaSituacao situacao;
  final String texto;

  const SivEtiqueta({super.key, required this.situacao, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final estilo = context.sivTextos.rotulo;

    Color? fundo;
    Color borda;
    Color textoCor;
    double opacidade = 1;

    switch (situacao) {
      case SivEtiquetaSituacao.emAndamento:
        fundo = const Color(0xFFD6EBFF);
        borda = cores.aco;
        textoCor = cores.acoEscuro;
        break;
      case SivEtiquetaSituacao.conferido:
      case SivEtiquetaSituacao.faturado:
      case SivEtiquetaSituacao.encerrado:
        fundo = null;
        borda = cores.hairline;
        textoCor = cores.textoPrincipal;
        break;
      case SivEtiquetaSituacao.cancelado:
        fundo = null;
        borda = cores.hairline;
        textoCor = cores.textoPrincipal;
        opacidade = 0.55;
        break;
      case SivEtiquetaSituacao.pago:
        fundo = cores.acoEscuro;
        borda = cores.acoEscuro;
        textoCor = cores.textoSobreEscuroTitulo;
        break;
    }

    return Opacity(
      opacity: opacidade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: fundo,
          border: Border.all(color: borda),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Text(texto, style: estilo.copyWith(color: textoCor)),
      ),
    );
  }
}
