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
  final Widget? floatingActionButton;

  const SivScaffold({
    super.key,
    required this.titulo,
    required this.secoesMenu,
    required this.corpo,
    this.subtitulo,
    this.acoes = const [],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            SivDimensoes.paddingBarraTituloHorizontal,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cores.superficie,
                        border: Border(bottom: BorderSide(color: cores.hairline)),
                      ),
                      // Título e ações NUNCA disputam a mesma linha -- com
                      // breadcrumb longo (ex: "E-commerces / Canal / Produtos
                      // no site") + 3 botões, dividir a largura entre os dois
                      // (mesmo com Wrap nas ações) só sobrava espaço real em
                      // telas bem largas; em telas intermediárias apertava a
                      // ponto de sumir/estourar. Empilhado sempre que há
                      // ações: cada um usa a largura inteira, sem cálculo de
                      // quanto sobra pra cada lado.
                      child: acoes.isEmpty
                          ? Row(
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
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    if (emDrawer)
                                      Builder(
                                        builder: (context) => IconButton(
                                          icon: const Icon(Icons.menu),
                                          onPressed: () => Scaffold.of(context)
                                              .openDrawer(),
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
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.end,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: acoes,
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
