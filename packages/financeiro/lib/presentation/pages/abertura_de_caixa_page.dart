import 'package:flutter/material.dart';

class AberturaDeCaixaPage extends StatelessWidget {
  final int? empresaId;
  final int? terminalId;
  final bool carregando;
  final String? erro;
  final VoidCallback onAbrir;

  const AberturaDeCaixaPage({
    super.key,
    required this.empresaId,
    required this.terminalId,
    required this.carregando,
    this.erro,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final podeAbrir = !carregando && empresaId != null && terminalId != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.point_of_sale_rounded, size: 44),
                const SizedBox(height: 12),
                Text(
                  'Abertura de caixa',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  empresaId == null || terminalId == null
                      ? 'Sessão sem empresa ou terminal definido. Selecione-os para abrir o caixa.'
                      : 'Empresa: $empresaId | Terminal: $terminalId',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: empresaId == null || terminalId == null
                        ? Colors.orange
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                if (carregando)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (erro != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      erro!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: podeAbrir ? onAbrir : null,
                  icon: carregando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open_outlined),
                  label: Text(carregando ? 'Abrindo caixa...' : 'Abrir caixa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
