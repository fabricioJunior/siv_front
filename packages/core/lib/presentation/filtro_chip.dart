import 'package:flutter/material.dart';

/// Chip compacto padrão para abrir um filtro em modal (bottom sheet).
/// Mesmo padrão visual usado no filtro de referência de "Movimentações
/// Manuais" -- ocupa pouco espaço e mostra o estado atual do filtro no
/// próprio label, com opção de limpar via [onLimpar].
class FiltroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLimpar;

  const FiltroChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      onDeleted: onLimpar,
      deleteIcon: onLimpar == null ? null : const Icon(Icons.close, size: 16),
    );
  }
}
