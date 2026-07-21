import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';
import 'package:pagamentos/presentation/bloc/pagamentos_avulsos_bloc/pagamentos_avulsos_bloc.dart';
import 'package:pagamentos/presentation/pages/pagamento_avulso_page.dart';
import 'package:pagamentos/presentation/pages/pagamento_avulso_detalhes_page.dart';
import 'package:pagamentos/use_cases.dart';

class PagamentosAvulsosPage extends StatefulWidget {
  const PagamentosAvulsosPage({super.key});

  @override
  State<PagamentosAvulsosPage> createState() => _PagamentosAvulsosPageState();
}

class _PagamentosAvulsosPageState extends State<PagamentosAvulsosPage> {
  late final PagamentosAvulsosBloc _bloc;
  final _buscaController = TextEditingController();
  final _buscaDebouncer = Debouncer(milliseconds: 400);
  String _orderDir = 'DESC';
  String? _providerFiltro;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PagamentosAvulsosBloc>()
      ..add(PagamentosAvulsosIniciou(orderDir: _orderDir))
      ..add(PagamentosAvulsosProvidersCarregar());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _buscaDebouncer.cancel();
    _bloc.close();
    super.dispose();
  }

  void _carregar() {
    _bloc.add(
      PagamentosAvulsosIniciou(
        orderDir: _orderDir,
        descricao: _buscaController.text.trim().isNotEmpty
            ? _buscaController.text.trim()
            : null,
        provider: _providerFiltro,
      ),
    );
  }

  void _alternarOrdenacao() {
    setState(() {
      _orderDir = _orderDir == 'DESC' ? 'ASC' : 'DESC';
    });
    _carregar();
  }

  Future<void> _abrirDetalhes(
    BuildContext context,
    PagamentoAvulso item,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PagamentoAvulsoDetalhesPage(pagamento: item),
      ),
    );

    if (context.mounted) {
      _carregar();
    }
  }

  Future<bool> _confirmarExclusao(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir pagamento avulso'),
          content: const Text(
            'Tem certeza que deseja excluir este pagamento avulso? Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    return confirmou ?? false;
  }

  Future<void> _excluir(int id) async {
    await sl<ExcluirPagamentoAvulso>().call(id);
    if (mounted) {
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PagamentosAvulsosBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagamentos avulsos'),
          actions: [
            IconButton(
              tooltip: _orderDir == 'DESC'
                  ? 'Mais recentes primeiro'
                  : 'Mais antigos primeiro',
              onPressed: _alternarOrdenacao,
              icon: Icon(
                _orderDir == 'DESC'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
              ),
            ),
            IconButton(
              tooltip: 'Atualizar pagamentos',
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Novo pagamento avulso',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PagamentoAvulsoPage(),
              ),
            );

            if (context.mounted) {
              _carregar();
            }
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _buscaController,
                decoration: InputDecoration(
                  hintText: 'Buscar por descrição...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _buscaController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaController.clear();
                            setState(() {});
                            _carregar();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) {
                  setState(() {});
                  _buscaDebouncer.run(_carregar);
                },
                onSubmitted: (_) => _carregar(),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PagamentosAvulsosBloc, PagamentosAvulsosState>(
              builder: (context, state) {
                if (state.providers.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _providerFiltro == null,
                          onSelected: (_) {
                            setState(() => _providerFiltro = null);
                            _carregar();
                          },
                        ),
                      ),
                      ...state.providers.map(
                        (provider) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(_providerLabel(provider)),
                            selected: _providerFiltro == provider,
                            onSelected: (_) {
                              setState(() => _providerFiltro = provider);
                              _carregar();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<PagamentosAvulsosBloc, PagamentosAvulsosState>(
                builder: (context, state) {
                  if (state.step == PagamentosAvulsosStep.inicial ||
                      state.step == PagamentosAvulsosStep.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.step == PagamentosAvulsosStep.falha) {
                    return Center(
                      child: Text(state.erro ?? 'Erro ao carregar pagamentos.'),
                    );
                  }

                  if (state.pagamentos.isEmpty) {
                    return const Center(
                      child: Text('Nenhum pagamento avulso encontrado.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.pagamentos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.pagamentos[index];
                      final status = (item.status ?? '').toLowerCase();
                      final statusColor = _statusColor(context, status);
                      return Dismissible(
                        key: ValueKey(item.id ?? item.hashCode),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmarExclusao(context),
                        onDismissed: (_) {
                          final id = item.id;
                          if (id != null) {
                            _excluir(id);
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: statusColor, width: 1.2),
                          ),
                          child: ListTile(
                            onTap: () => _abrirDetalhes(context, item),
                            title: Text(item.description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Forma: ${_providerLabel(item.provider)}'),
                                if (item.customer.nome.trim().isNotEmpty)
                                  Text('Cliente: ${item.customer.nome}'),
                                const SizedBox(height: 4),
                                if (item.pagoEm != null)
                                  Text(
                                    'Pago às: ${_formatarDataHora(item.pagoEm)}',
                                  ),
                                if (item.criadoEm != null)
                                  Text(
                                    'Criado às: ${_formatarDataHora(item.criadoEm ?? item.atualizadoEm)}',
                                  ),
                                if (item.expiraEm != null &&
                                    item.status?.toLowerCase() == 'pending')
                                  Text(
                                    'Expira às: ${_formatarDataHora(item.expiraEm)}',
                                  ),
                                const SizedBox(height: 6),
                                _statusChip(status),
                              ],
                            ),
                            trailing: Text(
                              'R\$ ${(item.amount / 100).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    if (status == 'paid') {
      return Colors.green.shade600;
    }
    if (status == 'pending') {
      return Colors.orange.shade700;
    }
    return Theme.of(context).colorScheme.outline;
  }

  Widget _statusChip(String status) {
    final isPago = status == 'paid';
    final isPendente = status == 'pending';

    final color = isPago
        ? Colors.green.shade600
        : isPendente
            ? Colors.orange.shade700
            : Colors.blueGrey;
    final label = isPago
        ? 'Pago'
        : isPendente
            ? 'Pendente'
            : (status.isEmpty ? 'Sem status' : status);
    final icon = isPago
        ? Icons.check_circle
        : isPendente
            ? Icons.schedule
            : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _providerLabel(String provider) {
    if (provider == 'infinitypay') {
      return 'InfinityPay';
    }
    if (provider == 'openpix') {
      return 'OpenPix';
    }
    if (provider == 'mercadopago') {
      return 'Mercado Pago';
    }
    return provider;
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) {
      return '-';
    }

    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}
