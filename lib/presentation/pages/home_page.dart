import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:autenticacao/models.dart';
import 'package:core/sessao.dart';
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

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja encerrar a sessão atual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      sl<AppBloc>().add(AppDesautenticou());
    }
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
              // Operações do dia — Comercial expandido diretamente (remove sub-menu)
              final operacoes = <_AccessFlowItem>[
                const _AccessFlowItem(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Caixa',
                  subtitle: 'Abertura, sangrias, suprimentos e fechamento.',
                  color: Colors.teal,
                  route: '/fluxo_de_caixa',
                  componentesNecessarios: ['FCXFP001', 'FCXFP002', 'FCXFL001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.shopping_cart_checkout_outlined,
                  title: 'Venda',
                  subtitle: 'Seleção de cliente, contagem e envio ao caixa.',
                  color: Colors.deepOrange,
                  route: '/venda',
                  precisaDeTerminal: true,
                  precisaDeCaixaAberto: true,
                  componentesNecessarios: ['PEDFC001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos',
                  subtitle: 'Retirada ou entrega com pagamento pendente.',
                  color: Colors.indigoAccent,
                  route: '/pedidos',
                  componentesNecessarios: ['PEDFC001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.sync_alt,
                  title: 'Troca e devolução',
                  subtitle:
                      'Seleção do romaneio original e recebimento no caixa.',
                  color: Colors.redAccent,
                  route: '/devolucao',
                  precisaDeCaixaAberto: true,
                  componentesNecessarios: ['PEDFC001'],
                ),

                const _AccessFlowItem(
                  icon: Icons.inventory_outlined,
                  title: 'Consignações',
                  subtitle: 'Remessas, movimentações e acerto com o cliente.',
                  color: Colors.indigo,
                  route: '/consignacoes',
                  componentesNecessarios: ['CONFC001'],
                ),

                const _AccessFlowItem(
                  icon: Icons.payment,
                  title: 'Pagamentos',
                  subtitle: 'Recebimentos avulsos e controle rápido.',
                  color: Colors.teal,
                  route: '/pagamentos_avulsos',
                  componentesNecessarios: ['PAGFM001', 'PAGFP005'],
                ),
              ];

              final cadastros = <_AccessFlowItem>[
                const _AccessFlowItem(
                  icon: Icons.people,
                  title: 'Pessoas',
                  subtitle: 'Clientes, fornecedores e cadastros gerais.',
                  color: Colors.pink,
                  route: '/pessoas',
                  componentesNecessarios: [' PESFC001, PESFC002', 'PESFM003'],
                ),
                const _AccessFlowItem(
                  icon: Icons.shopping_bag,
                  title: 'Produtos',
                  subtitle:
                      'Referências, cores, tamanhos, marcas e categorias.',
                  color: Colors.deepPurple,
                  route: '/menu_produtos',
                  componentesNecessarios: [
                    'PRDFM001',
                    'PRDFM003',
                    'PRDFM004',
                    'PRDFM006',
                  ],
                ),
                const _AccessFlowItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Financeiro',
                  subtitle: 'Formas de pagamento, preços e cobranças.',
                  color: Colors.brown,
                  route: '/financeiro',
                  componentesNecessarios: [
                    'GERFM001',
                    'FCXFP001',
                    'PRDFM010',
                    'PAGFM001',
                  ],
                ),
                const _AccessFlowItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Estoque',
                  subtitle: 'Saldo, filtros e acompanhamento do estoque.',
                  color: Colors.indigo,
                  route: '/estoque',
                  componentesNecessarios: ['PRDFL001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.warehouse_outlined,
                  title: 'Gerência de Estoque',
                  subtitle: 'Entrada manual, consulta, histórico e balanço.',
                  color: Colors.indigo,
                  route: '/gerencia_estoque',
                  componentesNecessarios: ['ROMFP001', 'PRDFL001'],
                ),
              ];

              final relatorios = <_AccessFlowItem>[
                const _AccessFlowItem(
                  icon: Icons.trending_up,
                  title: 'Faturamento e Ticket',
                  subtitle:
                      'Consolidado de vendas, ticket médio e por vendedor.',
                  color: Colors.green,
                  route: '/relatorio_faturamento',
                  componentesNecessarios: ['RELFC001'],
                ),

                const _AccessFlowItem(
                  icon: Icons.bar_chart,
                  title: 'Curva ABC',
                  subtitle:
                      'Classificação de produtos por participação no faturamento.',
                  color: Colors.indigo,
                  route: '/relatorio_curva_abc',
                  componentesNecessarios: ['RELFC002'],
                ),
                const _AccessFlowItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Romaneios',
                  subtitle: 'Visualizar todos os romaneios do sistema.',
                  color: Colors.deepOrange,
                  route: '/romaneios',
                  componentesNecessarios: ['ROMFP001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.people_outline,
                  title: 'Clientes Ativos',
                  subtitle:
                      'Clientes com compra recente no período selecionado.',
                  color: Colors.purple,
                  route: '/relatorio_clientes_ativos',
                  componentesNecessarios: ['RELFC003'],
                ),
                const _AccessFlowItem(
                  icon: Icons.badge_outlined,
                  title: 'Vendas por Funcionário',
                  subtitle:
                      'Vendas de funcionários selecionados em um período.',
                  color: Colors.teal,
                  route: '/relatorio_vendas_por_funcionario',
                  componentesNecessarios: ['RELFC004'],
                ),

                const _AccessFlowItem(
                  icon: Icons.receipt_outlined,
                  title: 'Documentos Fiscais',
                  subtitle: 'Notas emitidas, pendentes e com falha.',
                  color: Colors.indigo,
                  route: '/documentos_fiscais',
                  componentesNecessarios: ['FISFM001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.point_of_sale,
                  title: 'Histórico de vendas',
                  subtitle: 'Consulta por cliente, funcionário, caixa e data.',
                  color: Colors.green,
                  route: '/vendas',
                  componentesNecessarios: ['ROMFP001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.history,
                  title: 'Histórico de Caixas',
                  subtitle:
                      'Caixas abertos, em contagem e fechados por período.',
                  color: Colors.brown,
                  route: '/historico_de_caixas',
                  componentesNecessarios: ['FCXFP008'],
                ),
              ];

              final administracao = <_AccessFlowItem>[
                const _AccessFlowItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administração',
                  subtitle: 'Usuários, grupos, empresas e configurações.',
                  color: Colors.blueGrey,
                  route: '/administracao',
                  componentesNecessarios: ['ADMFM001', 'ADMFM004', 'SYSFM001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.tune_outlined,
                  title: 'Config. Fiscal',
                  subtitle: 'Gateway de emissão de NF-e por empresa.',
                  color: Colors.indigo,
                  route: '/configuracao_fiscal',
                  componentesNecessarios: ['FISFM001'],
                ),
                const _AccessFlowItem(
                  icon: Icons.sync,
                  title: 'Sincronização',
                  subtitle: 'Acompanhe e execute a atualização de dados.',
                  color: Colors.lightBlue,
                  route: '/sincronizacao',
                ),
              ];

              // Filtra apenas itens com permissão — remove ruído visual de itens bloqueados
              List<_AccessFlowItem> _permitidos(List<_AccessFlowItem> items) =>
                  items
                      .where(
                        (item) =>
                            item.componentesNecessarios.isEmpty ||
                            item.componentesNecessarios.any(
                              PermissaoPorNome.acessoPermitido,
                            ),
                      )
                      .toList();

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
                        if (state.caixaIdDaSessao == null) ...[
                          const SizedBox(height: 12),
                          _buildAbrirCaixaBanner(context),
                        ],
                        const SizedBox(height: 20),
                        _AccessSection(
                          title: 'Operações do dia',
                          subtitle: 'Fluxos mais usados na rotina operacional.',
                          items: _permitidos(operacoes),
                        ),
                        const SizedBox(height: 20),
                        _AccessSection(
                          title: 'Cadastros e catálogo',
                          subtitle:
                              'Organize os cadastros principais do sistema.',
                          items: _permitidos(cadastros),
                        ),
                        if (_permitidos(relatorios).isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _AccessSection(
                            title: 'Relatórios',
                            subtitle:
                                'Indicadores de vendas, produtos e clientes.',
                            items: _permitidos(relatorios),
                          ),
                        ],
                        if (_permitidos(administracao).isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _AccessSection(
                            title: 'Administração e suporte',
                            subtitle:
                                'Permissões, empresas, configurações e apoio operacional.',
                            items: _permitidos(administracao),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // Sair: ação secundária — menos proeminente, com confirmação
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          key: const Key('sair_button'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => _confirmarSaida(context),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text(
                            'Sair',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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

  Widget _buildAbrirCaixaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.point_of_sale_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum caixa aberto neste terminal',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Abra o caixa para iniciar vendas e recebimentos.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/fluxo_de_caixa'),
            child: const Text('Abrir caixa'),
          ),
        ],
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
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      empresaNome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const TerminalDaSessaoWidget(titulo: 'Terminal atual'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Hero actions: apenas configurações de sessão (sem Sincronização — já está na lista)
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                    arguments: {'trocandoDeEmpresa': true},
                  );
                },
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Trocar empresa'),
              ),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _trocarTerminal(context);
                },
                icon: const Icon(Icons.point_of_sale_outlined, size: 18),
                label: const Text('Trocar terminal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _trocarTerminal(BuildContext context) async {
    final appState = sl<AppBloc>().state;

    if (appState.usuarioDaSessao == null || appState.empresaDaSessao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou empresa da sessão não encontrados.'),
        ),
      );
      return;
    }

    final terminaisDaEmpresa = appState.terminaisDaEmpresaDaSessao;

    if (terminaisDaEmpresa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum terminal disponivel para a empresa da sessao.'),
        ),
      );
      return;
    }

    final resultado = await Navigator.of(context).pushNamed(
      '/selecionar_terminal',
      arguments: {'terminais': terminaisDaEmpresa},
    );

    if (!context.mounted || resultado is! Map) {
      return;
    }

    final idTerminal = resultado['idTerminal'];
    final idEmpresa = resultado['idEmpresa'];
    final nomeTerminal = resultado['nomeTerminal'];

    if (idTerminal is! int || idEmpresa is! int || nomeTerminal is! String) {
      return;
    }

    sl<AppBloc>().add(
      AppSelecionouTerminalDaSessao(
        terminal: _TerminalSelecionado(
          id: idTerminal,
          idEmpresa: idEmpresa,
          nome: nomeTerminal,
        ),
      ),
    );
  }
}

