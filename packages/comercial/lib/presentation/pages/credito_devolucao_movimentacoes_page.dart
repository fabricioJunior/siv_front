import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class CreditoDevolucaoMovimentacoesPage extends StatefulWidget {
  final int pessoaId;

  const CreditoDevolucaoMovimentacoesPage({
    super.key,
    required this.pessoaId,
  });

  @override
  State<CreditoDevolucaoMovimentacoesPage> createState() =>
      _CreditoDevolucaoMovimentacoesPageState();
}

class _CreditoDevolucaoMovimentacoesPageState
    extends State<CreditoDevolucaoMovimentacoesPage> {
  bool _carregando = true;
  String? _erro;
  List<CreditoDevolucaoMovimentacao> _movimentacoes = const [];
  double _saldo = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final buscarMovimentacoes = sl<BuscarCreditoDevolucaoMovimentacoes>();
      final movimentacoes = await buscarMovimentacoes.call(
        pessoaId: widget.pessoaId,
      );

      movimentacoes.sort((a, b) => b.data.compareTo(a.data));

      final saldo = movimentacoes.fold<double>(
        0,
        (acumulado, item) => acumulado + item.valorAssinado,
      );

      if (!mounted) return;

      setState(() {
        _movimentacoes = movimentacoes;
        _saldo = double.parse(saldo.toStringAsFixed(2));
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar movimentacoes de credito de devolucao.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentacoes de credito de devolucao'),
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildResumo(context),
            const SizedBox(height: 12),
            if (_carregando)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              )
            else if (_erro != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _carregar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_movimentacoes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhuma movimentacao encontrada para esta pessoa.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._movimentacoes.map((item) => _MovimentacaoTile(item: item)),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pessoa #${widget.pessoaId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ResumoChip(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Saldo: ${_formatarMoeda(_saldo)}',
                ),
                _ResumoChip(
                  icon: Icons.list_alt_outlined,
                  label: '${_movimentacoes.length} movimentacao(oes)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimentacaoTile extends StatelessWidget {
  final CreditoDevolucaoMovimentacao item;

  const _MovimentacaoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final entrada = item.valorAssinado >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entrada
              ? Colors.green.withValues(alpha: 0.12)
              : Colors.red.withValues(alpha: 0.12),
          child: Icon(
            entrada ? Icons.south_west : Icons.north_east,
            color: entrada ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          '${item.tipoDocumento} • ${item.tipoMovimento}',
        ),
        subtitle: Text(
          '${_formatarData(item.data)}\nRomaneio: ${item.romaneioId ?? '-'} • Fatura: ${item.faturaId ?? '-'}',
        ),
        isThreeLine: true,
        trailing: Text(
          _formatarMoeda(item.valorAssinado),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: entrada ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _ResumoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ResumoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _formatarData(DateTime data) => formatarDataHora(data);

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
