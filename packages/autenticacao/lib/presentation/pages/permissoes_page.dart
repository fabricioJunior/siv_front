import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/presentation/bloc/permissoes_bloc/permissoes_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class PermissoesPage extends StatelessWidget {
  const PermissoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PermissoesBloc>(
      create: (context) => sl<PermissoesBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Permissões'),
        ),
        body: BlocBuilder<PermissoesBloc, PermissoesState>(
          buildWhen: (previous, current) =>
              current is PermissoesCarregarEmProgesso ||
              current is PermissoesCarregarSucesso ||
              current is PermissoesCarregarFalha,
          builder: (context, state) {
            if (state is PermissoesCarregarEmProgesso) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PermissoesCarregarSucesso) {
              final permissoes = state.permissoes;
              return ListView.builder(
                itemCount: permissoes.length,
                itemBuilder: (context, index) {
                  final permissao = permissoes[index];
                  return _permissaoCard(context, permissao);
                },
              );
            } else if (state is PermissoesCarregarFalha) {
              return Center(
                child: Text(
                  state.mensagem,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.red,
                      ),
                ),
              );
            } else {
              return const Center(
                child: Text('Nenhuma permissão disponível.'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _permissaoCard(BuildContext context, Permissao permissao) {
    return Container(
      color:
          permissao.descontinuado ? Colors.red.shade100 : Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _checkBox(permissao),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${permissao.id}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nome: ${permissao.nome}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  permissao.descontinuado
                      ? 'Status: Descontinuado'
                      : 'Status: Ativo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            permissao.descontinuado ? Colors.red : Colors.green,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<PermissoesBloc, PermissoesState> _checkBox(Permissao permissao) {
    return BlocBuilder<PermissoesBloc, PermissoesState>(
      builder: (context, state) {
        var selecionado = state is PermissoesSelecionarSucesso &&
            state.permissoesSelecionadas.contains(permissao);
        return Checkbox(
          value: selecionado,
          onChanged: (value) {
            if (value == true) {
              context
                  .read<PermissoesBloc>()
                  .add(PermissoesSelecionou(permissao: permissao));
            } else {
              context
                  .read<PermissoesBloc>()
                  .add(PermissoesDesselecionou(permissao: permissao));
            }
          },
        );
      },
    );
  }
}
