import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';

class OrcamentosPage extends StatelessWidget {
  const OrcamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrcamentosBloc>(
      create: (_) =>
          sl<OrcamentosBloc>()..add(const OrcamentosCarregarSolicitado()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Orçamentos')),
        body: BlocBuilder<OrcamentosBloc, OrcamentosState>(
          builder: (context, state) {
            if (state.status == OrcamentosStatus.carregando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == OrcamentosStatus.erro) {
              return Center(
                child: Text(state.erro ?? 'Falha ao carregar os orçamentos.'),
              );
            }

            if (state.orcamentos.isEmpty) {
              return const Center(
                child: Text('Nenhum orçamento salvo.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.orcamentos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final orcamento = state.orcamentos[index];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).pop(orcamento.hash),
                    title: Text(
                      'Cliente: ${orcamento.clienteNome ?? '-'}',
                    ),
                    subtitle: Text(
                      'Vendedor: ${orcamento.funcionarioNome ?? '-'}\n'
                      'Data: ${_formatarData(orcamento.atualizadoEm)}  •  '
                      'Total: ${_formatarMoeda(orcamento.valorTotal)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Excluir orçamento',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmarExclusao(context, orcamento),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    OrcamentoLocal orcamento,
  ) async {
    final bloc = context.read<OrcamentosBloc>();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir orçamento'),
          content: const Text('Deseja realmente excluir este orçamento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      bloc.add(OrcamentoExcluirSolicitado(hash: orcamento.hash));
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} $hora:$minuto';
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
