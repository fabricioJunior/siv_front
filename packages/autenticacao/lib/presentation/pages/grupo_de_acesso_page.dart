import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/presentation/bloc/grupo_de_acesso_bloc/grupo_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/modals/selecionar_permissao_modal.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class GrupoDeAcessoPage extends StatelessWidget {
  final int? idGrupoDeAcesso;

  final formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final bloc = sl<GrupoDeAcessoBloc>();

  GrupoDeAcessoPage({
    super.key,
    this.idGrupoDeAcesso,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GrupoDeAcessoBloc>(
          create: (_) => bloc
            ..add(
              GrupoDeAcessoIniciouEvent(
                idGrupoDeAcesso: idGrupoDeAcesso,
              ),
            ),
        ),
      ],
      child: BlocListener<GrupoDeAcessoBloc, GrupoDeAcessoState>(
        listener: (context, state) async {
          if (state is GrupoDeAcessoExcluirGrupoSucesso) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Exclusão realizada com sucesso'),
                content: const Text('Grupo de acesso excluído com sucesso.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(_).pop();
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            ).then((_) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            });
          }

          // Erro/sucesso de salvar viram snackbar, não substituem a tela
          // inteira -- o formulário (nome + permissões já escolhidas)
          // continua visível e editável, o usuário só tenta salvar de
          // novo. Ver buildWhen abaixo, que mantém o formulário anterior
          // montado durante GrupoDeAcessoSalvarFalha.
          if (state is GrupoDeAcessoSalvarFalha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensagem)),
            );
          }
          if (state is GrupoDeAcessoSalvarSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Grupo de acesso salvo com sucesso.')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Grupo de Acesso'),
            actions: [
              if (idGrupoDeAcesso != null) _excluirGrupo(context),
            ],
          ),
          floatingActionButton: _floatActionButton(),
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
                  buildWhen: (previous, current) =>
                      previous is! GrupoDeAcessoEdicaoEmProgresso &&
                      current is! GrupoDeAcessoSalvarFalha,
                  builder: (context, state) {
                    switch (state.runtimeType) {
                      case const (GrupoDeAcessoCarregarFalha):
                        final falha = state as GrupoDeAcessoCarregarFalha;
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(falha.erroMessage),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () {
                                    context.read<GrupoDeAcessoBloc>().add(
                                          GrupoDeAcessoIniciouEvent(
                                            idGrupoDeAcesso: idGrupoDeAcesso,
                                          ),
                                        );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        );
                      case (const (GrupoDeAcessoCarregarEmProgresso)):
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator.adaptive(),
                        );
                      default:
                        return Column(
                          children: [
                            _grupoDeAcessoInformacoes(
                              context,
                              state is! GrupoDeAcessoEdicaoEmProgresso,
                            ),
                          ],
                        );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _excluirGrupo(BuildContext context) => IconButton(
        onPressed: () async {
          var confirmacao = await showDialog(
            context: context,
            builder: (context) => _confirmarExclusaoAlertDialog(context),
          );
          if (confirmacao == true) {
            bloc.add(GrupoExcluiu());
          }
        },
        icon: const Icon(Icons.delete),
      );

  AlertDialog _confirmarExclusaoAlertDialog(BuildContext context) =>
      AlertDialog(
        title: const Text('Excluir grupo de acesso?'),
        content: const Text(
          'Ação irreversível. Usuários vinculados a este grupo perdem as '
          'permissões associadas a ele.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Excluir'),
          ),
        ],
      );

  Widget _floatActionButton() =>
      BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
        builder: (context, state) {
          if (state is GrupoDeAcessoCarregarEmProgresso) {
            return const SizedBox();
          }
          if (state is GrupoDeAcessoSalvarEmProgresso) {
            return const FloatingActionButton(
              tooltip: 'Salvando',
              onPressed: null,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          final emEdicao = state is GrupoDeAcessoEdicaoEmProgresso;
          return FloatingActionButton(
            tooltip: emEdicao ? 'Salvar' : 'Editar',
            onPressed: () {
              if (!emEdicao) {
                // Reabre em modo de edição. Usa o id do STATE (state.id),
                // não o idGrupoDeAcesso do widget -- esse campo fica null
                // pra sempre num grupo recém-criado (widget não muda depois
                // de montado), enquanto o state já tem o id real assim que
                // o grupo é salvo. Usar o campo do widget aqui reabriria
                // como "criar outro grupo" em vez de editar o que acabou
                // de ser salvo.
                context.read<GrupoDeAcessoBloc>().add(
                      GrupoDeAcessoIniciouEvent(
                        idGrupoDeAcesso: state.id ?? idGrupoDeAcesso,
                      ),
                    );
                return;
              }
              if (formKey.currentState?.validate() ?? false) {
                context.read<GrupoDeAcessoBloc>().add(GrupoDeAcessoSalvou());
              }
            },
            child: Icon(emEdicao ? Icons.check : Icons.edit),
          );
        },
      );

  Widget _grupoDeAcessoInformacoes(
    BuildContext context,
    bool readOnly,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para o nome do grupo
            TextFormField(
              initialValue: context.read<GrupoDeAcessoBloc>().state.nome,
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

            const SizedBox(height: 8),
            BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
              builder: (blocContext, state) {
                if (state is GrupoDeAcessoCarregarEmProgresso) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is GrupoDeAcessoEdicaoEmProgresso ||
                    state is GrupoDeAcessoSalvarSucesso) {
                  final permissoesDoGrupo = state.permissoesDoGrupo ?? const [];
                  final grupoNovoVazio =
                      idGrupoDeAcesso == null && permissoesDoGrupo.isEmpty;

                  return Column(
                    children: [
                      if (grupoNovoVazio) _seletorDeCargo(blocContext, state),
                      Padding(
                        padding:
                            const EdgeInsetsGeometry.only(left: 16, right: 08),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Permissões',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                onPressed: () async {
                                  var permissoesNaoAdicionadas =
                                      state.permissoesNaoUtilizadasNoGrupo ??
                                          [];

                                  var permissoesSelecionadas =
                                      await SelecionarPermissaoModal.show(
                                    blocContext,
                                    permissoesNaoAdicionadas,
                                  );
                                  if (permissoesSelecionadas != null) {
                                    // ignore: use_build_context_synchronously
                                    for (final permissao
                                        in permissoesSelecionadas) {
                                      context.read<GrupoDeAcessoBloc>().add(
                                            GrupoDeAcessoAdionouPermissao(
                                              permissao: permissao,
                                            ),
                                          );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.add))
                          ],
                        ),
                      ),
                      _permissoesPorFluxo(
                        context,
                        permissoesDoGrupo,
                      ),
                    ],
                  );
                } else if (state is GrupoDeAcessoCarregarFalha) {
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
          ],
        ),
      ),
    );
  }

  // Templates de cargo (Vendedor/Caixa/Gerente) só aparecem num grupo NOVO
  // e ainda sem nenhuma permissão -- monta o perfil de uma vez em vez de
  // escolher item por item. Some assim que a primeira permissão é
  // adicionada (por template ou manualmente), não interfere depois.
  Widget _seletorDeCargo(BuildContext context, GrupoDeAcessoState state) {
    final theme = Theme.of(context);
    final disponiveis = state.permissoesNaoUtilizadasNoGrupo ?? const [];

    void aplicarCargo(String cargo) {
      final codigos = componentesDoCargo(cargo).toSet();
      final bloc = context.read<GrupoDeAcessoBloc>();
      for (final permissao in disponiveis) {
        if (codigos.contains(permissao.id)) {
          bloc.add(GrupoDeAcessoAdionouPermissao(permissao: permissao));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Começar com um cargo pronto?',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha um ponto de partida e ajuste depois. Ou adicione as '
            'permissões manualmente.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cargo in cargosPredefinidos)
                ActionChip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(cargo),
                  onPressed: () => aplicarCargo(cargo),
                ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  // Lista de permissões já concedidas ao grupo, agrupada por fluxo de
  // negócio (Vendas, Romaneios, Caixa, etc -- ver fluxos_de_permissao.dart)
  // em vez da lista plana e sem ordem que existia antes. Uma permissão
  // usada por mais de uma tela aparece repetida em cada fluxo
  // correspondente.
  Widget _permissoesPorFluxo(
    BuildContext context,
    List<Permissao> permissoes,
  ) {
    final grupos = agruparPermissoesPorFluxo(permissoes);

    if (grupos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Nenhuma permissão adicionada a este grupo ainda.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entrada in grupos.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              entrada.key,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...entrada.value
              .map((permissao) => _permissaoCard(context, permissao)),
        ],
      ],
    );
  }

  Widget _permissaoCard(BuildContext context, Permissao permissao) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nome amigável (nomeExibicao) como texto principal -- ver
                // mesma mudança no selecionar_permissao_modal.dart.
                Text(
                  permissao.nomeExibicao,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (permissao.descontinuado) ...[
                      Icon(
                        Icons.block,
                        size: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      permissao.descontinuado
                          ? 'Descontinuada · ${permissao.id}'
                          : permissao.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: permissao.descontinuado
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final bloc = context.read<GrupoDeAcessoBloc>();
              bloc.add(GrupoDeAcessoRemoveuPermissao(permissao: permissao));
              // Remoção é imediata (sem dialog de confirmação, que seria
              // fricção extra pra uma ação comum) mas reversível por
              // alguns segundos via o "Desfazer" do snackbar.
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('"${permissao.nomeExibicao}" removida.'),
                    action: SnackBarAction(
                      label: 'Desfazer',
                      onPressed: () => bloc.add(
                        GrupoDeAcessoAdionouPermissao(permissao: permissao),
                      ),
                    ),
                  ),
                );
            },
            icon: Icon(
              Icons.delete,
              color: Colors.redAccent.withAlpha(200),
            ),
          )
        ],
      ),
    );
  }
}
