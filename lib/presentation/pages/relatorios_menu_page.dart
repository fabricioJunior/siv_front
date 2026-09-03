import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:flutter/material.dart';

class RelatoriosMenuPage extends StatelessWidget {
  const RelatoriosMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = <_ItemData>[
      const _ItemData(
        icon: Icons.trending_up,
        titulo: 'Faturamento e Ticket',
        subtitulo: 'Consolidado de vendas, ticket médio e por vendedor.',
        cor: Colors.green,
        componente: 'RELFC001',
        route: '/relatorio_faturamento',
      ),
      const _ItemData(
        icon: Icons.point_of_sale,
        titulo: 'Histórico de vendas',
        subtitulo: 'Consulta por cliente, funcionário, caixa e data.',
        cor: Colors.green,
        componente: 'ROMFP001',
        route: '/vendas',
      ),
      const _ItemData(
        icon: Icons.badge_outlined,
        titulo: 'Vendas por Funcionário',
        subtitulo: 'Vendas de funcionários selecionados em um período.',
        cor: Colors.teal,
        componente: 'RELFC004',
        route: '/relatorio_vendas_por_funcionario',
      ),
      const _ItemData(
        icon: Icons.bar_chart,
        titulo: 'Curva ABC',
        subtitulo: 'Classificação de produtos por participação no faturamento.',
        cor: Colors.indigo,
        componente: 'RELFC002',
        route: '/relatorio_curva_abc',
      ),
      const _ItemData(
        icon: Icons.people_outline,
        titulo: 'Clientes Ativos',
        subtitulo: 'Clientes com compra recente no período selecionado.',
        cor: Colors.purple,
        componente: 'RELFC003',
        route: '/relatorio_clientes_ativos',
      ),
      const _ItemData(
        icon: Icons.shopping_bag_outlined,
        titulo: 'Compras de Clientes',
        subtitulo: 'Clientes vs. categoria, referência ou produto comprado.',
        cor: Colors.purple,
        componente: 'RELFC007',
        route: '/relatorio_compras_clientes',
      ),
      const _ItemData(
        icon: Icons.receipt_long_outlined,
        titulo: 'Movimentações do sistema',
        subtitulo: 'Todas as operações de produto (venda, devolução, transferência, compra e consignação).',
        cor: Colors.deepOrange,
        componente: 'ROMFP001',
        route: '/romaneios',
      ),
      const _ItemData(
        icon: Icons.cake_outlined,
        titulo: 'Aniversariantes',
        subtitulo: 'Clientes que fazem aniversário no mês.',
        cor: Colors.pink,
        componente: 'RELFC009',
        route: '/relatorio_clientes_aniversariantes',
      ),
      const _ItemData(
        icon: Icons.stars_outlined,
        titulo: 'Pontos de Fidelidade',
        subtitulo: 'Saldo, último crédito e cadastro no portal.',
        cor: Colors.amber,
        componente: 'RELFC006',
        route: '/relatorio_pontos_fidelidade',
      ),
      const _ItemData(
        icon: Icons.inventory_2_outlined,
        titulo: 'Produtos Defasados',
        subtitulo: 'Produtos ou referências sem movimentação recente.',
        cor: Colors.blueGrey,
        componente: 'RELFC008',
        route: '/relatorio_produtos_defasados',
      ),
      const _ItemData(
        icon: Icons.history,
        titulo: 'Histórico de Caixas',
        subtitulo: 'Caixas abertos, em contagem e fechados por período.',
        cor: Colors.brown,
        componente: 'FCXFP008',
        route: '/historico_de_caixas',
      ),
    ];

    // Exibe apenas itens com permissão — remove ruído visual de itens bloqueados
    final permitidos = todos
        .where((item) => PermissaoPorNome.acessoPermitido(item.componente))
        .toList();

    if (permitidos.isEmpty) {
      return const _SemAcesso();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final item in permitidos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ItemCard(item: item),
          ),
      ],
    );
  }
}

class _SemAcesso extends StatelessWidget {
  const _SemAcesso();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Sem acesso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text(
              'Você não possui permissão para acessar nenhum relatório.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemData {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final String componente;
  final String route;

  const _ItemData({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.componente,
    required this.route,
  });
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitulo,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: cor.withValues(alpha: 0.6), size: 20),
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
