import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:flutter/material.dart';

class AdministracaoMenuPage extends StatelessWidget {
  const AdministracaoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = <_ItemData>[
      const _ItemData(
        icon: Icons.person_outline,
        titulo: 'Usuários',
        subtitulo: 'Acesso, cadastro e manutenção de usuários.',
        cor: Colors.deepPurple,
        componente: 'ADMFM001',
        route: '/usuarios',
      ),
      const _ItemData(
        icon: Icons.lock_outline,
        titulo: 'Grupos de acesso',
        subtitulo: 'Permissões, perfis e vínculos por grupo.',
        cor: Colors.indigo,
        componente: 'ADMFM002',
        route: '/grupos_de_acesso',
      ),
      const _ItemData(
        icon: Icons.business_outlined,
        titulo: 'Empresas',
        subtitulo: 'Gestão de empresas, parâmetros e terminais.',
        cor: Colors.blueGrey,
        componente: 'ADMFM004',
        route: '/empresas',
      ),
      const _ItemData(
        icon: Icons.settings_outlined,
        titulo: 'Configurações',
        subtitulo: 'SMTP e ajustes sistêmicos da aplicação.',
        cor: Colors.teal,
        componente: 'SYSFM001',
        route: '/configuracoes',
      ),
      const _ItemData(
        icon: Icons.sync,
        titulo: 'Sincronização',
        subtitulo: 'Acompanhe ou execute a atualização de dados.',
        cor: Colors.lightBlue,
        route: '/sincronizacao',
      ),
    ];

    // Exibe apenas itens com permissão — remove ruído visual de itens bloqueados
    final permitidos = todos
        .where(
          (item) =>
              item.componente == null ||
              PermissaoPorNome.acessoPermitido(item.componente!),
        )
        .toList();

    if (permitidos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administração')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Sem acesso',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text(
                  'Você não possui permissão para acessar nenhuma função administrativa.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Administração')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(
            titulo: 'Acessos administrativos',
            descricao:
                'Permissões, empresas, configurações e rotinas do sistema.',
          ),
          const SizedBox(height: 16),
          ...permitidos.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ItemCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemData {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final String? componente;
  final String route;

  const _ItemData({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    this.componente,
    required this.route,
  });
}

class _Header extends StatelessWidget {
  final String titulo;
  final String descricao;

  const _Header({required this.titulo, required this.descricao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade500, Colors.blueGrey.shade400],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
            ),
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
                    color: Colors.white.withValues(alpha: 0.90),
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

class _ItemCard extends StatelessWidget {
  final _ItemData item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cor = item.cor;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cor.withValues(alpha: 0.10),
                        ),
                        child: Icon(item.icon, color: cor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.titulo,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitulo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        color: cor.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
