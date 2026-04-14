import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';

class TerminalDaSessaoWidget extends StatelessWidget {
  final String titulo;

  const TerminalDaSessaoWidget({
    super.key,
    this.titulo = 'Terminal da sessao',
  });

  @override
  Widget build(BuildContext context) {
    final sessao = sl<IAcessoGlobalSessao>();
    final nomeTerminal = sessao.terminalNomeDaSessao;
    final idTerminal = sessao.terminalIdDaSessao;

    if (idTerminal == null) {
      return const SizedBox.shrink();
    }

    final descricao = nomeTerminal == null || nomeTerminal.trim().isEmpty
        ? 'ID $idTerminal'
        : '$nomeTerminal (ID $idTerminal)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.point_of_sale_outlined, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$titulo: $descricao',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
