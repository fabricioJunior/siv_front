import 'package:brasil_fields/brasil_fields.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../blocs/empresa_bloc/empresa_bloc.dart';

class EmpresaPage extends StatelessWidget {
  final int? idEmpresa;
  final formKey = GlobalKey<FormState>();

  EmpresaPage({this.idEmpresa, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresaBloc>(
      create: (context) =>
          sl<EmpresaBloc>()..add(EmpresaIniciou(idEmpresa: idEmpresa)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(idEmpresa == null ? 'Nova empresa' : 'Empresa'),
        ),
        floatingActionButton: _floatActionButton(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueGrey.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<EmpresaBloc, EmpresaState>(
              buildWhen: (previous, current) =>
                  previous is! EmpresaEditarEmProgresso,
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (EmpresaCarregarEmProgresso):
                  case const (EmpresaSalvarEmProgresso):
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  case const (EmpresaEditarEmProgresso):
                  case const (EmpresaSalvarSucesso):
                  case const (EmpresaCarregarSucesso):
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(
                            context,
                            state.empresa,
                            state is! EmpresaEditarEmProgresso,
                          ),
                          const SizedBox(height: 16),
                          _configuracoesButton(context, state.empresa?.id ?? 0),
                          const SizedBox(height: 16),
                          _empresaInfos(
                            context,
                            state.empresa,
                            state is! EmpresaEditarEmProgresso,
                          ),
                        ],
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    Empresa? empresa,
    bool readOnly,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final nome = empresa?.nome.isNotEmpty == true
        ? empresa!.nome
        : 'Nova empresa';
    final fantasia = empresa?.nomeFantasia.isNotEmpty == true
        ? empresa!.nomeFantasia
        : 'Preencha os dados para concluir o cadastro';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.95),
            colorScheme.primaryContainer.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fantasia,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  readOnly ? 'Visualização' : 'Edição',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.badge_outlined,
                label: 'Código',
                value: empresa?.id?.toString() ?? 'Novo',
              ),
              _buildInfoChip(
                icon: Icons.receipt_long_outlined,
                label: 'CNPJ',
                value: empresa?.cnpj.isNotEmpty == true
                    ? empresa!.cnpj
                    : 'Não informado',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _configuracoesButton(BuildContext context, int empresaId) {
    final habilitado = empresaId > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações rápidas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              habilitado
                  ? 'Gerencie recursos vinculados a esta empresa.'
                  : 'Salve a empresa para liberar terminais e configurações.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: !habilitado
                      ? null
                      : () {
                          Navigator.of(context).pushNamed(
                            '/terminais',
                            arguments: {'empresaId': empresaId},
                          );
                        },
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Terminais'),
                ),
                OutlinedButton.icon(
                  onPressed: !habilitado
                      ? null
                      : () {
                          Navigator.of(context).pushNamed(
                            '/parametros_empresa',
                            arguments: {'empresaId': empresaId},
                          );
                        },
                  icon: const Icon(Icons.settings),
                  label: const Text('Configurações'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _empresaInfos(BuildContext context, Empresa? empresa, bool readOnly) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final duasColunas = constraints.maxWidth > 900;

          final principal = _buildSectionCard(
            context,
            icon: Icons.apartment_rounded,
            title: 'Dados principais',
            subtitle: 'Informações essenciais da empresa.',
            child: Column(
              children: [
                _buildTextField(
                  context,
                  label: 'Nome',
                  icon: Icons.business,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.nome ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um nome da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(EmpresaEditou(nome: value));
                  },
                  fieldKey: const Key('nome_empresa_text_field'),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context,
                  label: 'Código da empresa',
                  icon: Icons.tag,
                  readOnly: readOnly || empresa?.id != null,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.id?.toString() ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um código para a empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<EmpresaBloc>().add(
                        EmpresaEditou(id: int.parse(value)),
                      );
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  keyboardType: TextInputType.number,
                  fieldKey: const Key('codigo_da_empresa_text_field'),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context,
                  label: 'Nome fantasia',
                  icon: Icons.store_mall_directory_outlined,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.nomeFantasia ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um nome fantasia da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(
                      EmpresaEditou(nomeFantasia: value),
                    );
                  },
                  fieldKey: const Key('nome_fantasia_empresa'),
                ),
              ],
            ),
          );

          final contato = _buildSectionCard(
            context,
            icon: Icons.contact_phone_outlined,
            title: 'Contato e fiscal',
            subtitle: 'Dados de comunicação e documentação.',
            child: Column(
              children: [
                _buildTextField(
                  context,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.email ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um email da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(
                      EmpresaEditou(email: value),
                    );
                  },
                  keyboardType: TextInputType.emailAddress,
                  fieldKey: const Key('email_empresa'),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context,
                  label: 'Telefone',
                  icon: Icons.phone_outlined,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.telefone ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um telefone da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(
                      EmpresaEditou(telefone: value),
                    );
                  },
                  keyboardType: TextInputType.phone,
                  fieldKey: const Key('telefone_empresa'),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context,
                  label: 'CNPJ',
                  icon: Icons.receipt_long_outlined,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.cnpj ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o CNPJ da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(EmpresaEditou(cnpj: value));
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CnpjInputFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  fieldKey: const Key('cnpj_empresa'),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  context,
                  label: 'Registro municipal',
                  icon: Icons.assignment_outlined,
                  readOnly: readOnly,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: empresa?.registroMunicipal ?? ''),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o registro municipal da empresa';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<EmpresaBloc>().add(
                      EmpresaEditou(registroMunicipal: value),
                    );
                  },
                  fieldKey: const Key('registro_municipal_empresa'),
                ),
              ],
            ),
          );

          if (duasColunas) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: principal),
                const SizedBox(width: 16),
                Expanded(child: contato),
              ],
            );
          }

          return Column(
            children: [principal, const SizedBox(height: 16), contato],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(icon, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool readOnly,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Key? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: fieldKey,
          readOnly: readOnly,
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _floatActionButton() => BlocBuilder<EmpresaBloc, EmpresaState>(
    builder: (context, state) {
      if (state is EmpresaCarregarEmProgresso) {
        return const SizedBox.shrink();
      }

      if (state is EmpresaSalvarEmProgresso) {
        return const FloatingActionButton.extended(
          tooltip: 'Salvando',
          onPressed: null,
          icon: CircularProgressIndicator.adaptive(),
          label: Text('Salvando'),
        );
      }

      final editando = state is EmpresaEditarEmProgresso;

      return FloatingActionButton.extended(
        tooltip: editando ? 'Salvar' : 'Editar',
        onPressed: () {
          if (!editando) {
            context.read<EmpresaBloc>().add(EmpresaEditou());
          } else if (formKey.currentState!.validate()) {
            context.read<EmpresaBloc>().add(EmpresaSalvou());
          }
        },
        icon: Icon(editando ? Icons.check : Icons.edit),
        label: Text(editando ? 'Salvar' : 'Editar'),
      );
    },
  );
}
