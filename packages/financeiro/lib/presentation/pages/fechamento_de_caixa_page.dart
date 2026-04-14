import 'package:flutter/material.dart';

class FechamentoDeCaixaPage extends StatelessWidget {
  final int caixaId;

  const FechamentoDeCaixaPage({
    super.key,
    required this.caixaId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fechamento de caixa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Caixa #$caixaId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Conclua a contagem e confirme para encerrar o caixa.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Ao confirmar, o servidor atualizará o status do caixa para fechado.',
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Encerrar contagem e fechar caixa'),
            ),
          ],
        ),
      ),
    );
  }
}
