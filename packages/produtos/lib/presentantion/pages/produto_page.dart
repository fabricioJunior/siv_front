import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentation.dart';

class ProdutoPage extends StatelessWidget {
  final Produto? produto;
  final int? referenciaId;
  final int? corId;
  final int? tamanhoId;

  const ProdutoPage({
    super.key,
    this.produto,
    this.referenciaId,
    this.corId,
    this.tamanhoId,
  });

  @override
  Widget build(BuildContext context) {
    final editando = produto?.id != null;

    return BlocProvider<ProdutoBloc>(
      create: (_) => sl<ProdutoBloc>()
        ..add(
          ProdutoIniciou(
            produto: produto,
            referenciaId: referenciaId,
            corId: corId,
            tamanhoId: tamanhoId,
          ),
        ),
      child: BlocListener<ProdutoBloc, ProdutoState>(
        listenWhen: (previous, current) =>
            previous.produtoStep != current.produtoStep,
        listener: (context, state) {
          if (state.produtoStep == ProdutoStep.criado ||
              state.produtoStep == ProdutoStep.salvo) {
            Navigator.of(context).pop(true);
          }

          if (state.produtoStep == ProdutoStep.falha &&
              state.erroMensagem != null &&
              state.erroMensagem!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.erroMensagem!)));
          }
        },
        child: BlocBuilder<ProdutoBloc, ProdutoState>(
          builder: (context, state) {
            final carregando = state.produtoStep == ProdutoStep.carregando;

            return Scaffold(
              appBar: AppBar(
                title: Text(editando ? 'Editar Produto' : 'Novo Produto'),
              ),
              body: SafeArea(
                child: carregando && state.etapaAtual == 2
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: _buildStepper(context, state),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildConteudoEtapa(context, state),
                            ),
                          ),
                        ],
                      ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      if (state.etapaAtual > 0)
                        OutlinedButton.icon(
                          onPressed: carregando
                              ? null
                              : () => context.read<ProdutoBloc>().add(
                                  ProdutoEtapaAtualizou(
                                    etapaAtual: state.etapaAtual - 1,
                                  ),
                                ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Voltar'),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: carregando
                            ? null
                            : () => _avancarFluxo(context, state),
                        icon: Icon(
                          state.etapaAtual == 2
                              ? Icons.check
                              : Icons.arrow_forward,
                        ),
                        label: Text(_labelAcaoPrincipal(state.etapaAtual)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context, ProdutoState state) {
    final theme = Theme.of(context);
    const titulos = ['1. Seleção', '2. Combinações', '3. Confirmação'];

    return Row(
      children: List.generate(titulos.length, (index) {
        final ativo = state.etapaAtual == index;
        final concluido = state.etapaAtual > index;
        final cor = ativo
            ? theme.colorScheme.primary
            : concluido
            ? theme.colorScheme.tertiary
            : theme.colorScheme.outline;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < titulos.length - 1 ? 8 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cor),
              ),
              child: Text(
                titulos[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(color: cor),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConteudoEtapa(BuildContext context, ProdutoState state) {
    switch (state.etapaAtual) {
      case 0:
        return _buildEtapaSelecao(context, state);
      case 1:
        return _buildEtapaCombinacoes(context, state);
      case 2:
        return _buildEtapaConfirmacao(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEtapaSelecao(BuildContext context, ProdutoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione a referência, cores e tamanhos para gerar as combinações.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ReferenciaSeletor(
          modo: ReferenciaSeletorModo.unica,
          idReferenciasSelecionadasIniciais: referenciaId != null
              ? [referenciaId!]
              : [],
          referenciasSelecionadasIniciais: state.referenciaSelecionada == null
              ? const []
              : [state.referenciaSelecionada!],
          onChanged: (selecionadas) {
            context.read<ProdutoBloc>().add(
              ProdutoReferenciaSelecionou(
                referencia: selecionadas.isEmpty ? null : selecionadas.first,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        CorSeletor(
          modo: CorSeletorModo.multipla,
          coresSelecionadasIniciais: state.coresSelecionadas,
          onChanged: (selecionadas) {
            context.read<ProdutoBloc>().add(
              ProdutoCoresSelecionou(cores: selecionadas),
            );
          },
        ),
        const SizedBox(height: 12),
        TamanhoSeletor(
          modo: TamanhoSeletorModo.multipla,
          tamanhosSelecionadosIniciais: state.tamanhosSelecionados,
          onChanged: (selecionados) {
            context.read<ProdutoBloc>().add(
              ProdutoTamanhosSelecionou(tamanhos: selecionados),
            );
          },
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Criar código de barras automaticamente'),
          value: state.criarCodigoBarrasAutomaticamente,
          onChanged: (value) {
            context.read<ProdutoBloc>().add(
              ProdutoCriacaoCodigoBarrasAutomaticaAlternou(
                criarCodigoBarrasAutomaticamente: value ?? false,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Prévia: ${state.coresSelecionadas.length} cor(es) x ${state.tamanhosSelecionados.length} tamanho(s) = ${state.coresSelecionadas.length * state.tamanhosSelecionados.length} combinação(ões)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEtapaCombinacoes(BuildContext context, ProdutoState state) {
    if (state.combinacoes.isEmpty) {
      return const Text(
        'Nenhuma combinação gerada. Volte e selecione cores e tamanhos.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marque as combinações que deseja cadastrar.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Inserir')),
              const DataColumn(label: Text('Cor')),
              const DataColumn(label: Text('Tamanho')),
              if (!state.criarCodigoBarrasAutomaticamente)
                const DataColumn(label: Text('Código de barras')),
            ],
            rows: state.combinacoes.map((item) {
              return DataRow(
                selected: item.selecionada,
                cells: [
                  DataCell(
                    Checkbox(
                      value: item.selecionada,
                      onChanged: (value) {
                        context.read<ProdutoBloc>().add(
                          ProdutoCombinacaoSelecionou(
                            chave: item.chave,
                            selecionada: value ?? false,
                          ),
                        );
                      },
                    ),
                  ),
                  DataCell(Text(item.cor.nome)),
                  DataCell(Text(item.tamanho.nome)),
                  if (!state.criarCodigoBarrasAutomaticamente)
                    DataCell(
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              item.codigoDeBarras.isEmpty
                                  ? '-'
                                  : item.codigoDeBarras,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () =>
                                _editarCodigoDeBarras(context, state, item),
                            child: Text(
                              item.codigoDeBarras.isEmpty
                                  ? 'Informar'
                                  : 'Editar',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        if (state.criarCodigoBarrasAutomaticamente) ...[
          const SizedBox(height: 8),
          Text(
            'Os códigos de barras serão gerados automaticamente ao confirmar o cadastro.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Selecionadas: ${state.combinacoes.where((item) => item.selecionada).length} de ${state.combinacoes.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEtapaConfirmacao(BuildContext context, ProdutoState state) {
    final selecionadas = state.combinacoes
        .where((item) => item.selecionada)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirme os dados do cadastro',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Referência'),
          subtitle: Text(state.referenciaSelecionada?.nome ?? '-'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Total de combinações selecionadas'),
          subtitle: Text('${selecionadas.length}'),
        ),
        const SizedBox(height: 8),
        Text(
          'Combinações que serão cadastradas:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...selecionadas.map(
          (item) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline, size: 18),
            title: Text('${item.cor.nome} / ${item.tamanho.nome}'),
          ),
        ),
      ],
    );
  }

  String _labelAcaoPrincipal(int etapaAtual) {
    if (etapaAtual == 2) {
      return 'Confirmar cadastro';
    }
    return 'Próximo';
  }

  void _avancarFluxo(BuildContext context, ProdutoState state) {
    if (state.etapaAtual == 0) {
      if (state.referenciaSelecionada == null && state.referenciaId == null) {
        _mostrarMensagem(context, 'Selecione uma referência para continuar.');
        return;
      }
      if (state.coresSelecionadas.isEmpty) {
        _mostrarMensagem(context, 'Selecione ao menos uma cor.');
        return;
      }
      if (state.tamanhosSelecionados.isEmpty) {
        _mostrarMensagem(context, 'Selecione ao menos um tamanho.');
        return;
      }

      context.read<ProdutoBloc>().add(ProdutoEtapaAtualizou(etapaAtual: 1));
      return;
    }

    if (state.etapaAtual == 1) {
      final selecionadas = state.combinacoes
          .where((item) => item.selecionada)
          .toList();
      if (selecionadas.isEmpty) {
        _mostrarMensagem(
          context,
          'Selecione ao menos uma combinação para continuar.',
        );
        return;
      }

      if (!state.criarCodigoBarrasAutomaticamente) {
        final temSemCodigo = selecionadas.any(
          (item) => item.codigoDeBarras.trim().isEmpty,
        );
        if (temSemCodigo) {
          _mostrarMensagem(
            context,
            'Informe o código de barras para todas as combinações selecionadas.',
          );
          return;
        }

        final codigosDuplicados = _obterCodigosDuplicados(selecionadas);
        if (codigosDuplicados.isNotEmpty) {
          _mostrarMensagem(
            context,
            'Existem códigos de barras duplicados: ${codigosDuplicados.join(', ')}.',
          );
          return;
        }
      }

      context.read<ProdutoBloc>().add(ProdutoEtapaAtualizou(etapaAtual: 2));
      return;
    }

    final referenciaId = state.referenciaSelecionada?.id ?? state.referenciaId;
    if (referenciaId == null) {
      _mostrarMensagem(context, 'Referência inválida para cadastro.');
      return;
    }

    final selecionadas = state.combinacoes
        .where((item) => item.selecionada)
        .where((item) => item.cor.id != null && item.tamanho.id != null)
        .map(
          (item) => ProdutoCombinacaoSelecao(
            corId: item.cor.id!,
            tamanhoId: item.tamanho.id!,
            codigoDeBarras: state.criarCodigoBarrasAutomaticamente
                ? null
                : (item.codigoDeBarras.trim().isEmpty
                      ? null
                      : item.codigoDeBarras.trim()),
          ),
        )
        .toList();

    if (selecionadas.isEmpty) {
      _mostrarMensagem(
        context,
        'As combinações selecionadas precisam ter cor e tamanho válidos.',
      );
      return;
    }

    context.read<ProdutoBloc>().add(
      ProdutoSalvouCombinacoes(
        referenciaId: referenciaId,
        combinacoes: selecionadas,
        criarCodigoDeBarrasAutomaticamente:
            state.criarCodigoBarrasAutomaticamente,
      ),
    );
  }

  void _mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _editarCodigoDeBarras(
    BuildContext context,
    ProdutoState state,
    ProdutoCombinacaoCadastro item,
  ) async {
    final controller = TextEditingController(text: item.codigoDeBarras);

    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Código de barras da combinação: ${item.cor.nome} / ${item.tamanho.nome}',
          ),
          content: TextField(
            controller: controller,
            maxLength: 13,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Informe o código da combinação',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Limpar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (codigo == null) {
      return;
    }

    final codigoNormalizado = codigo.trim();
    final codigoDuplicado =
        codigoNormalizado.isNotEmpty &&
        state.combinacoes.any(
          (combinacao) =>
              !identical(combinacao, item) &&
              combinacao.codigoDeBarras.trim() == codigoNormalizado,
        );

    if (codigoDuplicado) {
      // ignore: use_build_context_synchronously
      _mostrarMensagem(
        context,
        'Código de barras já informado em outra combinação.',
      );
      return;
    }

    // ignore: use_build_context_synchronously
    context.read<ProdutoBloc>().add(
      ProdutoCombinacaoCodigoBarrasEditou(
        chave: item.chave,
        codigoDeBarras: codigoNormalizado,
      ),
    );
  }

  List<String> _obterCodigosDuplicados(
    List<ProdutoCombinacaoCadastro> combinacoes,
  ) {
    final frequencia = <String, int>{};

    for (final combinacao in combinacoes) {
      final codigo = combinacao.codigoDeBarras.trim();
      if (codigo.isEmpty) {
        continue;
      }
      frequencia[codigo] = (frequencia[codigo] ?? 0) + 1;
    }

    return frequencia.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();
  }
}
