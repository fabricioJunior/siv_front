import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/compras_do_cliente_bloc/compras_do_cliente_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('T').first.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

class ComprasDoClientePage extends StatefulWidget {
  final int pessoaId;
  final String nomeCliente;

  const ComprasDoClientePage({
    super.key,
    required this.pessoaId,
    required this.nomeCliente,
  });

  @override
  State<ComprasDoClientePage> createState() => _ComprasDoClientePageState();
}

class _ComprasDoClientePageState extends State<ComprasDoClientePage> {
  late final ComprasDoClienteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ComprasDoClienteBloc>()
      ..add(ComprasDoClienteCarregar(pessoaId: widget.pessoaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ComprasDoClienteBloc>.value(
      value: _bloc,
      child: BlocBuilder<ComprasDoClienteBloc, ComprasDoClienteState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.nomeCliente)),
            body: switch (state.step) {
              ComprasDoClienteStep.carregando ||
              ComprasDoClienteStep.inicial =>
                const Center(child: CircularProgressIndicator.adaptive()),
              ComprasDoClienteStep.falha => _EstadoCard(
                  titulo: 'Falha ao carregar',
                  descricao: state.erro ?? '',
                  onRetry: () => _bloc.add(
                      ComprasDoClienteCarregar(pessoaId: widget.pessoaId)),
                ),
              ComprasDoClienteStep.sucesso => state.dados!.items.isEmpty
                  ? const _EstadoCard(
                      titulo: 'Nenhuma compra encontrada',
                      descricao: 'Este cliente ainda não possui compras.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: state.dados!.items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _CompraCard(item: item),
                            ),
                          )
                          .toList(),
                    ),
            },
          );
        },
      ),
    );
  }
}

class _CompraCard extends StatelessWidget {
  final RelatorioClienteCompraItem item;
  const _CompraCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF388E3C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.receipt_long_outlined,
                          color: Color(0xFF388E3C), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Romaneio #${item.romaneioId}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            item.empresaNome,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmtMoeda(item.valorLiquido),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          _fmtData(item.data),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.titulo,
    required this.descricao,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(titulo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(descricao,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                      onPressed: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
