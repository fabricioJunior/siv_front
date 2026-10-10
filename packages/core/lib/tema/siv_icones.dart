import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Ícones de traço fino do design system. Único ponto do app que importa o
/// pacote Lucide -- nenhuma tela deve importá-lo direto.
abstract final class SivIcones {
  static const IconData alcaArrastar = LucideIcons.gripVertical;
  static const IconData grupo = LucideIcons.folder;
  static const IconData lista = LucideIcons.listChecks;
  static const IconData porRegras = LucideIcons.refreshCw;
  static const IconData adicionar = LucideIcons.plus;
  static const IconData remover = LucideIcons.x;
  static const IconData buscar = LucideIcons.search;
  static const IconData lerCodigo = LucideIcons.scanBarcode;
  static const IconData link = LucideIcons.link;
  static const IconData editar = LucideIcons.pencil;

  /// Abre/fecha um grupo na prévia do menu.
  static const IconData expandir = LucideIcons.chevronDown;

  /// Tamanho em linhas de lista.
  static const double tamanhoLinha = 18;

  /// Tamanho dentro de botões.
  static const double tamanhoBotao = 16;
}
