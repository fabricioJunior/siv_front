import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class CategoriasDespesaPage extends StatelessWidget {
  final bloc = sl<CategoriasDespesaBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  CategoriasDespesaPage({super.key});

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriasDespesaBloc>(
      create: (context) =>
          bloc..add(CategoriasDespesaIniciou(empresaId: _empresaId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Categorias de despesa')),
        floatingActionButton:
            BlocBuilder<CategoriasDespesaBloc, CategoriasDespesaState>(
          builder: (context, state) {
            final carregando = state is CategoriasDespesaCarregarEmProgresso;
            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () async {
                      final result = await Navigator.of(context)
                          .pushNamed('/categoria_despesa');
                      if (result == true) {
                        // ignore: use_build_context_synchronously
                        context.read<CategoriasDespesaBloc>().add(
                              CategoriasDespesaIniciou(empresaId: _empresaId),
                            );
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
                  hintText: 'Buscar por nome',
                  onChanged: (value) {
                    debouncer.run(() {
                      bloc.add(
                        CategoriasDespesaIniciou(
                          empresaId: _empresaId,
                          busca: value,
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<CategoriasDespesaBloc, CategoriasDespesaState>(
                  builder: (context, state) {
                    if (state is CategoriasDespesaCarregarEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is CategoriasDespesaCarregarFalha) {
                      return const Center(
                        child: Text('Falha ao carregar categorias.'),
                      );
                    }

                    if (state.categorias.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma categoria cadastrada.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.categorias.length,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemBuilder: (context, index) {
                        final categoria = state.categorias[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(categoria.nome),
                            subtitle: Text(
                              categoria.inativa ? 'Inativa' : 'Ativa',
                              style: TextStyle(
                                color: categoria.inativa
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .pushNamed(
                                '/categoria_despesa',
                                arguments: {'id': categoria.id},
                              );
                              if (result == true && context.mounted) {
                                context.read<CategoriasDespesaBloc>().add(
                                      CategoriasDespesaIniciou(
                                        empresaId: _empresaId,
                                      ),
                                    );
                              }
                            },
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
      ),
    );
  }
}
