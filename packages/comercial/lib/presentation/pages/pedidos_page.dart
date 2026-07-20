import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  late final PedidosBloc _bloc;
  final _buscaController = TextEditingController();
  final _buscaDebouncer = Debouncer(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _bloc = sl<PedidosBloc>()..add(PedidosIniciou());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _buscaDebouncer.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidosBloc>.value(
      value: _bloc,
      child: BlocBuilder<PedidosBloc, PedidosState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pedidos')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: state.step == PedidosStep.carregando
                  ? null
                  : () async {
                      final result =
                          await Navigator.pushNamed(context, '/pedido');
                      if (result == true && context.mounted) {
                        _bloc.add(PedidosIniciou());
                      }
                    },
              icon: const Icon(Icons.add),
              label: const Text('Novo'),
            ),
            body: RefreshIndicator(
              onRefresh: () async => _bloc.add(PedidosIniciou()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  // Header
                  if (state.step == PedidosStep.sucesso)
                    _PedidosHeader(total: state.pedidos.length),
                  if (state.step == PedidosStep.sucesso)
                    const SizedBox(height: 16),
                  // Busca
                  TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID, pessoa ou situação',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscaController.clear();
                                setState(() {});
                                _bloc.add(PedidosBuscaAlterada(''));
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      setState(() {});
                      _buscaDebouncer
                          .run(() => _bloc.add(PedidosBuscaAlterada(v)));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Estados
                  if (state.step == PedidosStep.carregando)
                    const _EstadoCard(
                      icon: Icons.hourglass_top_rounded,
                      titulo: 'Carregando pedidos',
                      descricao: 'Aguarde enquanto os dados são carregados.',
                      child: CircularProgressIndicator.adaptive(),
                    )
                  else if (state.step == PedidosStep.falha)
                    _EstadoCard(
                      icon: Icons.error_outline,
                      titulo: 'Falha ao carregar',
                      descricao:
                          state.erro ?? 'Não foi possível carregar os pedidos.',
                      action: TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                        onPressed: () => _bloc.add(PedidosIniciou()),
                      ),
                    )
                  else if (state.filtrados.isEmpty)
                    _EstadoCard(
                      icon: Icons.receipt_long_outlined,
                      titulo: state.busca.isNotEmpty
                          ? 'Nenhum resultado para a busca'
                          : 'Nenhum pedido encontrado',
                      descricao: state.busca.isNotEmpty
                          ? 'Tente outro termo de busca.'
                          : 'Crie um novo pedido para começar.',
                    )
                  else
                    ...state.filtrados.map(
                      (pedido) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PedidoCard(
                          pedido: pedido,
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/pedido',
                              arguments: {'idPedido': pedido.id},
                            );
                            if (result == true && context.mounted) {
                              _bloc.add(PedidosIniciou());
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PedidosHeader extends StatelessWidget {
  final int total;
  const _PedidosHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.10),
            child: Icon(Icons.receipt_long, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedidos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                ),
                Text(
                  '$total pedido${total != 1 ? 's' : ''} carregado${total != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.85),
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

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const _PedidoCard({required this.pedido, required this.onTap});

  Color get _cor => switch (pedido.situacao?.toLowerCase()) {
        'aberto' || 'criado' => Colors.blue,
        'conferido' => Colors.orange,
        'faturado' => Colors.green,
        'cancelado' => Colors.red,
        _ => Colors.blueGrey,
      };

  String get _labelSituacao => switch (pedido.situacao?.toLowerCase()) {
        'aberto' || 'criado' => 'Aberto',
        'conferido' => 'Conferido',
        'faturado' => 'Faturado',
        'cancelado' => 'Cancelado',
        _ => pedido.situacao ?? '-',
      };

  String _formatarValorMonetario(double? valor) {
    if (valor == null) return '-';
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) return '-';
    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  Widget _buildBadgeSecundario(String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }

  String _labelSituacaoPagamento(String? situacao) {
    switch (situacao) {
      case 'pendente':
        return 'Pendente';
      case 'parcial':
        return 'Parcial';
      case 'pago':
        return 'Pago';
      default:
        return situacao ?? '-';
    }
  }

  Color _corSituacaoPagamento(String? situacao) {
    switch (situacao) {
      case 'pago':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _labelSituacaoEntrega(String? situacao) {
    switch (situacao) {
      case 'aguardando_chamada':
        return 'Aguardando chamada';
      case 'chamado':
        return 'Chamado';
      case 'entregue':
        return 'Entregue';
      default:
        return situacao ?? '-';
    }
  }

  Color _corSituacaoEntrega(String? situacao) {
    switch (situacao) {
      case 'entregue':
        return Colors.green;
      case 'chamado':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cor.withValues(alpha: 0.10),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: cor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pedido #${pedido.id ?? '-'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pedido.pessoaNome ??
                                  (pedido.pessoaId != null
                                      ? 'Pessoa #${pedido.pessoaId}'
                                      : '-'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tipo: ${pedido.tipo ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vendedor: ${pedido.funcionarioNome ?? (pedido.funcionarioId != null ? 'Funcionário #${pedido.funcionarioId}' : '-')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatarDataHora(pedido.criadoEm),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            if (pedido.situacaoPagamento != null ||
                                pedido.situacaoEntrega != null) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  if (pedido.situacaoPagamento != null)
                                    _buildBadgeSecundario(
                                      'Pagto: ${_labelSituacaoPagamento(pedido.situacaoPagamento)}',
                                      _corSituacaoPagamento(
                                        pedido.situacaoPagamento,
                                      ),
                                    ),
                                  if (pedido.modalidadeEntrega == 'entrega' &&
                                      pedido.situacaoEntrega != null)
                                    _buildBadgeSecundario(
                                      'Entrega: ${_labelSituacaoEntrega(pedido.situacaoEntrega)}',
                                      _corSituacaoEntrega(
                                        pedido.situacaoEntrega,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (pedido.valorTotal != null) ...[
                            Text(
                              _formatarValorMonetario(pedido.valorTotal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _labelSituacao,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.chevron_right,
                              size: 18,
                              color: cor.withValues(alpha: 0.5)),
                        ],
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

class _EstadoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final Widget? child;
  final Widget? action;

  const _EstadoCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) ...[
              child!,
              const SizedBox(height: 16),
            ] else ...[
              Icon(icon, size: 42),
              const SizedBox(height: 12),
            ],
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
