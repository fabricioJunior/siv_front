import 'package:flutter/material.dart';

import '../tema.dart';

enum SivAvisoTipo { sucesso, atencao, falha }

/// Faixa de rodapé com aviso, some sozinha após 4s. Use
/// [SivAviso.mostrar] para exibir sobre um [Scaffold] via [SnackBar].
class SivAviso {
  static void mostrar(
    BuildContext context, {
    required String mensagem,
    SivAvisoTipo tipo = SivAvisoTipo.sucesso,
  }) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    late Color fundo;
    late Color borda;
    late Color textoCor;

    switch (tipo) {
      case SivAvisoTipo.sucesso:
        fundo = cores.acoEscuro;
        borda = cores.acoEscuro;
        textoCor = cores.textoSobreEscuroTitulo;
        break;
      case SivAvisoTipo.atencao:
        fundo = const Color(0xFFF5EFE0);
        borda = const Color(0xFFCBB27A);
        textoCor = cores.textoPrincipal;
        break;
      case SivAvisoTipo.falha:
        fundo = const Color(0xFFF6E9E9);
        borda = const Color(0xFFC99B9B);
        textoCor = cores.textoPrincipal;
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: fundo,
        elevation: 0,
        shape: Border(top: BorderSide(color: borda, width: 1)),
        content: Text(mensagem, style: textos.corpo.copyWith(color: textoCor)),
      ),
    );
  }
}
