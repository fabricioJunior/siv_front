import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/domain/models/pessoa.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

class SelecionarPessoaPage extends StatefulWidget {
  final bool retornarSomenteId;

  const SelecionarPessoaPage({
    super.key,
    this.retornarSomenteId = false,
  });

  @override
  State<SelecionarPessoaPage> createState() => _SelecionarPessoaPageState();
}

class _SelecionarPessoaPageState extends State<SelecionarPessoaPage> {
  late final PessoasBloc _bloc;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PessoasBloc>();
    _debouncer = Debouncer(milliseconds: 350);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoasBloc>(
      create: (_) => _bloc..add(PessoasIniciou()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecionar pessoa'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                hintText: 'Buscar por nome ou documento',
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  _debouncer.run(() {
                    _bloc.add(PessoasIniciou(busca: value));
                  });
                },
                onSubmitted: (value) {
                  _bloc.add(PessoasIniciou(busca: value));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<PessoasBloc, PessoasState>(
                builder: (context, state) {
                  if (state is PessoasCarregarEmProgresso ||
                      state is PessoasInitial) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state is PessoasCarregarFalha) {
                    return const Center(
                      child: Text('Falha ao carregar pessoas.'),
                    );
                  }

                  final pessoas = state.pessoas;
                  if (pessoas.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma pessoa encontrada.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    itemCount: pessoas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pessoa = pessoas[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _selecionarPessoa(context, pessoa),
                          title: Text(pessoa.nome),
                          subtitle: Text(pessoa.documento),
                          trailing: const Icon(Icons.chevron_right),
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

  void _selecionarPessoa(BuildContext context, Pessoa pessoa) {
    final id = pessoa.id?.toString() ?? '';
    if (widget.retornarSomenteId) {
      Navigator.of(context).pop(<String, String>{'id': id});
      return;
    }

    Navigator.of(context).pop(
      <String, String>{
        'id': id,
        'nome': pessoa.nome,
        'documento': pessoa.documento,
        'email': pessoa.email ?? '',
        'telefone': pessoa.contato ?? '',
      },
    );
  }
}
