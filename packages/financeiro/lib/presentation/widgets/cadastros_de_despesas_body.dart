import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class CadastrosDeDespesasBody extends StatelessWidget {
  const CadastrosDeDespesasBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (PermissaoPorNome.acessoPermitido('DESFM001'))
          const _CategoriasDespesaSection(),
        if (PermissaoPorNome.acessoPermitido('DESFM002'))
          const _OrigensPagamentoDespesaSection(),
      ],
    );
  }
}

class _CategoriasDespesaSection extends StatefulWidget {
  const _CategoriasDespesaSection();

  @override
  State<_CategoriasDespesaSection> createState() =>
      _CategoriasDespesaSectionState();
}

class _CategoriasDespesaSectionState extends State<_CategoriasDespesaSection> {
  final bloc = sl<CategoriasDespesaBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    bloc.add(CategoriasDespesaIniciou(empresaId: _empresaId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriasDespesaBloc>(
      create: (_) => bloc,
      child: ExpansionTile(
        title: const Text('Categorias de despesa'),
        initiallyExpanded: true,
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result =
                await Navigator.of(context).pushNamed('/categoria_despesa');
            if (result == true) {
              // ignore: use_build_context_synchronously
              bloc.add(CategoriasDespesaIniciou(empresaId: _empresaId));
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Buscar por nome',
              onChanged: (value) {
                debouncer.run(() {
                  bloc.add(
                    CategoriasDespesaIniciou(
                      empresaId: _empresaId,
                      busca: value,
                    ),
                  );
                });
              },
            ),
          ),
          BlocBuilder<CategoriasDespesaBloc, CategoriasDespesaState>(
            builder: (context, state) {
              if (state is CategoriasDespesaCarregarEmProgresso) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              if (state is CategoriasDespesaCarregarFalha) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Falha ao carregar categorias.'),
                );
              }

              if (state.categorias.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma categoria cadastrada.'),
                );
              }

              return Column(
                children: state.categorias
                    .map(
                      (categoria) => ListTile(
                        title: Text(categoria.nome),
                        subtitle: Text(
                          categoria.inativa ? 'Inativa' : 'Ativa',
                          style: TextStyle(
                            color: categoria.inativa
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            '/categoria_despesa',
                            arguments: {'id': categoria.id},
                          );
                          if (result == true && context.mounted) {
                            bloc.add(
                              CategoriasDespesaIniciou(empresaId: _empresaId),
                            );
                          }
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrigensPagamentoDespesaSection extends StatefulWidget {
  const _OrigensPagamentoDespesaSection();

  @override
  State<_OrigensPagamentoDespesaSection> createState() =>
      _OrigensPagamentoDespesaSectionState();
}

class _OrigensPagamentoDespesaSectionState
    extends State<_OrigensPagamentoDespesaSection> {
  final bloc = sl<OrigensPagamentoDespesaBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    bloc.add(OrigensPagamentoDespesaIniciou(empresaId: _empresaId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrigensPagamentoDespesaBloc>(
      create: (_) => bloc,
      child: ExpansionTile(
        title: const Text('Origens de pagamento'),
        initiallyExpanded: true,
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.of(context)
                .pushNamed('/origem_pagamento_despesa');
            if (result == true) {
              // ignore: use_build_context_synchronously
              bloc.add(OrigensPagamentoDespesaIniciou(empresaId: _empresaId));
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Buscar por nome',
              onChanged: (value) {
                debouncer.run(() {
                  bloc.add(
                    OrigensPagamentoDespesaIniciou(
                      empresaId: _empresaId,
                      busca: value,
                    ),
                  );
                });
              },
            ),
          ),
          BlocBuilder<OrigensPagamentoDespesaBloc,
              OrigensPagamentoDespesaState>(
            builder: (context, state) {
              if (state is OrigensPagamentoDespesaCarregarEmProgresso) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              if (state is OrigensPagamentoDespesaCarregarFalha) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Falha ao carregar origens de pagamento.'),
                );
              }

              if (state.origens.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma origem de pagamento cadastrada.'),
                );
              }

              return Column(
                children: state.origens
                    .map(
                      (origem) => ListTile(
                        title: Text(origem.nome),
                        subtitle: Text(
                          origem.tipo.diaVencimentoObrigatorio
                              ? '${origem.tipo.label} • vence dia ${origem.diaVencimento} '
                                  '• fecha ${origem.prazoFechamentoDias} dias antes'
                              : origem.tipo.label,
                        ),
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            '/origem_pagamento_despesa',
                            arguments: {'id': origem.id},
                          );
                          if (result == true && context.mounted) {
                            bloc.add(
                              OrigensPagamentoDespesaIniciou(
                                empresaId: _empresaId,
                              ),
                            );
                          }
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
