import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/grupo_de_acesso_bloc/grupo_de_acesso_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../bloc/permissoes_bloc/permissoes_bloc.dart';

class GrupoDeAcessoPage extends StatelessWidget {
  final int? idGrupoDeAcesso;

  final formKey = GlobalKey<FormState>();

  final ScrollController scrollController = ScrollController();
  GrupoDeAcessoPage({
    super.key,
    this.idGrupoDeAcesso,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GrupoDeAcessoBloc>(
          create: (_) => sl<GrupoDeAcessoBloc>()
            ..add(
              GrupoDeAcessoIniciouEvent(
                idGrupoDeAcesso: idGrupoDeAcesso,
              ),
            ),
        ),
        BlocProvider<PermissoesBloc>(
          create: (context) => sl<PermissoesBloc>()..add(PermissoesIniciou()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupo de Acesso'),
        ),
        floatingActionButton: _floatActionButton(),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
                buildWhen: (previous, current) =>
                    previous is! GrupoDeAcessoEdicaoEmProgresso,
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case const (GrupoDeAcessoCarregarFalha):
                      return const Text('Erro ao carregar grupo de acesso');
                    case const (GrupoDeAcessoSalvarFalha):
                      return const Text('Erro ao salvar grupo de acesso');
                    case (const (GrupoDeAcessoCarregarEmProgresso)):
                      return const CircularProgressIndicator.adaptive();
                    default:
                      return _grupoDeAcessoInformacoes(
                        context,
                        state.grupoDeAcesso,
                        state is! GrupoDeAcessoEdicaoEmProgresso,
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatActionButton() =>
      BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
        builder: (context, state) {
          if (state is GrupoDeAcessoCarregarEmProgresso) {
            return const SizedBox();
          }
          if (state is GrupoDeAcessoSalvarEmProgresso) {
            return const FloatingActionButton(
              tooltip: 'salvando',
              onPressed: null,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return FloatingActionButton(
            tooltip: 'Edição',
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.read<GrupoDeAcessoBloc>().add(GrupoDeAcessoSalvou());
              }
            },
            child: const Icon(
              Icons.check,
            ),
          );
        },
      );

  Widget _grupoDeAcessoInformacoes(
    BuildContext context,
    GrupoDeAcesso? grupoDeAcesso,
    bool readOnly,
  ) {
    final TextEditingController nomeController = TextEditingController(
      text: grupoDeAcesso?.nome ?? '',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para o nome do grupo
            TextFormField(
              controller: nomeController,
              readOnly: readOnly,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome do grupo';
                }
                return null;
              },
              onChanged: (value) {
                context.read<GrupoDeAcessoBloc>().add(
                      GrupoDeAcessoAlterouNomeEvent(nome: value),
                    );
              },
            ),
            const SizedBox(height: 16),

            // Lista de permissões
            const Text(
              'Permissões',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PermissoesBloc, PermissoesState>(
              builder: (context, state) {
                if (state is PermissoesCarregarEmProgesso) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is PermissoesCarregarSucesso ||
                    state is PermissoesSelecionarSucesso) {
                  final permissoesJaSelecionadas = state.permissoesSelecionadas;
                  final permissoesDoGrupo = grupoDeAcesso?.permissoes ?? {};
                  List<Permissao> permissoes = List.from(permissoesDoGrupo);
                  permissoes.addAll(permissoesJaSelecionadas ?? []);
                  permissoes = permissoes.toSet().toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: state.permissoes?.length ?? 0,
                    itemBuilder: (context, index) {
                      final permissao = state.permissoes?.elementAt(index);
                      final isSelected = permissoes.contains(permissao);

                      return CheckboxListTile(
                        title: Text(permissao?.nome ?? ''),
                        value: isSelected,
                        onChanged: readOnly
                            ? null
                            : (value) {
                                if (value == true) {
                                  context.read<PermissoesBloc>().add(
                                        PermissoesSelecionou(
                                          permissao: permissao!,
                                        ),
                                      );
                                  context.read<GrupoDeAcessoBloc>().add(
                                        GrupoDeAcessoAdionouPermissao(
                                          permissao: permissao,
                                        ),
                                      );
                                } else {
                                  context.read<PermissoesBloc>().add(
                                        PermissoesDesselecionou(
                                          permissao: permissao!,
                                        ),
                                      );
                                  context.read<GrupoDeAcessoBloc>().add(
                                        GrupoDeAcessoRemoveuPermissao(
                                          permissao: permissao,
                                        ),
                                      );
                                }
                              },
                      );
                    },
                  );
                } else if (state is PermissoesCarregarFalha) {
                  return const Text(
                    'Erro ao carregar permissões',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 16),

            // Botão de salvar
            if (!readOnly)
              ElevatedButton(
                onPressed: () {
                  context.read<GrupoDeAcessoBloc>().add(
                        GrupoDeAcessoSalvou(),
                      );
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    );
  }
}
