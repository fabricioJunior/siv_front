import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Rodapé fixo de ação: status à esquerda, ação secundária e primária à
/// direita. Desktop com 72px de altura; mobile empilha com a primária de
/// largura total.
class SivRodapeAcoes extends StatelessWidget {
  /// Texto de situação à esquerda do ponto.
  final String status;

  /// Cor do ponto de 8px (ex.: `atencao` com pendências, `aco` sem).
  final Color? corStatus;
  final Widget? secundaria;
  final Widget primaria;
  final bool mobile;

  const SivRodapeAcoes({
    super.key,
    required this.status,
    required this.primaria,
    this.corStatus,
    this.secundaria,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final ponto = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: corStatus ?? cores.aco,
      ),
    );
    final decoracao = BoxDecoration(
      color: cores.superficie,
      border: Border(top: BorderSide(color: cores.hairline)),
    );

    if (mobile) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
        decoration: decoracao,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ponto,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: textos.apoio.copyWith(fontSize: 12.5),
                  ),
                ),
                if (secundaria != null) secundaria!,
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(height: 52, child: primaria),
          ],
        ),
      );
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: SivDimensoes.paddingBarraTituloHorizontal,
      ),
      decoration: decoracao,
      child: Row(
        children: [
          ponto,
          const SizedBox(width: 8),
          Expanded(
            child: Text(status, style: textos.apoio.copyWith(fontSize: 13.5)),
          ),
          if (secundaria != null) ...[secundaria!, const SizedBox(width: 12)],
          SizedBox(height: 48, child: primaria),
        ],
      ),
    );
  }
}
