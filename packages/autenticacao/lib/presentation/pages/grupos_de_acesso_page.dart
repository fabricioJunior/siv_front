import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';

class GruposDeAcessoPage extends StatelessWidget {
  const GruposDeAcessoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<GruposDeAcessoBloc>()..add(const GruposDeAcessoIniciouEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupos de Acesso'),
        ),
        body: BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
          builder: (context, state) {
            if (state is GruposDeAcessoCarregarEmProgresso) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GruposDeAcessoCarregarSucesso) {
              final grupos = state.grupos;
              return ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupo = grupos[index];
                  return _grupoDeAcessoCard(context, grupo);
                },
              );
            } else if (state is GruposDeAcessoCarregarError) {
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
                child: Text('Nenhum grupo de acesso disponível.'),
              );
            }
          },
        ),
        floatingActionButton:
            BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/grupo_de_acesso');
                // ignore: use_build_context_synchronously
                context
                    .read<GruposDeAcessoBloc>()
                    .add(const GruposDeAcessoIniciouEvent());
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _grupoDeAcessoCard(BuildContext context, GrupoDeAcesso grupo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(grupo.nome),
        subtitle: Text('ID: ${grupo.id}'),
        trailing: const Icon(Icons.edit),
        onTap: () async {
          await Navigator.pushNamed(context, '/grupo_de_acesso', arguments: {
            'idGrupoDeAcesso': grupo.id,
          });
          // ignore: use_build_context_synchronously
          context
              .read<GruposDeAcessoBloc>()
              .add(const GruposDeAcessoIniciouEvent());
        },
      ),
    );
  }
}
