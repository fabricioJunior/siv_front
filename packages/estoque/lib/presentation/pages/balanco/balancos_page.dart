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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtros',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: _filtroSituacao,
                      decoration: const InputDecoration(
                        labelText: 'Situação',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'em_andamento',
                          child: Text('Em Andamento'),
                        ),
                        DropdownMenuItem(
                          value: 'encerrado',
                          child: Text('Encerrado'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelado',
                          child: Text('Cancelado'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroSituacao = value;
                          _currentPage = 1;
                        });
                        _carregarBalancos();
                      },
                    ),
                  ],
                ),
              ),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getSituacaoCor().withOpacity(0.15),
          child: Icon(Icons.inventory_2_outlined, color: _getSituacaoCor()),
        ),
        title: Text('Balanço #${balanco.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Data: ${_formatDateTime(balanco.data)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (balanco.observacao != null)
              Text(
                'Observação: ${balanco.observacao}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Chip(
          label: Text(_getSituacaoLabel()),
          backgroundColor: _getSituacaoCor().withOpacity(0.2),
          labelStyle: TextStyle(color: _getSituacaoCor()),
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
