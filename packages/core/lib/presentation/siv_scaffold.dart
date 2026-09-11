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
  final List<SivMenuLateralSecao> secoesMenu;
  final Widget? cabecalhoMenu;
  final Widget? rodapeMenu;
  final Widget corpo;
  final Widget? floatingActionButton;

  const SivScaffold({
    super.key,
    required this.titulo,
    required this.secoesMenu,
    required this.corpo,
    this.subtitulo,
    this.cabecalhoMenu,
    this.rodapeMenu,
    this.floatingActionButton,
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
          floatingActionButton: floatingActionButton,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!emDrawer) menu,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: SivDimensoes.alturaBarraTitulo,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: emDrawer
                            ? 16
                            : SivDimensoes.paddingBarraTituloHorizontal,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cores.superficie,
                        border: Border(bottom: BorderSide(color: cores.hairline)),
                      ),
                      // Barra de título só mostra título/subtítulo -- botões
                      // de ação são responsabilidade de cada tela, renderizados
                      // no topo do próprio corpo.
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
                            child: _SivScaffoldTitulo(
                              titulo: titulo,
                              subtitulo: subtitulo,
                              textos: textos,
                              cores: cores,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        // Padding fixo (28/30, pensado pra desktop) comia
                        // proporcionalmente demais numa tela de ~390px --
                        // conteúdo ficava espremido mesmo sobrando espaço
                        // real. Mobile (emDrawer) encosta nos 4 lados (0);
                        // cada tela decide seu próprio respiro interno se
                        // precisar.
                        padding: EdgeInsets.symmetric(
                          horizontal: emDrawer ? 0 : SivDimensoes.paginaHorizontal,
                          vertical: emDrawer ? 0 : SivDimensoes.paginaVertical,
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

class _SivScaffoldTitulo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final SivTextStyles textos;
  final SivColors cores;

  const _SivScaffoldTitulo({
    required this.titulo,
    required this.subtitulo,
    required this.textos,
    required this.cores,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
