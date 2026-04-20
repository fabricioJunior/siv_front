import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema/presentation/bloc/dispositivo_bloc/dispositivo_bloc.dart';

class ConfiguracaoDispositivoPage extends StatelessWidget {
  const ConfiguracaoDispositivoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DispositivoBloc>(
      create: (_) => sl<DispositivoBloc>()..add(DispositivoIniciou()),
      child: const _ConfiguracaoDispositivoView(),
    );
  }
}

class _ConfiguracaoDispositivoView extends StatelessWidget {
  const _ConfiguracaoDispositivoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Dispositivo'),
      ),
      body: BlocConsumer<DispositivoBloc, DispositivoState>(
        listener: (context, state) {
          if (state.step == DispositivoStep.apagado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dados locais apagados com sucesso.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          }
          if (state.step == DispositivoStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ocorreu um erro. Tente novamente.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.step == DispositivoStep.inicial ||
              state.step == DispositivoStep.carregando) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state.step == DispositivoStep.falha && state.info == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Não foi possível carregar as informações.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DispositivoBloc>()
                        .add(DispositivoIniciou()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final info = state.info;
          final isApagando = state.step == DispositivoStep.apagando;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                titulo: 'Espaço em uso pelo app',
                valor: _formatarBytes(info?.espacoUsadoBytes ?? 0),
                icon: Icons.storage_outlined,
                color: Colors.indigo,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                titulo: 'Caminho do banco de dados',
                valor: info?.pathBancoDeDados ?? '-',
                icon: Icons.folder_outlined,
                color: Colors.teal,
                copiavel: true,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                titulo: 'Caminho de instalação do app',
                valor: info?.pathInstalacaoApp ?? '-',
                icon: Icons.install_desktop_outlined,
                color: Colors.deepPurple,
                copiavel: true,
              ),
              const SizedBox(height: 32),
              _ApagarDadosButton(isApagando: isApagando),
            ],
          );
        },
      ),
    );
  }

  String _formatarBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;
  final bool copiavel;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
    this.copiavel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    valor,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (copiavel)
              IconButton(
                tooltip: 'Copiar',
                icon: const Icon(Icons.copy_outlined, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: valor));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copiado!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ApagarDadosButton extends StatelessWidget {
  final bool isApagando;

  const _ApagarDadosButton({required this.isApagando});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isApagando ? null : () => _confirmarApagar(context),
        icon: isApagando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.delete_forever_outlined),
        label: Text(isApagando ? 'Apagando...' : 'Apagar dados locais'),
      ),
    );
  }

  void _confirmarApagar(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar dados locais'),
        content: const Text(
          'Esta ação removerá todos os dados armazenados localmente no dispositivo. '
          'O app será reiniciado e você precisará fazer login novamente.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<DispositivoBloc>()
                  .add(DispositivoApagarDadosSolicitado());
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}
