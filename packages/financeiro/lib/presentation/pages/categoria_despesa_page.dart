import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class CategoriaDespesaPage extends StatefulWidget {
  final int? id;

  const CategoriaDespesaPage({super.key, this.id});

  @override
  State<CategoriaDespesaPage> createState() => _CategoriaDespesaPageState();
}

class _CategoriaDespesaPageState extends State<CategoriaDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

    return BlocProvider<CategoriaDespesaBloc>(
      create: (_) => sl<CategoriaDespesaBloc>()
        ..add(CategoriaDespesaIniciou(empresaId: empresaId, id: widget.id)),
      child: BlocListener<CategoriaDespesaBloc, CategoriaDespesaState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == CategoriaDespesaStep.validacaoInvalida ||
              state.step == CategoriaDespesaStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro ?? 'Falha ao salvar categoria.'),
              ),
            );
          }
          if (state.step == CategoriaDespesaStep.criado ||
              state.step == CategoriaDespesaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.id == null ? 'Nova categoria' : 'Editar categoria'),
          ),
          floatingActionButton:
              BlocBuilder<CategoriaDespesaBloc, CategoriaDespesaState>(
            builder: (context, state) {
              final salvando = state.step == CategoriaDespesaStep.salvando ||
                  state.step == CategoriaDespesaStep.carregando;
              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context
                              .read<CategoriaDespesaBloc>()
                              .add(CategoriaDespesaSalvou());
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<CategoriaDespesaBloc, CategoriaDespesaState>(
            builder: (context, state) {
              if (state.step == CategoriaDespesaStep.carregando) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              final nome = state.nome ?? '';
              if (_nomeController.text != nome) {
                _nomeController.value = TextEditingValue(
                  text: nome,
                  selection: TextSelection.collapsed(offset: nome.length),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Informe o nome'
                              : null,
                          onChanged: (value) => context
                              .read<CategoriaDespesaBloc>()
                              .add(CategoriaDespesaCampoAlterado(nome: value)),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Inativa'),
                          value: state.inativa ?? false,
                          onChanged: (value) => context
                              .read<CategoriaDespesaBloc>()
                              .add(CategoriaDespesaCampoAlterado(inativa: value)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
