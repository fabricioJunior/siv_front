import 'package:flutter/widgets.dart';

/// Ações secundárias que a página atual quer expor na barra de título do
/// [SivScaffold] (montado uma única vez pelo shell de navegação, acima do
/// `Navigator`). Cada página chama [definir] no `initState`/rebuild e
/// [limpar] no `dispose` -- não há troca automática por rota porque o shell
/// não sabe quais widgets a página quer lá.
class SivPageAcoes {
  static final ValueNotifier<List<Widget>> notifier = ValueNotifier(const []);

  static void definir(List<Widget> acoes) {
    notifier.value = acoes;
  }

  static void limpar() {
    notifier.value = const [];
  }
}
