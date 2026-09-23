import 'package:flutter/material.dart';

import '../tema.dart';

/// Título (e subtítulo opcional) de página, renderizado pela própria tela no
/// topo do seu corpo -- reproduz o estilo usado antes na barra de título
/// compartilhada do [SivScaffold].
class SivTituloPagina extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  const SivTituloPagina({super.key, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Padding(
      padding: const EdgeInsets.only(bottom: SivDimensoes.gapCards),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: textos.secao,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitulo != null)
            Text(
              subtitulo!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
        ],
      ),
    );
  }
}
