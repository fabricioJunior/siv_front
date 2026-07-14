import 'package:flutter/material.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';

class GerenciaEstoqueMenuPage extends StatelessWidget {
  const GerenciaEstoqueMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = <_ItemData>[
      const _ItemData(
        icon: Icons.input,
        titulo: 'Entrada manual de produto',
        subtitulo: 'Registro manual de entrada de itens no estoque.',
        cor: Colors.teal,
        componente: 'ROMFP001',
        route: '/entrada_manual_de_produtos',
      ),
      const _ItemData(
        icon: Icons.output,
        titulo: 'Saída manual de produto',
        subtitulo: 'Registro manual de saída de itens do estoque.',
        cor: Colors.deepOrange,
        componente: 'ROMFP001',
        route: '/saida_manual_de_produtos',
      ),
      const _ItemData(
        icon: Icons.inventory_2_outlined,
        titulo: 'Consulta de estoque',
        subtitulo: 'Saldo, filtros e acompanhamento do estoque.',
        cor: Colors.indigo,
        componente: 'PRDFL001',
        route: '/estoque',
      ),
      const _ItemData(
        icon: Icons.history,
        titulo: 'Histórico de movimentações manuais',
        subtitulo: 'Consulta por funcionário, quantidade e data.',
        cor: Colors.brown,
        componente: 'ROMFP001',
        route: '/romaneios_entrada_manual',
      ),
      const _ItemData(
        icon: Icons.fact_check_outlined,
        titulo: 'Balanço',
        subtitulo: 'Seleção de itens, contagem por lote e fechamento.',
        cor: Colors.blue,
        componente: 'PRDFL001',
        route: '/balancos',
      ),
    ];

    // Filtra apenas itens com permissão
    final permitidos = todos
        .where(
          (item) =>
              item.componente == null ||
              PermissaoPorNome.acessoPermitido(item.componente!),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gerência de Estoque')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(),
          const SizedBox(height: 16),
          if (permitidos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.lock_outline, size: 42, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Sem acesso',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Você não possui permissão para nenhum fluxo de estoque.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.92),
            Colors.indigo.withValues(alpha: 0.70),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: const Icon(
              Icons.warehouse_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gerência de Estoque',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entradas, consulta e balanço do estoque.',
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
