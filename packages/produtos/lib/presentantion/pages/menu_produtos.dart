import 'package:flutter/material.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';

class MenuProdutosPage extends StatelessWidget {
  const MenuProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _MenuHeader(
            titulo: 'Catálogo de produtos',
            descricao:
                'Organize referências, variações, categorias e marcas em um fluxo visual mais simples.',
            icon: Icons.shopping_bag_outlined,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          _ItemMenu(
            icon: Icons.model_training,
            titulo: 'Modelos / Referências',
            subtitulo: 'Base do catálogo com referências, produtos e mídias.',
            componente: 'PRDFM003',
            onTap: () => Navigator.of(context).pushNamed('/referencias'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.straighten,
            titulo: 'Tamanhos',
            subtitulo: 'Cadastre e mantenha os tamanhos disponíveis.',
            componente: 'PRDFM001',
            onTap: () => Navigator.of(context).pushNamed('/tamanhos'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.palette,
            titulo: 'Cores',
            subtitulo: 'Gerencie variações e paleta do catálogo.',
            componente: 'PRDFM001',
            onTap: () => Navigator.of(context).pushNamed('/cores'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.category,
            titulo: 'Categorias',
            subtitulo: 'Estruture grupos e classificação dos produtos.',
            componente: 'PRDFM004',
            onTap: () => Navigator.of(context).pushNamed('/categorias'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.branding_watermark,
            titulo: 'Marcas',
            subtitulo: 'Cadastre e atualize marcas vinculadas aos itens.',
            componente: 'PRDFM006',
            onTap: () => Navigator.of(context).pushNamed('/marcas'),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icon;
  final Color color;

  const _MenuHeader({
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.92),
            color.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
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
  final String? componente;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    this.componente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final permitido =
        componente == null || PermissaoPorNome.acessoPermitido(componente!);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(permitido ? icon : Icons.lock_outline),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          permitido
              ? subtitulo
              : 'Acesso bloqueado para o seu perfil. Consulte o administrador.',
        ),
        trailing: Icon(permitido ? Icons.chevron_right : Icons.lock),
        onTap: () {
          if (permitido) {
            onTap();
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Você não possui permissão para acessar esta funcionalidade.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
