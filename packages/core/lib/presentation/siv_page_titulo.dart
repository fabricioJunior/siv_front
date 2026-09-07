import 'package:flutter/widgets.dart';

/// Título e subtítulo que a página atual quer sobrepor no `SivScaffold`
/// (montado uma única vez pelo shell de navegação, acima do `Navigator`).
/// Mesmo esquema de [SivPageAcoes]: cada página chama [definir] e [limpar]
/// no dispose -- sem título definido, o shell usa o label do item de menu
/// ativo.
class SivPageTitulo {
  static final ValueNotifier<String?> notifier = ValueNotifier(null);

  static void definir(String titulo) {
    _agendar(() => notifier.value = titulo);
  }

  static void limpar() {
    _agendar(() => notifier.value = null);
  }

  static void _agendar(VoidCallback aplicar) {
    WidgetsBinding.instance.addPostFrameCallback((_) => aplicar());
  }
}
