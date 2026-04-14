import 'package:flutter/material.dart';

class FinanceiroMenuPage extends StatelessWidget {
  const FinanceiroMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financeiro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuHeader(
            titulo: 'Fluxos financeiros',
            descricao:
                'Centralize pagamentos, formas de pagamento e tabelas de preço em um único lugar.',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.brown,
          ),
          const SizedBox(height: 16),
          _ItemMenu(
            icon: Icons.payment,
            titulo: 'Pagamentos avulsos',
            subtitulo: 'Lançamentos, consulta e acompanhamento de pagamentos.',
            onTap: () => Navigator.pushNamed(context, '/pagamentos_avulsos'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.credit_card,
            titulo: 'Formas de pagamento',
            subtitulo: 'Cadastre e mantenha os meios de pagamento disponíveis.',
            onTap: () => Navigator.pushNamed(context, '/formas_de_pagamento'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.receipt_long,
            titulo: 'Fluxo de caixa',
            subtitulo: 'Abra o caixa e acompanhe os lancamentos do extrato.',
            onTap: () => Navigator.pushNamed(context, '/fluxo_de_caixa'),
          ),
          const SizedBox(height: 12),
          _ItemMenu(
            icon: Icons.attach_money,
            titulo: 'Tabelas de preço',
            subtitulo: 'Gerencie preços e condições comerciais por tabela.',
            onTap: () => Navigator.pushNamed(context, '/tabelas_de_preco'),
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
            color.withValues(alpha: 0.72)
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
