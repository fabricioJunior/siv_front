import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/domain/models/pessoa.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:core/presentation.dart';

// ignore: must_be_immutable
class PessoaPage extends StatelessWidget {
  final int? idPessoa;
  var formKey = GlobalKey<FormState>();
  PessoaPage({this.idPessoa, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoaBloc>(
      create: (_) => sl<PessoaBloc>()
        ..add(
          PessoaIniciou(
            idPessoa: idPessoa,
            tipoPessoa: TipoPessoa.fisica,
          ),
        ),
      child: Scaffold(
        floatingActionButton: BlocBuilder<PessoaBloc, PessoaState>(
          builder: (context, state) {
            if (state.dataDeNascimento == null) {
              return SizedBox();
            }
            if (state.pessoaStep == PessoaStep.carregando) {
              return CircularProgressIndicator();
            }
            return FloatingActionButton(
              child: Icon(
                state.pessoaStep == PessoaStep.editando
                    ? Icons.check
                    : Icons.edit,
              ),
              onPressed: () {
                if (state.pessoaStep != PessoaStep.editando) {
                  context.read<PessoaBloc>().add(PessoaEditou());
                } else if (formKey.currentState?.validate() ?? false) {
                  context.read<PessoaBloc>().add(PessoaSalvou());
                }
              },
            );
          },
        ),
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações principais',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        BlocBuilder<PessoaBloc, PessoaState>(
                            // buildWhen: (previous, current) =>
                            //     (previous.pessoaStep != PessoaStep.editando ||
                            //         previous.pessoa != null) ||
                            //     previous.eCliente != current.eCliente ||
                            //     previous.eFornecedor != current.eFornecedor ||
                            //     previous.eFuncionario != current.eFuncionario,
                            builder: (context, state) {
                          if (state.pessoaStep == PessoaStep.carregando) {
                            return CircularProgressIndicator();
                          }
                          if (state.pessoaStep == PessoaStep.editando ||
                              state.pessoaStep == PessoaStep.carregado ||
                              state.pessoaStep == PessoaStep.salva) {
                            return Opacity(
                              opacity: state.pessoaStep == PessoaStep.editando
                                  ? 1.0
                                  : 0.6,
                              child: _informacoesBasicas(
                                context,
                                state,
                                state.pessoaStep != PessoaStep.editando,
                              ),
                            );
                          }

                          return SizedBox();
                        })
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _informacoesBasicas(
    BuildContext context,
    PessoaState pessoaState,
    bool bloqueado,
  ) {
    Debouncer debouncer = Debouncer(milliseconds: 500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nome'),
        TextFormField(
          readOnly: bloqueado,
          key: const Key('nome_pessoa_text_field'),
          controller: TextEditingController.fromValue(
            pessoaState.nome == null
                ? null
                : TextEditingValue(text: pessoaState.nome!),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Informe um nome de usuário';
            }
            return null;
          },
          onChanged: (value) {
            debouncer.run(() {
              context.read<PessoaBloc>().add(PessoaEditou(nome: value));
            });
          },
        ),
        Text('CPF'),
        CPFInput(
          bloqueado: bloqueado,
          valorInicial: pessoaState.documento,
          onChanged: (value) {
            debouncer.run(
              () {
                context.read<PessoaBloc>().add(PessoaEditou(documento: value));
              },
            );
          },
        ),
        SizedBox(
          height: 16,
        ),
        Text('Data de nascimento'),
        DateInput(
          bloqueado: bloqueado,
          dataInicial: pessoaState.dataDeNascimento,
          onComplete: (value) {
            debouncer.run(
              () {
                context
                    .read<PessoaBloc>()
                    .add(PessoaEditou(dataDeNascimento: value));
              },
            );
          },
        ),
        Text('Telefone para contato'),
        CelularInput(
          bloqueado: bloqueado,
          valorInicial: pessoaState.contato,
          onChanged: (value) {
            debouncer.run(
              () {
                context.read<PessoaBloc>().add(PessoaEditou(contato: value));
              },
            );
          },
        ),
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
                  title: Text('Cliente'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.cliente),
                ),
                ListTile(
                  title: Text('Funcionario'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.funcionario),
                ),
                ListTile(
                  title: Text('Fornecedor'),
                  leading: Radio<TipoPessoaSeletor>(
                    value: TipoPessoaSeletor.fornecedor,
                  ),
                ),
              ],
            ),
          ),
        )
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
