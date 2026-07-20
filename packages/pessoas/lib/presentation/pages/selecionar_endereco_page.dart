import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/domain/models/endereco.dart';
import 'package:pessoas/presentation/bloc/endereco_cadastro_bloc/endereco_cadastro_bloc.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/pages/endereco_cadastro_page.dart';

class SelecionarEnderecoPage extends StatelessWidget {
  final int idPessoa;
  final String? titulo;

  const SelecionarEnderecoPage({
    super.key,
    required this.idPessoa,
    this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EnderecosBloc>(
      create: (_) =>
          sl<EnderecosBloc>()..add(EnderecosIniciou(idPessoa: idPessoa)),
      child: Scaffold(
        appBar: AppBar(title: Text(titulo ?? 'Selecionar endereço')),
        floatingActionButton: BlocBuilder<EnderecosBloc, EnderecosState>(
          builder: (context, state) {
            final carregando = state is EnderecosCarregarEmProgresso ||
                state is EnderecosCriarEmProgresso ||
                state is EnderecosSalvarEmProgresso ||
                state is EnderecosExcluirEmProgresso;

            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<EnderecosBloc>(),
                              ),
                              BlocProvider(
                                create: (_) => sl<EnderecoCadastroBloc>(),
                              ),
                            ],
                            child: EnderecoCadastroPage(idPessoa: idPessoa),
                          ),
                        ),
                      );
                    },
              child: carregando
                  ? const CircularProgressIndicator.adaptive()
                  : const Icon(Icons.add),
            );
          },
        ),
        body: SafeArea(
          child: BlocBuilder<EnderecosBloc, EnderecosState>(
            builder: (context, state) {
              if (state is EnderecosCarregarEmProgresso ||
                  state is EnderecosInicial) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state is EnderecosCarregarFalha) {
                return const Center(
                  child: Text('Falha ao carregar endereços.'),
                );
              }

              if (state.enderecos.isEmpty) {
                return const Center(
                  child: Text('Cliente não possui endereço cadastrado.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.enderecos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final endereco = state.enderecos[index];
                  return Card(
                    child: ListTile(
                      onTap: () => Navigator.of(context)
                          .pop(_mapearEndereco(endereco)),
                      title: Text('${endereco.logradouro}, ${endereco.numero}'),
                      subtitle: Text(
                        '${endereco.bairro} · ${endereco.municipio}/${endereco.uf}\nCEP: ${endereco.cep}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, String> _mapearEndereco(Endereco endereco) {
    return <String, String>{
      'id': endereco.id?.toString() ?? '',
      'logradouro': endereco.logradouro,
      'numero': endereco.numero,
      'complemento': endereco.complemento,
      'bairro': endereco.bairro,
      'municipio': endereco.municipio,
      'uf': endereco.uf,
      'cep': endereco.cep,
    };
  }
}
