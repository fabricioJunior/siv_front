import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

class PessoasPage extends StatelessWidget {
  var bloc = sl<PessoasBloc>();
  var debouncer = Debouncer(milliseconds: 400);
  PessoasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoasBloc>(
      create: (context) => bloc..add(PessoasIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<PessoasBloc, PessoasState>(
          builder: (context, state) {
            if (state is PessoasCarregarEmProgresso) {
              return CircularProgressIndicator();
            }

            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context).pushNamed('/pessoa');

                // ignore: use_build_context_synchronously
                context.read<PessoasBloc>().add(PessoasIniciou());
              },
            );
          },
        ),
        appBar: AppBar(
          title: Text('Pessoas'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SearchBar(
                autoFocus: true,
                hintText: 'Digite o nome ou documento',
                onChanged: (value) {
                  debouncer.run(() {
                    bloc.add(PessoasIniciou(busca: value));
                  });
                },
                onSubmitted: (value) {
                  bloc.add(PessoasIniciou(busca: value));
                },
              ),
            ),
            SizedBox(height: 16),
            BlocBuilder<PessoasBloc, PessoasState>(builder: (context, state) {
              switch (state.runtimeType) {
                case const (PessoasCarregarEmProgresso):
                  return _load();
                case const (PessoasCarregarSucesso):
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.pessoas.length,
                    itemBuilder: (context, index) {
                      var pessoa = state.pessoas[index];
                      return _pessoaCard(context, pessoa);
                    },
                  );
                default:
                  return SizedBox();
              }
            })
          ],
        ),
      ),
    );
  }

  Widget _pessoaCard(BuildContext context, Pessoa pessoa) => ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/pessoa',
            arguments: {
              'idPessoa': pessoa.id,
            },
          );
        },
        title: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${pessoa.nome} - ${pessoa.documento}'),
          ),
        ),
      );

  Widget _load() => Column(
        children: [
          CircularProgressIndicator.adaptive(),
        ],
      );
}
