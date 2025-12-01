import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

import '../blocs/empresa_bloc/empresa_bloc.dart';

class EmpresaPage extends StatelessWidget {
  final int? idEmpresa;

  final formKey = GlobalKey<FormState>();
  EmpresaPage({this.idEmpresa, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresaBloc>(
      create: (context) => sl<EmpresaBloc>()
        ..add(
          EmpresaIniciou(idEmpresa: idEmpresa),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Empresa'),
        ),
        floatingActionButton: _floatActionButton(),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<EmpresaBloc, EmpresaState>(
                  buildWhen: (previous, current) =>
                      previous is! EmpresaEditarEmProgresso,
                  builder: (context, state) {
                    switch (state.runtimeType) {
                      case const (EmpresaCarregarEmProgresso):
                      case const (EmpresaSalvarEmProgresso):
                        return CircularProgressIndicator.adaptive();
                      case const (EmpresaEditarEmProgresso):
                      case const (EmpresaSalvarSucesso):
                      case const (EmpresaCarregarSucesso):
                        return _empresaInfos(
                          context,
                          state.empresa,
                          state is! EmpresaEditarEmProgresso,
                        );
                      default:
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _empresaInfos(
    BuildContext context,
    Empresa? empresa,
    bool readOnly,
  ) =>
      Card(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('nome_empresa_text_field'),
                  controller: TextEditingController.fromValue(
                    empresa == null
                        ? null
                        : TextEditingValue(text: empresa.nome),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um nome da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(EmpresaEditou(nome: value));
                  },
                ),
                const Text('Codigo da empresa'),
                TextFormField(
                  readOnly: readOnly || empresa?.id != null,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  key: const Key('codigo_da_empresa_text_field'),
                  controller: TextEditingController.fromValue(
                    empresa == null
                        ? null
                        : TextEditingValue(text: empresa.id?.toString() ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um codigo para a empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context
                          .read<EmpresaBloc>()
                          .add(EmpresaEditou(id: int.parse(value)));
                    }
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text('Nome fantasia'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('nome_fantasia_empresa'),
                  controller: TextEditingController.fromValue(
                    empresa == null
                        ? null
                        : TextEditingValue(text: empresa.nomeFantasia),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um nome fantasia da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context
                        .read<EmpresaBloc>()
                        .add(EmpresaEditou(nomeFantasia: value));
                  },
                ),
                const Text('Email'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('email_empresa'),
                  controller: TextEditingController.fromValue(
                    empresa?.email == null
                        ? null
                        : TextEditingValue(text: empresa!.email!),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um  email da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context
                        .read<EmpresaBloc>()
                        .add(EmpresaEditou(email: value));
                  },
                ),
                const Text('Telefone'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('telefone_empresa'),
                  controller: TextEditingController.fromValue(
                    empresa?.telefone == null
                        ? null
                        : TextEditingValue(text: empresa!.telefone!),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um  telefone da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context
                        .read<EmpresaBloc>()
                        .add(EmpresaEditou(telefone: value));
                  },
                ),
                const Text('CNPJ'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('cnpj_empresa'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CnpjInputFormatter(),
                  ],
                  controller: TextEditingController.fromValue(
                    empresa?.cnpj == null
                        ? null
                        : TextEditingValue(text: empresa!.cnpj ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o CNPJ da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(EmpresaEditou(cnpj: value));
                  },
                ),
                const Text('Registro municipal'),
                TextFormField(
                  readOnly: readOnly,
                  key: const Key('registro_municipal_empresa'),
                  controller: TextEditingController.fromValue(
                    empresa?.registroMunicipal == null
                        ? null
                        : TextEditingValue(text: empresa!.registroMunicipal!),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o Registro municiapal da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context
                        .read<EmpresaBloc>()
                        .add(EmpresaEditou(registroMunicipal: value));
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget _floatActionButton() => BlocBuilder<EmpresaBloc, EmpresaState>(
        builder: (context, state) {
          if (state is EmpresaCarregarEmProgresso) {
            return const SizedBox();
          }
          if (state is EmpresaSalvarEmProgresso) {
            return const FloatingActionButton(
              tooltip: 'salvando',
              onPressed: null,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return FloatingActionButton(
            tooltip: 'Edição',
            onPressed: () {
              if (state is! EmpresaEditarEmProgresso) {
                context.read<EmpresaBloc>().add(EmpresaEditou());
              } else if (formKey.currentState!.validate()) {
                context.read<EmpresaBloc>().add(EmpresaSalvou());
              }
            },
            child: Icon(
              state is! EmpresaEditarEmProgresso ? Icons.edit : Icons.check,
            ),
          );
        },
      );
}
