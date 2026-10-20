import 'package:flutter/material.dart';

import '../../tema.dart';

/// Chip de filtro de relatório. Padrão: dropdown (`Loja: Todas ▾`); use
/// [RelatorioFiltroChip.toggle] para checkbox em chip.
class RelatorioFiltroChip extends StatelessWidget {
  final String rotulo;
  final String? valor;
  final bool? marcado;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged;

  const RelatorioFiltroChip({
    super.key,
    required this.rotulo,
    this.valor,
    required VoidCallback this.onTap,
  }) : marcado = null,
       onChanged = null;

  const RelatorioFiltroChip.toggle({
    super.key,
    required this.rotulo,
    required bool this.marcado,
    required ValueChanged<bool> this.onChanged,
  }) : valor = null,
       onTap = null;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final toggle = marcado != null;
    final ativo = marcado ?? false;
    return Material(
      color: ativo ? cores.selecaoFundo : cores.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        side: BorderSide(color: ativo ? cores.aco : cores.hairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: toggle ? () => onChanged!(!ativo) : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: SivDimensoes.alvoToqueMinimo,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (toggle) ...[
                  Icon(
                    ativo ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: ativo ? cores.aco : cores.textoApoio,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  valor == null ? rotulo : '$rotulo: $valor',
                  style: context.sivTextos.apoio.copyWith(color: cores.tinta),
                ),
                if (!toggle) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 20, color: cores.aco),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
