import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<SyncDataBloc>().add(
        const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.home),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AppBloc, AppState>(
            bloc: sl<AppBloc>(),
            builder: (context, state) {
              final operacoes = <_AccessFlowItem>[
                const _AccessFlowItem(
                  icon: Icons.storefront,
                  title: 'Comercial',
                  subtitle: 'Pedidos, romaneios e rotinas de venda.',
                  color: Colors.deepOrange,
                  route: '/comercial',
                ),
                const _AccessFlowItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Estoque',
                  subtitle: 'Saldo, filtros e acompanhamento do estoque.',
                  color: Colors.indigo,
                  route: '/estoque',
                ),
                const _AccessFlowItem(
                  icon: Icons.payment,
                  title: 'Pagamentos',
                  subtitle: 'Recebimentos avulsos e controle rápido.',
                  color: Colors.teal,
                  route: '/pagamentos_avulsos',
                ),
                const _AccessFlowItem(
                  icon: Icons.input,
                  title: 'Entrada manual',
                  subtitle: 'Lançamento manual de produtos no fluxo.',
                  color: Colors.redAccent,
                  route: '/entrada_manual_de_produtos',
                ),
              ];

              final cadastros = <_AccessFlowItem>[
                if (PermissaoPorNome.acessoPermitido('PESFM001'))
                  const _AccessFlowItem(
                    icon: Icons.people,
                    title: 'Pessoas',
                    subtitle: 'Clientes, fornecedores e cadastros gerais.',
                    color: Colors.pink,
                    route: '/pessoas',
                  ),
                if (PermissaoPorNome.acessoPermitido('PRODFM001'))
                  const _AccessFlowItem(
                    icon: Icons.shopping_bag,
                    title: 'Produtos',
                    subtitle:
                        'Referências, cores, tamanhos, marcas e categorias.',
                    color: Colors.deepPurple,
                    route: '/menu_produtos',
                  ),
                const _AccessFlowItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Financeiro',
                  subtitle: 'Formas de pagamento, preços e cobranças.',
                  color: Colors.brown,
                  route: '/financeiro',
                ),
              ];

              final administracao = <_AccessFlowItem>[
                if (PermissaoPorNome.acessoPermitido('ADMFM001') ||
                    PermissaoPorNome.acessoPermitido('ADMFM004') ||
                    PermissaoPorNome.acessoPermitido('SYSFM001'))
                  const _AccessFlowItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Administração',
                    subtitle: 'Usuários, grupos, empresas e configurações.',
                    color: Colors.blueGrey,
                    route: '/administracao',
                  ),
                const _AccessFlowItem(
                  icon: Icons.sync,
                  title: 'Sincronização',
                  subtitle: 'Acompanhe e execute a atualização de dados.',
                  color: Colors.lightBlue,
                  route: '/sincronizacao',
                ),
              ];

              final userName = state.usuarioDaSessao?.nome ?? 'Usuário';
              final userInitial = userName.isNotEmpty ? userName[0] : 'U';
              final empresaNome =
                  state.empresaDaSessao?.nome ?? 'Nenhuma empresa selecionada';

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildHeroCard(
                          context,
                          userName: userName,
                          userInitial: userInitial,
                          empresaNome: empresaNome,
                        ),
                        const SizedBox(height: 20),
                        _AccessSection(
                          title: 'Operações do dia',
                          subtitle: 'Fluxos mais usados na rotina operacional.',
                          items: operacoes,
                        ),
                        const SizedBox(height: 20),
                        _AccessSection(
                          title: 'Cadastros e catálogo',
                          subtitle:
                              'Organize os cadastros principais do sistema.',
                          items: cadastros,
                        ),
                        if (administracao.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _AccessSection(
                            title: 'Administração e suporte',
                            subtitle:
                                'Permissões, empresas, configurações e apoio operacional.',
                            items: administracao,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('sair_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          sl<AppBloc>().add(AppDesautenticou());
                        },
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Sair',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String userName,
    required String userInitial,
    required String empresaNome,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade500, Colors.blue.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(
                  userInitial.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Empresa atual: $empresaNome',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/selecionar_empresa');
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Trocar empresa'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/sincronizacao');
                },
                icon: const Icon(Icons.sync),
                label: const Text('Sincronização'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_AccessFlowItem> items;

  const _AccessSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1100
                ? 3
                : constraints.maxWidth >= 700
                ? 2
                : 1;
            const spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _AccessFlowCard(item: item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AccessFlowItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _AccessFlowItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}

class _AccessFlowCard extends StatelessWidget {
  final _AccessFlowItem item;

  const _AccessFlowCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: item.color.withValues(alpha: 0.12),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
