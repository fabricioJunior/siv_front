import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';

class CuponsPage extends StatelessWidget {
  final bloc = sl<CuponsBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  CuponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CuponsBloc>(
      create: (context) => bloc..add(CuponsIniciou()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cupons')),
        floatingActionButton: BlocBuilder<CuponsBloc, CuponsState>(
          builder: (context, state) {
            final carregando = state is CuponsCarregarEmProgresso;

            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () async {
                      final result = await Navigator.of(
                        context,
                      ).pushNamed('/cupom/form');

                      if (result == true) {
                        // ignore: use_build_context_synchronously
                        context.read<CuponsBloc>().add(CuponsIniciou());
                      }
                    },
              child: carregando
                  ? const CircularProgressIndicator.adaptive()
                  : const Icon(Icons.add),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SearchBar(
                  hintText: 'Buscar por código',
                  onChanged: (value) {
                    debouncer.run(() {
                      bloc.add(CuponsIniciou(busca: value));
                    });
                  },
                  onSubmitted: (value) {
                    bloc.add(CuponsIniciou(busca: value));
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<CuponsBloc, CuponsState>(
                  builder: (context, state) {
                    if (state is CuponsCarregarEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is CuponsCarregarFalha) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Falha ao carregar cupons.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final itens = state.cupons;
                    if (itens.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nenhum cupom cadastrado.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: itens.length,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return _CupomCard(item: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupomCard extends StatelessWidget {
  final Cupom item;

  const _CupomCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              item.ativa ? Colors.green.shade100 : Colors.grey.shade300,
          child: Icon(
            Icons.confirmation_number_outlined,
            color: item.ativa ? Colors.green.shade700 : Colors.grey.shade700,
          ),
        ),
        title: Text(
          item.codigo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_descricaoDesconto(item)),
            Text(
                '${_formatarData(item.dataInicio)} a ${_formatarData(item.dataFim)}'),
            Text(
              'Usos: ${item.usosRealizados}${item.limiteUsos != null ? '/${item.limiteUsos}' : ''}',
            ),
            const SizedBox(height: 4),
            Text(
              item.ativa ? 'Ativo' : 'Inativo',
              style: TextStyle(color: item.ativa ? Colors.green : Colors.grey),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            '/cupom/form',
            arguments: {'idCupom': item.id},
          );

          if (result == true && context.mounted) {
            context.read<CuponsBloc>().add(CuponsIniciou());
          }
        },
      ),
    );
  }

  String _descricaoDesconto(Cupom item) {
    switch (item.tipoDesconto) {
      case TipoDesconto.percentual:
        return '${item.valorPercentual ?? 0}% de desconto';
      case TipoDesconto.valorFixo:
        return 'R\$ ${item.valorFixo ?? 0} de desconto';
      case TipoDesconto.precoFixo:
        return 'Preço fixo de R\$ ${item.precoFixo ?? 0}';
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}
