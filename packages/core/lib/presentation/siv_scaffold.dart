import 'package:flutter/material.dart';

import '../tema.dart';
import 'siv_menu_lateral.dart';

/// Casca de toda tela autenticada: menu lateral fixo + slot de conteúdo.
/// Título é responsabilidade de cada tela, renderizado no topo do próprio
/// corpo (ver [SivTituloPagina]).
///
/// Responsivo em 3 modos, decididos pela largura disponível:
/// - >= [SivDimensoes.breakpointMenuRail]: menu completo (236px), inline.
/// - >= [SivDimensoes.breakpointMenuDrawer]: menu colapsado em rail de
///   ícones (72px) com tooltip, inline.
/// - abaixo disso: menu vira [Drawer], acionado por um pequeno botão de
///   menu fixo no topo.
class SivScaffold extends StatelessWidget {
  final List<SivMenuLateralSecao> secoesMenu;
  final Widget? cabecalhoMenu;
  final Widget? rodapeMenu;
  final Widget corpo;
  final Widget? floatingActionButton;

  /// Override manual do usuário sobre o rail automático (breakpoints de
  /// largura) -- `null` mantém o comportamento automático existente,
  /// `true`/`false` força o modo independente da largura disponível.
  /// Ignorado quando a tela é estreita o bastante pra virar [Drawer].
  final bool? colapsoMenuForcado;
  final VoidCallback? onToggleColapsoMenu;

  const SivScaffold({
    super.key,
    required this.secoesMenu,
    required this.corpo,
    this.cabecalhoMenu,
    this.rodapeMenu,
    this.floatingActionButton,
    this.colapsoMenuForcado,
    this.onToggleColapsoMenu,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final emDrawer = largura < SivDimensoes.breakpointMenuDrawer;
        final emRail = !emDrawer &&
            (colapsoMenuForcado ??
                largura < SivDimensoes.breakpointMenuRail);

        final menu = SivMenuLateral(
          secoes: secoesMenu,
          cabecalho: cabecalhoMenu,
          rodape: rodapeMenu,
          colapsado: emRail,
          onToggleColapso: emDrawer ? null : onToggleColapsoMenu,
        );

        return Scaffold(
          // Telas pequenas usam Drawer -- selecionar um item deve fechá-lo
          // (padrão mobile); telas grandes têm o menu inline, não fecha nada.
          drawer: emDrawer
              ? Drawer(
                  width: 280,
                  child: SafeArea(
                    child: Builder(
                      builder: (drawerContext) => SivMenuLateral(
                        secoes: _secoesComFechamentoDrawer(
                          secoesMenu,
                          () => Scaffold.of(drawerContext).closeDrawer(),
                        ),
                        cabecalho: cabecalhoMenu,
                        rodape: rodapeMenu,
                        colapsado: false,
                        onToggleColapso: null,
                      ),
                    ),
                  ),
                )
              : null,
          floatingActionButton: floatingActionButton,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!emDrawer) menu,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sem Drawer -- o menu já fica inline, não precisa de
                    // botão pra abrir nada. Título/subtítulo saíram daqui:
                    // cada tela renderiza o próprio, no topo do corpo.
                    if (emDrawer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cores.superficie,
                          border: Border(bottom: BorderSide(color: cores.hairline)),
                        ),
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
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

/// Reconstrói [secoes] trocando cada `onTap` de navegação (item de topo
/// sem filhos, ou filho de acordeão) por uma versão que fecha o Drawer
/// antes de navegar. `onToggleExpandir` fica intacto -- só expande o
/// acordeão, não é navegação.
List<SivMenuLateralSecao> _secoesComFechamentoDrawer(
  List<SivMenuLateralSecao> secoes,
  VoidCallback fechar,
) {
  VoidCallback? envolver(VoidCallback? onTap) =>
      onTap == null ? null : () { fechar(); onTap(); };

  return secoes
      .map(
        (secao) => SivMenuLateralSecao(
          titulo: secao.titulo,
          itens: secao.itens
              .map(
                (item) => SivMenuLateralItem(
                  label: item.label,
                  icone: item.icone,
                  selecionado: item.selecionado,
                  onTap: envolver(item.onTap),
                  desabilitado: item.desabilitado,
                  expandido: item.expandido,
                  onToggleExpandir: item.onToggleExpandir,
                  filhos: item.filhos
                      .map(
                        (filho) => SivMenuLateralFilho(
                          label: filho.label,
                          selecionado: filho.selecionado,
                          onTap: envolver(filho.onTap),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      )
      .toList();
}
