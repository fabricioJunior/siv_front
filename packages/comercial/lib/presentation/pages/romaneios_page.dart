import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class RomaneiosPage extends StatelessWidget {
  const RomaneiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneiosBloc>(
      create: (_) => sl<RomaneiosBloc>()..add(RomaneiosIniciou()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Romaneios')),
            floatingActionButton: BlocBuilder<RomaneiosBloc, RomaneiosState>(
              builder: (context, state) {
                final carregando = state.step == RomaneiosStep.carregando;
                return FloatingActionButton(
                  onPressed: carregando
                      ? null
                      : () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/romaneio',
                          );
                          if (result == true && context.mounted) {
                            context
                                .read<RomaneiosBloc>()
                                .add(RomaneiosIniciou());
                          }
                        },
                  child: const Icon(Icons.add),
                );
              },
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<RomaneiosBloc>().add(RomaneiosIniciou());
              },
              child: BlocBuilder<RomaneiosBloc, RomaneiosState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (state.step == RomaneiosStep.carregando)
                        const Center(
                            child: CircularProgressIndicator.adaptive())
                      else if (state.step == RomaneiosStep.falha)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            state.erro ?? 'Falha ao carregar romaneios.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (state.romaneios.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum romaneio encontrado.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...state.romaneios.map((romaneio) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text('Romaneio #${romaneio.id ?? '-'}'),
                              subtitle: Text(
                                'Pessoa: ${romaneio.pessoaNome ?? romaneio.pessoaId ?? '-'}\nOperacao: ${romaneio.operacao?.descricao ?? '-'} | Situacao: ${romaneio.situacao ?? '-'}',
                              ),
                              onTap: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/romaneio',
                                  arguments: {
                                    'idRomaneio': romaneio.id,
                                    'permitirEdicao': false,
                                  },
                                );
                                if (result == true && context.mounted) {
                                  context.read<RomaneiosBloc>().add(
                                        RomaneiosIniciou(),
                                      );
                                }
                              },
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
