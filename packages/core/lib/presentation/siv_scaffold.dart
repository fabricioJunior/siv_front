import 'package:flutter/material.dart';

import '../tema.dart';
import 'siv_menu_lateral.dart';

/// Casca de toda tela autenticada: menu lateral fixo + barra de título +
/// slot de conteúdo.
///
/// Responsivo em 3 modos, decididos pela largura disponível:
/// - >= [SivDimensoes.breakpointMenuRail]: menu completo (236px), inline.
/// - >= [SivDimensoes.breakpointMenuDrawer]: menu colapsado em rail de
///   ícones (72px) com tooltip, inline.
/// - abaixo disso: menu vira [Drawer], acionado por um botão de menu na
///   barra de título.
class SivScaffold extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Widget> acoes;
  final List<SivMenuLateralSecao> secoesMenu;
  final Widget? cabecalhoMenu;
  final Widget? rodapeMenu;
  final Widget corpo;

  const SivScaffold({
    super.key,
    required this.titulo,
    required this.secoesMenu,
    required this.corpo,
    this.subtitulo,
    this.acoes = const [],
    this.cabecalhoMenu,
    this.rodapeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final emDrawer = largura < SivDimensoes.breakpointMenuDrawer;
        final emRail =
            !emDrawer && largura < SivDimensoes.breakpointMenuRail;

        final menu = SivMenuLateral(
          secoes: secoesMenu,
          cabecalho: cabecalhoMenu,
          rodape: rodapeMenu,
          colapsado: emRail,
        );

        return Scaffold(
          drawer: emDrawer ? Drawer(width: 280, child: SafeArea(child: menu)) : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!emDrawer) menu,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: SivDimensoes.alturaBarraTitulo,
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            SivDimensoes.paddingBarraTituloHorizontal,
                      ),
                      decoration: BoxDecoration(
                        color: cores.superficie,
                        border: Border(bottom: BorderSide(color: cores.hairline)),
                      ),
                      child: Row(
                        children: [
                          if (emDrawer)
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ),
                            ),
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
      },
    );
  }
}
