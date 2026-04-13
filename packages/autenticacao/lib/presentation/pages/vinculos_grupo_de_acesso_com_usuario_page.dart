import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/bloc/vinculos_grupo_de_acesso_usuario_bloc/vinculos_grupo_de_acesso_usuario_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';

class VinculosGrupoDeAcessoComUsuarioPage extends StatelessWidget {
  final int idUsuario;

  VinculosGrupoDeAcessoComUsuarioPage({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VinculosGrupoDeAcessoUsuarioBloc>()
        ..add(VinculosGrupoDeAcessoIniciou(idUsuario: idUsuario)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupos de Acesso do Usuário'),
        ),
        floatingActionButton: BlocBuilder<VinculosGrupoDeAcessoUsuarioBloc,
            VinculosGrupoDeAcessoUsuarioState>(
          builder: (context, state) {
            if (state is VinculosGrupoDeAcessoUsuarioCarregarSucesso ||
                state is VinculosGrupoDeAcessoUsuarioVincularSucesso ||
                state is VinculosGrupoDeAcessoUsuarioDesvincularSucesso) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  _onAdionouNovoVinculo(context, state.empresas);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        body: SafeArea(
          child: BlocBuilder<VinculosGrupoDeAcessoUsuarioBloc,
              VinculosGrupoDeAcessoUsuarioState>(
            builder: (context, state) {
              final theme = Theme.of(context);

              if (state is VinculosGrupoDeAcessoUsuarioCarregarEmProgresso ||
                  state is VinculosGrupoDeAcessoUsuarioVincularEmProgresso ||
                  state is VinculosGrupoDeAcessoUsuarioDesvincularEmProgresso) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is VinculosGrupoDeAcessoUsuarioCarregarFalha) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Falha ao carregar vínculos.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state.vinculos.isEmpty) {
                return _emptyState(context);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                itemCount: state.vinculos.length + 1,
                separatorBuilder: (_, index) {
                  if (index == 0) {
                    return const SizedBox(height: 12);
                  }
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      'Vínculos cadastrados',
                      style: theme.textTheme.titleMedium,
                    );
                  }

                  final vinculo = state.vinculos[index - 1];
                  return _vinculoCard(context, vinculo);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link_off,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum vínculo cadastrado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para vincular um grupo de acesso ao usuário.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _vinculoCard(
    BuildContext context,
    VinculoGrupoDeAcessoEUsuario vinculo,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(vinculo.grupoDeAcesso?.nome ?? 'Grupo não informado'),
        subtitle: Text(vinculo.empresa?.nome ?? 'Empresa não informada'),
        trailing: IconButton(
          tooltip: 'Excluir vínculo',
          onPressed: () {
            context.read<VinculosGrupoDeAcessoUsuarioBloc>().add(
                  VinculosGrupoDeAcessoDesvinculou(
                    idGrupoDeAcesso: vinculo.grupoDeAcesso!.id!,
                    idEmpresa: vinculo.idEmpresa!,
                  ),
                );
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  void _onAdionouNovoVinculo(
    BuildContext context,
    List<Empresa> empresas,
  ) async {
    final bloc = BlocProvider.of<VinculosGrupoDeAcessoUsuarioBloc>(context);
    Empresa? empresa = await _EmpresasModal.show(context, empresas);

    if (empresa == null) {
      return;
    }
    GrupoDeAcesso? grupoDeAcesso = await _GruposDeAcessoModal.show(context);

    if (grupoDeAcesso == null) {
      return;
    }
    bloc.add(VinculosGrupoDeAcessoVinculou(
      idEmpresa: empresa.id,
      idGrupoDeAcesso: grupoDeAcesso.id!,
    ));
  }
}

class _EmpresasModal extends StatelessWidget {
  final List<Empresa> empresas;

  static Future<Empresa?> show(
      BuildContext context, List<Empresa> empresas) async {
    if (empresas.length == 1) {
      return empresas.first;
    }
    return showModalBottomSheet<Empresa>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _EmpresasModal(empresas: empresas),
    );
  }

  const _EmpresasModal({required this.empresas});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Selecione a empresa para o vínculo:'),
        Expanded(
            child: ListView.builder(
          itemCount: empresas.length,
          itemBuilder: (context, index) {
            var empresa = empresas[index];
            return ListTile(
              title: Text(empresa.nome),
              onTap: () {
                Navigator.of(context).pop(empresa);
              },
            );
          },
        )),
      ],
    );
  }
}

class _GruposDeAcessoModal extends StatelessWidget {
  static Future<GrupoDeAcesso?> show(
    BuildContext context,
  ) async {
    return showModalBottomSheet<GrupoDeAcesso?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _GruposDeAcessoModal(),
    );
  }

  const _GruposDeAcessoModal();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<GruposDeAcessoBloc>(
      create: (context) =>
          sl<GruposDeAcessoBloc>()..add(GruposDeAcessoIniciouEvent()),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Selecione o grupo de acesso',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case const (GruposDeAcessoCarregarEmProgresso):
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    case const (GruposDeAcessoCarregarError):
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Falha ao carregar grupos de acesso.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      );
                  }
                  if (state is GruposDeAcessoCarregarSucesso) {
                    if (state.grupos.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Nenhum grupo de acesso cadastrado.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.grupos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        var grupo = state.grupos[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.group_work_outlined,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(grupo.nome),
                            subtitle: Text('ID: ${grupo.id}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).pop(grupo);
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
