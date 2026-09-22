import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';

/// Lista as movimentações (romaneios) desta consignação -- entradas
/// (consignacao_saida), devoluções e acertos -- uma por romaneio distinto
/// entre os itens já carregados. Toque no card abre o romaneio (tela já
/// existente, só leitura) com os produtos daquela movimentação.
class ConsignacaoExtratoPage extends StatefulWidget {
  final Consignacao consignacao;

  const ConsignacaoExtratoPage({super.key, required this.consignacao});

  @override
  State<ConsignacaoExtratoPage> createState() =>
      _ConsignacaoExtratoPageState();
}

class _ConsignacaoExtratoPageState extends State<ConsignacaoExtratoPage> {
  bool _carregando = true;
  String? _erro;
  List<Romaneio> _movimentacoes = const [];

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
      final romaneioIds = widget.consignacao.itens
          .map((item) => item.romaneioId)
          .whereType<int>()
          .toSet();

      final recuperarRomaneio = sl<RecuperarRomaneio>();
      final movimentacoes = await Future.wait(
        romaneioIds.map((id) => recuperarRomaneio.call(id)),
      );
      movimentacoes.sort((a, b) {
        final dataA = a.criadoEm ?? a.data;
        final dataB = b.criadoEm ?? b.data;
        if (dataA == null || dataB == null) return 0;
        return dataB.compareTo(dataA);
      });

      if (!mounted) return;
      setState(() {
        _movimentacoes = movimentacoes;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar as movimentações da consignação.';
        _carregando = false;
      });
    }
  }

  void _abrirRomaneio(int id) {
    Navigator.of(context).pushNamed(
      '/romaneio',
      arguments: {'idRomaneio': id, 'permitirEdicao': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimentações da consignação')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    'Nenhuma movimentação encontrada para esta consignação.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._movimentacoes.map(
                (romaneio) => _MovimentacaoTile(
                  romaneio: romaneio,
                  onTap: () => _abrirRomaneio(romaneio.id!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovimentacaoTile extends StatelessWidget {
  final Romaneio romaneio;
  final VoidCallback onTap;

  const _MovimentacaoTile({required this.romaneio, required this.onTap});

  String get _rotuloOperacao {
    switch (romaneio.operacao) {
      case TipoOperacao.consignacao_saida:
        return 'Saída de produtos';
      case TipoOperacao.consignacao_devolucao:
        return 'Devolução';
      case TipoOperacao.consignacao_acerto:
        return 'Acerto';
      default:
        return romaneio.operacao?.descricao ?? 'Movimentação';
    }
  }

  IconData get _icone {
    switch (romaneio.operacao) {
      case TipoOperacao.consignacao_devolucao:
        return Icons.assignment_return_outlined;
      case TipoOperacao.consignacao_acerto:
        return Icons.point_of_sale_outlined;
      default:
        return Icons.north_east;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = romaneio.criadoEm ?? romaneio.data;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(_icone)),
        title: Text('ID ${romaneio.id} • $_rotuloOperacao'),
        subtitle: Text(data != null ? _formatarData(data) : '-'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final ano = local.year.toString();
  return '$dia/$mes/$ano';
}
