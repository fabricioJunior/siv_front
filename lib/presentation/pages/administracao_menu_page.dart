import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:flutter/material.dart';

class AdministracaoMenuPage extends StatelessWidget {
  const AdministracaoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final itens = <Widget>[
      if (PermissaoPorNome.acessoPermitido('ADMFM001')) ...[
        _ItemMenu(
          icon: Icons.person_outline,
          titulo: 'Usuários',
          subtitulo: 'Acesso, cadastro e manutenção de usuários.',
          onTap: () => Navigator.pushNamed(context, '/usuarios'),
        ),
        const SizedBox(height: 12),
        _ItemMenu(
          icon: Icons.lock_outline,
          titulo: 'Grupos de acesso',
          subtitulo: 'Permissões, perfis e vínculos por grupo.',
          onTap: () => Navigator.pushNamed(context, '/grupos_de_acesso'),
        ),
        const SizedBox(height: 12),
      ],
      if (PermissaoPorNome.acessoPermitido('ADMFM004')) ...[
        _ItemMenu(
          icon: Icons.business_outlined,
          titulo: 'Empresas',
          subtitulo: 'Gestão de empresas, parâmetros e terminais.',
          onTap: () => Navigator.pushNamed(context, '/empresas'),
        ),
        const SizedBox(height: 12),
      ],
      if (PermissaoPorNome.acessoPermitido('SYSFM001')) ...[
        _ItemMenu(
          icon: Icons.settings_outlined,
          titulo: 'Configurações',
          subtitulo: 'SMTP e ajustes sistêmicos da aplicação.',
          onTap: () => Navigator.pushNamed(context, '/configuracao_smtp'),
        ),
        const SizedBox(height: 12),
      ],
      _ItemMenu(
        icon: Icons.sync,
        titulo: 'Sincronização',
        subtitulo: 'Acompanhe ou execute a atualização de dados.',
        onTap: () => Navigator.pushNamed(context, '/sincronizacao'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Administração')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _MenuHeader(
            titulo: 'Acessos administrativos',
            descricao:
                'Organize permissões, empresas, configurações e rotinas operacionais do sistema.',
            icon: Icons.admin_panel_settings_outlined,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          ...itens,
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
