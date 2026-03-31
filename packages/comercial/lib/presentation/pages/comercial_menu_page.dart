import 'package:flutter/material.dart';

class ComercialMenuPage extends StatelessWidget {
  const ComercialMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comercial')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ItemMenu(
            icon: Icons.receipt_long,
            titulo: 'Pedidos',
            subtitulo: 'Criacao, conferencia, faturamento e cancelamento',
            onTap: () => Navigator.pushNamed(context, '/pedidos'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.local_shipping,
            titulo: 'Romaneios',
            subtitulo: 'Criacao, ajuste e observacoes de romaneio',
            onTap: () => Navigator.pushNamed(context, '/romaneios'),
          ),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
