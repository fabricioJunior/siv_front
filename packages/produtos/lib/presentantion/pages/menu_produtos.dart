import 'package:flutter/material.dart';

class MenuProdutosPage extends StatelessWidget {
  const MenuProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento de Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context: context,
              title: 'Tamanhos',
              icon: Icons.straighten,
              color: Colors.blue,
              onTap: () {
                Navigator.of(context).pushNamed('/tamanhos');
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'Cores',
              icon: Icons.palette,
              color: Colors.purple,
              onTap: () {
                Navigator.of(context).pushNamed('/cores');
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'Categorias',
              icon: Icons.category,
              color: Colors.teal,
              onTap: () {
                Navigator.of(context).pushNamed('/categorias');
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'Marcas',
              icon: Icons.branding_watermark,
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pushNamed('/marcas');
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'Preços',
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () {
                _showComingSoon(context, 'Gerenciamento de Preços');
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'Produtos',
              icon: Icons.inventory,
              color: Colors.orange,
              onTap: () {
                Navigator.of(context).pushNamed('/referencias');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em desenvolvimento'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
