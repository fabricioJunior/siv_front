import 'package:flutter/material.dart';

import '../tema.dart';
import 'siv_menu_lateral.dart';

/// Casca de toda tela autenticada: menu lateral fixo + barra de título +
/// slot de conteúdo.
class SivScaffold extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Widget> acoes;
  final List<SivMenuLateralItem> itensMenu;
  final Widget? cabecalhoMenu;
  final Widget corpo;

  const SivScaffold({
    super.key,
    required this.titulo,
    required this.itensMenu,
    required this.corpo,
    this.subtitulo,
    this.acoes = const [],
    this.cabecalhoMenu,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SivMenuLateral(itens: itensMenu, cabecalho: cabecalhoMenu),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: SivDimensoes.alturaBarraTitulo,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SivDimensoes.paddingBarraTituloHorizontal,
                  ),
                  decoration: BoxDecoration(
                    color: cores.superficie,
                    border: Border(
                      bottom: BorderSide(color: cores.hairline),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(titulo, style: textos.secao),
                            if (subtitulo != null)
                              Text(
                                subtitulo!,
                                style: textos.apoio.copyWith(
                                  color: cores.textoApoio,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (acoes.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < acoes.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              acoes[i],
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SivDimensoes.paginaHorizontal,
                      vertical: SivDimensoes.paginaVertical,
                    ),
                    child: corpo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
