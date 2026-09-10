import 'package:flutter/widgets.dart';

/// FAB que a página atual quer expor no [SivScaffold] (montado uma única vez
/// pelo shell de navegação). Mesmo padrão de [SivPageAcoes]: a página chama
/// [definir] no initState/rebuild e [limpar] no dispose.
///
/// Pensado pra telas com muitas ações no topo (barra de título) que ficam
/// apertadas em mobile -- a página pode reservar a AÇÃO PRIMÁRIA (criar/
/// adicionar) aqui como FAB, sempre alcançável, e deixar as secundárias na
/// barra de título normal (que já quebra linha sozinha via Wrap).
class SivPageFab {
  static final ValueNotifier<Widget?> notifier = ValueNotifier(null);

  static void definir(Widget? fab) {
    _agendar(() => notifier.value = fab);
  }

  static void limpar() {
    _agendar(() => notifier.value = null);
  }

  // Mesmo motivo do SivPageAcoes._agendar: adia pro fim do frame pra não
  // mudar o valor durante o build de um descendente (reentrância no layout).
  static void _agendar(VoidCallback aplicar) {
    WidgetsBinding.instance.addPostFrameCallback((_) => aplicar());
  }
}
