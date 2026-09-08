import 'package:flutter/material.dart';

import '../tema/siv_theme.dart';

/// Trilha de progresso de N etapas: colunas de largura igual, cada uma com
/// uma barra de 3px (acesa quando a etapa foi atingida) e um rótulo abaixo.
/// Sem pills, sem círculos numerados.
class SivTrilhaDeProgresso extends StatelessWidget {
  const SivTrilhaDeProgresso({super.key, required this.passos});

  /// Lista de (rótulo, atingida).
  final List<(String, bool)> passos;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Row(
      children: [
        for (final passo in passos)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 3,
                    color: passo.$2 ? cores.aco : cores.hairline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    passo.$1.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: textos.rotulo,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
