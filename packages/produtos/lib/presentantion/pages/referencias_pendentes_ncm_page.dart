import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class ReferenciasPendentesNcmPage extends StatefulWidget {
  const ReferenciasPendentesNcmPage({super.key});

  @override
  State<ReferenciasPendentesNcmPage> createState() =>
      _ReferenciasPendentesNcmPageState();
}

class _ReferenciasPendentesNcmPageState
    extends State<ReferenciasPendentesNcmPage> {
  late final ReferenciasPendentesNcmBloc _bloc;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ReferenciasPendentesNcmBloc>()
      ..add(ReferenciasPendentesNcmIniciou());
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _bloc.state;
      if (state.step == ReferenciasPendentesNcmStep.carregado &&
          state.currentPage < state.totalPages) {
        _bloc.add(ReferenciasPendentesNcmCarregouMais());
      }
    }
  }

  void _buscar() {
    _bloc.add(
      ReferenciasPendentesNcmBuscou(search: _searchController.text.trim()),
    );
  }

  void _alterarOrdem(String orderBy, String orderDir) {
    _bloc.add(
      ReferenciasPendentesNcmBuscou(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        orderBy: orderBy,
        orderDir: orderDir,
      ),
    );
  }

  void _atualizarEmMassa() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atualizar NCM em massa'),
        content: const Text(
          'Isso vai preencher automaticamente o NCM de todas as referências sem NCM, '
          'usando o NCM da sub-categoria ou categoria correspondente.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Atualizar'),
          ),
        ],
      ),
    ).then((confirmou) {
      if (confirmou == true) {
        _bloc.add(ReferenciasPendentesNcmAtualizouEmMassa());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReferenciasPendentesNcmBloc>.value(
      value: _bloc,
      child: BlocListener<ReferenciasPendentesNcmBloc,
          ReferenciasPendentesNcmState>(
        listenWhen: (prev, curr) =>
            curr.step == ReferenciasPendentesNcmStep.atualizado &&
            prev.step != ReferenciasPendentesNcmStep.atualizado,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.atualizadas} referência(s) atualizadas, '
                '${state.ignoradas} ignoradas.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Pendência de NCM')),
          floatingActionButton:
              BlocBuilder<ReferenciasPendentesNcmBloc,
                  ReferenciasPendentesNcmState>(
                builder: (context, state) {
                  final atualizando =
                      state.step == ReferenciasPendentesNcmStep.atualizando;
                  return FloatingActionButton.extended(
                    onPressed: atualizando ? null : _atualizarEmMassa,
                    icon: atualizando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(
                      atualizando ? 'Atualizando...' : 'Atualizar em massa',
                    ),
                  );
                },
              ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou descrição',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _buscar();
                        },
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _buscar(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<ReferenciasPendentesNcmBloc,
                    ReferenciasPendentesNcmState>(
                  buildWhen: (prev, curr) =>
                      prev.orderBy != curr.orderBy ||
                      prev.orderDir != curr.orderDir,
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Ordenar: '),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'Nome',
                            ativo: state.orderBy == 'nome',
                            desc: state.orderDir == 'DESC',
                            onTap: () {
                              final novaDir = state.orderBy == 'nome' &&
                                      state.orderDir == 'ASC'
                                  ? 'DESC'
                                  : 'ASC';
                              _alterarOrdem('nome', novaDir);
                            },
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'Data de cadastro',
                            ativo: state.orderBy == 'criadoEm',
                            desc: state.orderDir == 'DESC',
                            onTap: () {
                              final novaDir = state.orderBy == 'criadoEm' &&
                                      state.orderDir == 'ASC'
                                  ? 'DESC'
                                  : 'ASC';
                              _alterarOrdem('criadoEm', novaDir);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                BlocBuilder<ReferenciasPendentesNcmBloc,
                    ReferenciasPendentesNcmState>(
                  buildWhen: (prev, curr) => prev.totalItems != curr.totalItems,
                  builder: (context, state) {
                    if (state.totalItems == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${state.totalItems} referência(s) sem NCM',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<ReferenciasPendentesNcmBloc,
                      ReferenciasPendentesNcmState>(
                    builder: (context, state) {
                      if (state.step == ReferenciasPendentesNcmStep.carregando) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == ReferenciasPendentesNcmStep.falha) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Erro ao carregar referências.'),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    _bloc.add(ReferenciasPendentesNcmIniciou()),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhuma referência sem NCM',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(ReferenciasPendentesNcmIniciou());
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: state.items.length +
                              (state.step ==
                                      ReferenciasPendentesNcmStep
                                          .carregandoMais
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            }
                            final ref = state.items[index];
                            final ncmSugerido =
                                ref.subCategoria?.ncm ?? ref.categoria?.ncm;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  ref.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (ref.categoria != null)
                                      Text(
                                        'Categoria: ${ref.categoria!.nome}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (ref.subCategoria != null)
                                      Text(
                                        'Sub-categoria: ${ref.subCategoria!.nome}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (ncmSugerido != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'NCM sugerido: ',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Chip(
                                            label: Text(
                                              ncmSugerido,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ] else
                                      const Text(
                                        'Sem NCM sugerido na categoria',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool ativo;
  final bool desc;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.ativo,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (ativo) ...[
            const SizedBox(width: 4),
            Icon(
              desc ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
            ),
          ],
        ],
      ),
      selected: ativo,
      onSelected: (_) => onTap(),
    );
  }
}
