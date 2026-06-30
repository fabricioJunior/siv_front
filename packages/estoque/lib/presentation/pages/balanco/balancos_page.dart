import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/presentation/bloc/balanco/balanco_bloc.dart';
import 'package:estoque/routes/estoque_routes.dart';
import 'package:core/bloc.dart';
import 'package:flutter/material.dart';

class BalancosPage extends StatefulWidget {
  const BalancosPage({super.key});

  @override
  State<BalancosPage> createState() => _BalancosPageState();
}

class _BalancosPageState extends State<BalancosPage> {
  int _currentPage = 1;
  String? _filtroSituacao;

  @override
  void initState() {
    super.initState();
    _carregarBalancos();
  }

  void _carregarBalancos() {
    context.read<BalancoBloc>().add(
      ListarBalancosEvent(
        situacao: _filtroSituacao,
        page: _currentPage,
        limit: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balanços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarBalancos,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _filtroSituacao == null,
                  onSelected: (_) {
                    setState(() { _filtroSituacao = null; _currentPage = 1; });
                    _carregarBalancos();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Em Andamento'),
                  selected: _filtroSituacao == 'em_andamento',
                  selectedColor: Colors.blue.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() { _filtroSituacao = 'em_andamento'; _currentPage = 1; });
                    _carregarBalancos();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Encerrado'),
                  selected: _filtroSituacao == 'encerrado',
                  selectedColor: Colors.green.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() { _filtroSituacao = 'encerrado'; _currentPage = 1; });
                    _carregarBalancos();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cancelado'),
                  selected: _filtroSituacao == 'cancelado',
                  selectedColor: Colors.red.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() { _filtroSituacao = 'cancelado'; _currentPage = 1; });
                    _carregarBalancos();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<BalancoBloc, BalancoState>(
              builder: (context, state) {
                if (state is BalancoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BalancoError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _carregarBalancos,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BalancoListLoaded) {
                  if (state.balancos.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum balanço encontrado',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tente alterar os filtros ou crie um novo balanço.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: state.balancos.length,
                    itemBuilder: (context, index) {
                      final balanco = state.balancos[index];
                      return BalancoCard(
                        balanco: balanco,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            EstoqueRoutes.detalhesBalanco,
                            arguments: {'balancoId': balanco.id},
                          );
                        },
                      );
                    },
                  );
                }

                return const Center(child: Text('Estado desconhecido'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo balanço',
        onPressed: () async {
          await Navigator.of(context).pushNamed(EstoqueRoutes.criarBalanco);
          _carregarBalancos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BalancoCard extends StatelessWidget {
  final Balanco balanco;
  final VoidCallback onTap;

  const BalancoCard({Key? key, required this.balanco, required this.onTap})
    : super(key: key);

  String _getSituacaoLabel() {
    switch (balanco.situacao) {
      case 'em_andamento':
        return 'Em Andamento';
      case 'encerrado':
        return 'Encerrado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return balanco.situacao;
    }
  }

  Color _getSituacaoCor() {
    switch (balanco.situacao) {
      case 'em_andamento':
        return Colors.blue;
      case 'encerrado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _getSituacaoCor();
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: cor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: cor.withOpacity(0.12),
                        child: Icon(Icons.inventory_2_outlined, color: cor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balanço #${balanco.id}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(balanco.data),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            if (balanco.observacao != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                balanco.observacao!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          _getSituacaoLabel(),
                          style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: cor.withOpacity(0.12),
                        side: BorderSide(color: cor.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        visualDensity: VisualDensity.compact,
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

  String _formatDateTime(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
