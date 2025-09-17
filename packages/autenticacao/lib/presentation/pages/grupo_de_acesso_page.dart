import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/presentation/bloc/grupo_de_acesso_bloc/grupo_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/modals/selecionar_permissao_modal.dart';
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
                title: const Text('Exclusão Realizada com sucesso!'),
                content: const Text('Grupo de acesso excluido com sucesso'),
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
              Navigator.of(context).pop();
            });
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
        title: const Text(
            'Confirmação, você realmente deseja excluir o grupo de acesso ?'),
        content: const Text(
            'ATENÇÃO, ação inrreversível e com impacto ao acesso dos usuários com acesso ao grupo de acesso'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'SIM',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'NÃO',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.green),
            ),
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
                  return Column(
                    children: [
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

                                  var permissao =
                                      await SelecionarPermissaoModal.show(
                                    blocContext,
                                    permissoesNaoAdicionadas,
                                  );
                                  if (permissao != null) {
                                    // ignore: use_build_context_synchronously
                                    context.read<GrupoDeAcessoBloc>().add(
                                          GrupoDeAcessoAdionouPermissao(
                                            permissao: permissao,
                                          ),
                                        );
                                  }
                                },
                                icon: const Icon(Icons.add))
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        controller: scrollController,
                        itemCount: state.permissoesDoGrupo?.length ?? 0,
                        itemBuilder: (context, index) {
                          final permissao =
                              state.permissoesDoGrupo?.elementAt(index);

                          return _permissaoCard(context, permissao!);
                        },
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
                Text(
                  'ID: ${permissao.id}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nome: ${permissao.nome}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  permissao.descontinuado
                      ? 'Status: Descontinuado'
                      : 'Status: Ativo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            permissao.descontinuado ? Colors.red : Colors.green,
                      ),
                ),
                const SizedBox(height: 04),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context
                  .read<GrupoDeAcessoBloc>()
                  .add(GrupoDeAcessoRemoveuPermissao(permissao: permissao));
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
