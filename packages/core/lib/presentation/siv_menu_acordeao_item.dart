import 'package:flutter/widgets.dart';

/// Descreve uma filha de um item-acordeão do menu lateral (ver
/// `SivMenuLateralItem.filhos`). Cada `*_menu_page.dart` (hub) expõe uma
/// lista pública desses itens -- única fonte de dado usada tanto pela
/// própria página (se mantida) quanto pelo acordeão do menu.
class SivMenuAcordeaoFilho {
  final String label;
  final String rota;

  /// Componente exigido pra exibir o item -- `null` libera sem checagem
  /// (mesmo padrão de `_ItemDeNavegacao.exigePermissao`).
  final String? componente;

  /// Rótulo de agrupamento por tema, opcional (ex: relatórios). Itens
  /// consecutivos com o mesmo grupo ganham um cabeçalho no acordeão.
  final String? grupo;

  const SivMenuAcordeaoFilho({
    required this.label,
    required this.rota,
    this.componente,
    this.grupo,
  });
}
