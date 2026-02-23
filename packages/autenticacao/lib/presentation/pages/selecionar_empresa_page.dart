import 'package:autenticacao/domain/models/empresa.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class SelecionarEmpresaPage extends StatelessWidget {
  final bloc = sl<LoginBloc>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Selecionar empresa'),
      ),
      body: SafeArea(
        child: BlocBuilder<LoginBloc, LoginState>(
          bloc: bloc,
          builder: (context, state) {
            if (state is LoginAutenticarEmProgresso ||
                state is LoginCarregarEmpresasEmProgresso) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            final empresas = state.empresas ?? [];

            if (empresas.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nenhuma empresa disponível para seleção.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        key: const Key('selecionar_empresa_cadastrar_button'),
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/empresa');
                          bloc.add(LoginCarregouEmpresas());
                        },
                        icon: const Icon(Icons.add_business_outlined),
                        label: const Text('Cadastrar empresa'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              itemCount: empresas.length + 1,
              separatorBuilder: (_, index) {
                if (index == 0) {
                  return const SizedBox(height: 12);
                }
                return const SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    'Escolha a empresa para continuar',
                    style: theme.textTheme.titleMedium,
                  );
                }

                final empresa = empresas[index - 1];
                return _empresaCard(context, empresa);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _empresaCard(BuildContext context, Empresa empresa) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          bloc.add(
            LoginAutenticou(empresa: empresa),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                Icons.business_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  empresa.nome,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
