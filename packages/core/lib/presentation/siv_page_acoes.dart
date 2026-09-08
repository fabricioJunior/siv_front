import 'package:flutter/widgets.dart';

/// Ações secundárias que a página atual quer expor na barra de título do
/// [SivScaffold] (montado uma única vez pelo shell de navegação, acima do
/// `Navigator`). Cada página chama [definir] no `initState`/rebuild e
/// [limpar] no `dispose` -- não há troca automática por rota porque o shell
/// não sabe quais widgets a página quer lá.
class SivPageAcoes {
  static final ValueNotifier<List<Widget>> notifier = ValueNotifier(const []);

  static void definir(List<Widget> acoes) {
    _agendar(() => notifier.value = acoes);
  }

  static void limpar() {
    _agendar(() => notifier.value = const []);
  }

  // As páginas chamam definir/limpar de dentro do próprio builder (a cada
  // rebuild, pra manter as ações sincronizadas com o estado). notifier.value
  // notifica os listeners na hora -- e o listener (ValueListenableBuilder no
  // AppShell, ancestral acima do Navigator) fica fora da subárvore que está
  // sendo construída. Mudar o valor durante o build de um descendente reabre
  // build/layout de um ancestral já processado nesse mesmo frame, causando
  // reentrância ("!_debugDoingThisLayout"). Adiar pro fim do frame evita isso.
  static void _agendar(VoidCallback aplicar) {
    WidgetsBinding.instance.addPostFrameCallback((_) => aplicar());
  }
}
