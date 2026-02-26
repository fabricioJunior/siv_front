import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/domain/models/pessoa.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';

class PessoaPage extends StatelessWidget {
  final int? idPessoa;
  final formKey = GlobalKey<FormState>();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  PessoaPage({this.idPessoa, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<PessoaBloc>(
      create: (_) => sl<PessoaBloc>()
        ..add(
          PessoaIniciou(
            idPessoa: idPessoa,
            tipoPessoa: TipoPessoa.fisica,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(idPessoa == null ? 'Nova pessoa' : 'Pessoa #$idPessoa'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: BlocBuilder<PessoaBloc, PessoaState>(
          builder: (context, state) {
            if (state.dataDeNascimento == null ||
                state.pessoaStep == PessoaStep.carregando) {
              return const SizedBox.shrink();
            }

            final editando = state.pessoaStep == PessoaStep.editando;

            return FloatingActionButton.extended(
              icon: Icon(editando ? Icons.check : Icons.edit),
              label: Text(editando ? 'Salvar' : 'Editar'),
              onPressed: () {
                if (!editando) {
                  context.read<PessoaBloc>().add(PessoaEditou());
                } else if (formKey.currentState?.validate() ?? false) {
                  context.read<PessoaBloc>().add(PessoaSalvou());
                }
              },
            );
          },
        ),
        body: BlocBuilder<PessoaBloc, PessoaState>(
          builder: (context, state) {
            if (state.pessoaStep == PessoaStep.carregando) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth > 900 ? 24.0 : 12.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        96,
                      ),
                      child: Form(
                        key: formKey,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: theme.colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informações principais',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dados pessoais e vínculo da pessoa.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (idPessoa != null) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Wrap(
                                      spacing: 8,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              '/enderecos_page',
                                              arguments: {'idPessoa': idPessoa},
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.location_on_outlined,
                                          ),
                                          label: const Text('Endereços'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              '/pontos_page',
                                              arguments: {'idPessoa': idPessoa},
                                            );
                                          },
                                          icon:
                                              const Icon(Icons.stars_outlined),
                                          label: const Text('Pontos'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (state.pessoaStep == PessoaStep.editando ||
                                    state.pessoaStep == PessoaStep.carregado ||
                                    state.pessoaStep == PessoaStep.salva)
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 180),
                                    opacity:
                                        state.pessoaStep == PessoaStep.editando
                                            ? 1
                                            : 0.7,
                                    child: _informacoesBasicas(
                                      context,
                                      state,
                                      state.pessoaStep != PessoaStep.editando,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _informacoesBasicas(
    BuildContext context,
    PessoaState pessoaState,
    bool bloqueado,
  ) {
    final fieldSpacing = const SizedBox(height: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: bloqueado,
          key: const Key('nome_pessoa_text_field'),
          controller: TextEditingController.fromValue(
            pessoaState.nome == null
                ? null
                : TextEditingValue(text: pessoaState.nome!),
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Digite o nome completo',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Informe um nome de usuário';
            }
            return null;
          },
          onChanged: (value) {
            _debouncer.run(() {
              context.read<PessoaBloc>().add(PessoaEditou(nome: value));
            });
          },
        ),
        fieldSpacing,
        Text(
          'CPF',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        CPFInput(
          bloqueado: bloqueado,
          valorInicial: pessoaState.documento,
          onChanged: (value) {
            _debouncer.run(() {
              context.read<PessoaBloc>().add(PessoaEditou(documento: value));
            });
          },
        ),
        fieldSpacing,
        Text(
          'Data de nascimento',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        DateInput(
          bloqueado: bloqueado,
          dataInicial: pessoaState.dataDeNascimento,
          onComplete: (value) {
            _debouncer.run(() {
              context
                  .read<PessoaBloc>()
                  .add(PessoaEditou(dataDeNascimento: value));
            });
          },
        ),
        fieldSpacing,
        Text(
          'Telefone para contato',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        CelularInput(
          bloqueado: bloqueado,
          valorInicial: pessoaState.contato,
          onChanged: (value) {
            _debouncer.run(() {
              context.read<PessoaBloc>().add(PessoaEditou(contato: value));
            });
          },
        ),
        const SizedBox(height: 18),
        Text(
          'Tipo de vínculo',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        IgnorePointer(
          ignoring: bloqueado,
          child: RadioGroup<TipoPessoaSeletor>(
            groupValue: _valorInicial(pessoaState),
            onChanged: (value) {
              context.read<PessoaBloc>().add(
                    PessoaEditou(
                      eCliente: value == TipoPessoaSeletor.cliente,
                      eFornecedor: value == TipoPessoaSeletor.fornecedor,
                      eFuncionario: value == TipoPessoaSeletor.funcionario,
                    ),
                  );
            },
            child: const Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Cliente'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.cliente),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Funcionário'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.funcionario),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Fornecedor'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.fornecedor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TipoPessoaSeletor _valorInicial(PessoaState state) {
    if (state.eFornecedor ?? false) {
      return TipoPessoaSeletor.fornecedor;
    }
    if (state.eFuncionario ?? false) {
      return TipoPessoaSeletor.funcionario;
    }
    return TipoPessoaSeletor.cliente;
  }
}

enum TipoPessoaSeletor {
  fornecedor,
  cliente,
  funcionario,
}