class _TerminalSelecionado implements TerminalDoUsuario {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  _TerminalSelecionado({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
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
    if (items.isEmpty) return const SizedBox.shrink();

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
            const spacing = 10.0;
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
  final List<String> componentesNecessarios;
  final bool precisaDeCaixaAberto;
  final bool precisaDeTerminal;

  const _AccessFlowItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    this.precisaDeCaixaAberto = false,
    this.precisaDeTerminal = false,
    this.componentesNecessarios = const [],
  });
}

class _AccessFlowCard extends StatelessWidget {
  final _AccessFlowItem item;

  const _AccessFlowCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (item.precisaDeCaixaAberto &&
              sl<IAcessoGlobalSessao>().caixaIdDaSessao == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Esta funcionalidade requer um caixa aberto nesse terminal.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (item.precisaDeTerminal &&
              sl<IAcessoGlobalSessao>().terminalIdDaSessao == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Selecione um terminal antes de iniciar uma venda.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );

            final appState = sl<AppBloc>().state;
            final terminaisDaEmpresa = appState.terminaisDaEmpresaDaSessao;
            if (terminaisDaEmpresa.isEmpty) {
              return;
            }

            final resultado = await Navigator.of(context).pushNamed(
              '/selecionar_terminal',
              arguments: {'terminais': terminaisDaEmpresa},
            );

            if (!context.mounted || resultado is! Map) {
              return;
            }

            final idTerminal = resultado['idTerminal'];
            final idEmpresa = resultado['idEmpresa'];
            final nomeTerminal = resultado['nomeTerminal'];

            if (idTerminal is! int ||
                idEmpresa is! int ||
                nomeTerminal is! String) {
              return;
            }

            sl<AppBloc>().add(
              AppSelecionouTerminalDaSessao(
                terminal: _TerminalSelecionado(
                  id: idTerminal,
                  idEmpresa: idEmpresa,
                  nome: nomeTerminal,
                ),
              ),
            );
            return;
          }

          Navigator.pushNamed(context, item.route);
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Strip colorida lateral — padrão dashboard
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: item.color,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: item.color.withValues(alpha: 0.10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
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
                        color: item.color.withValues(alpha: 0.6),
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
