import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ReferenciasPage extends StatefulWidget {
  const ReferenciasPage({super.key});

  @override
  State<ReferenciasPage> createState() => _ReferenciasPageState();
}

class _ReferenciasPageState extends State<ReferenciasPage> {
  final bloc = sl<ReferenciasBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  String _formatarData(DateTime? data) {
    if (data == null) return '-';
    final local = data.toLocal();
    String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
    return '${doisDigitos(local.day)}/${doisDigitos(local.month)}/${local.year} ${doisDigitos(local.hour)}:${doisDigitos(local.minute)}';
  }

  String _labelOrdenacao(ReferenciasOrdenacao ordenacao) {
    switch (ordenacao) {
      case ReferenciasOrdenacao.nomeAsc:
        return 'Nome (A-Z)';
      case ReferenciasOrdenacao.nomeDesc:
        return 'Nome (Z-A)';
      case ReferenciasOrdenacao.criadoEmAsc:
        return 'Criado em (mais antigo)';
      case ReferenciasOrdenacao.criadoEmDesc:
        return 'Criado em (mais recente)';
      case ReferenciasOrdenacao.atualizadoEmAsc:
        return 'Atualizado em (mais antigo)';
      case ReferenciasOrdenacao.atualizadoEmDesc:
        return 'Atualizado em (mais recente)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReferenciasBloc>(
      create: (context) => bloc..add(ReferenciasIniciou()),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ReferenciaCadastroModal.show(context: context).then((_) {
              bloc.add(ReferenciasIniciou());
            });
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(title: const Text('Referencias')),
        body: SafeArea(
          child: BlocBuilder<ReferenciasBloc, ReferenciasState>(
            builder: (context, state) {
              final ordenacaoAtual = state.ordenacao;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Text(
                          'Gerencie suas referencias',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SearchBar(
                          autoFocus: false,
                          hintText: 'Buscar referencia por nome',
                          onChanged: (value) {
                            debouncer.run(() {
                              bloc.add(
                                ReferenciasIniciou(
                                  busca: value,
                                  ordenacao: ordenacaoAtual,
                                ),
                              );
                            });
                          },
                          onSubmitted: (value) {
                            bloc.add(
                              ReferenciasIniciou(
                                busca: value,
                                ordenacao: ordenacaoAtual,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton<ReferenciasOrdenacao>(
                              tooltip: 'Ordenar referências',
                              onSelected: (ordenacao) {
                                bloc.add(
                                  ReferenciasIniciou(ordenacao: ordenacao),
                                );
                              },
                              itemBuilder: (context) =>
                                  ReferenciasOrdenacao.values.map((ordenacao) {
                                    return PopupMenuItem<ReferenciasOrdenacao>(
                                      value: ordenacao,
                                      child: Row(
                                        children: [
                                          if (ordenacaoAtual == ordenacao)
                                            const Icon(Icons.check, size: 16)
                                          else
                                            const SizedBox(width: 16),
                                          const SizedBox(width: 8),
                                          Text(_labelOrdenacao(ordenacao)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              child: Row(
                                children: [
                                  const Icon(Icons.sort, size: 18),
                                  const SizedBox(width: 6),
                                  Text(_labelOrdenacao(ordenacaoAtual)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildConteudoLista(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConteudoLista(BuildContext context, ReferenciasState state) {
    if (state is ReferenciasCarregarEmProgresso) {
      return _buildLoading();
    }

    if (state is ReferenciasCarregarFalha) {
      return _buildError(state.ordenacao);
    }

    if (state is ReferenciasCarregarSucesso) {
      if (state.referencias.isEmpty) {
        return _buildEmpty();
      }

      return ListView.builder(
        itemCount: state.referencias.length,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemBuilder: (context, index) {
          final referencia = state.referencias[index];
          return _buildReferenciaCard(context, referencia);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildReferenciaCard(BuildContext context, Referencia referencia) {
    final categoriaNome = referencia.categoria?.nome;
    final subCategoriaNome = referencia.subCategoria?.nome;
    final descricao = referencia.descricao;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          final referenciaId = referencia.id;
          if (referenciaId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Referência sem ID válido.')),
            );
            return;
          }

          await Navigator.of(context).push<Referencia>(
            MaterialPageRoute(
              builder: (_) => ReferenciaPage(idReferencia: referenciaId),
            ),
          );

          // ignore: use_build_context_synchronously
          context.read<ReferenciasBloc>().add(ReferenciasIniciou());
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: ClipOval(
            child: SizedBox.expand(
              child: ImagemViewWidget(
                url: referencia.id.toString(),
                onlyFromCache: true,
                cacheKey: referencia.id.toString(),
                fit: BoxFit.cover,
                placeholder: Center(
                  child: Text(
                    referencia.nome.isNotEmpty
                        ? referencia.nome.substring(0, 1).toUpperCase()
                        : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        //  CircleAvatar(
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   child: Text(
        //     referencia.nome.isNotEmpty
        //         ? referencia.nome.substring(0, 1).toUpperCase()
        //         : '-',
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
        title: Text(
          referencia.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (descricao != null && descricao.isNotEmpty)
              Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (categoriaNome != null && categoriaNome.isNotEmpty)
              Text('Categoria: $categoriaNome'),
            if (subCategoriaNome != null && subCategoriaNome.isNotEmpty)
              Text('Subcategoria: $subCategoriaNome'),
            Text('Criado em: ${_formatarData(referencia.criadoEm)}'),
            Text('Atualizado em: ${_formatarData(referencia.atualizadoEm)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  Widget _buildError(ReferenciasOrdenacao ordenacaoAtual) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar referencias'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              bloc.add(ReferenciasIniciou(ordenacao: ordenacaoAtual));
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma referencia encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
