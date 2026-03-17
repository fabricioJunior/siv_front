import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentation.dart';

class ProdutoPage extends StatefulWidget {
  final Produto? produto;

  const ProdutoPage({super.key, this.produto});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  late final ProdutoBloc _bloc;

  int _etapaAtual = 0;
  bool _criarCodigoBarrasAutomaticamente = false;
  Referencia? _referenciaSelecionada;
  List<Cor> _coresSelecionadas = const [];
  List<Tamanho> _tamanhosSelecionados = const [];
  List<_CombinacaoCadastro> _combinacoes = const [];

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProdutoBloc>()..add(ProdutoIniciou(produto: widget.produto));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto?.id != null;

    return BlocProvider<ProdutoBloc>.value(
      value: _bloc,
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
                child: carregando && _etapaAtual == 2
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: _buildStepper(context),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildConteudoEtapa(context),
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
                      if (_etapaAtual > 0)
                        OutlinedButton.icon(
                          onPressed: carregando
                              ? null
                              : () {
                                  setState(() {
                                    _etapaAtual = _etapaAtual - 1;
                                  });
                                },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Voltar'),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: carregando
                            ? null
                            : () => _avancarFluxo(context),
                        icon: Icon(
                          _etapaAtual == 2 ? Icons.check : Icons.arrow_forward,
                        ),
                        label: Text(_labelAcaoPrincipal()),
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

  Widget _buildStepper(BuildContext context) {
    final theme = Theme.of(context);
    const titulos = ['1. Seleção', '2. Combinações', '3. Confirmação'];

    return Row(
      children: List.generate(titulos.length, (index) {
        final ativo = _etapaAtual == index;
        final concluido = _etapaAtual > index;
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

  Widget _buildConteudoEtapa(BuildContext context) {
    switch (_etapaAtual) {
      case 0:
        return _buildEtapaSelecao();
      case 1:
        return _buildEtapaCombinacoes(context);
      case 2:
        return _buildEtapaConfirmacao(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEtapaSelecao() {
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
          referenciasSelecionadasIniciais: _referenciaSelecionada == null
              ? const []
              : [_referenciaSelecionada!],
          onChanged: (selecionadas) {
            setState(() {
              _referenciaSelecionada = selecionadas.isEmpty
                  ? null
                  : selecionadas.first;
            });
          },
        ),
        const SizedBox(height: 12),
        CorSeletor(
          modo: CorSeletorModo.multipla,
          coresSelecionadasIniciais: _coresSelecionadas,
          onChanged: (selecionadas) {
            setState(() {
              _coresSelecionadas = selecionadas;
              _sincronizarCombinacoes();
            });
          },
        ),
        const SizedBox(height: 12),
        TamanhoSeletor(
          modo: TamanhoSeletorModo.multipla,
          tamanhosSelecionadosIniciais: _tamanhosSelecionados,
          onChanged: (selecionados) {
            setState(() {
              _tamanhosSelecionados = selecionados;
              _sincronizarCombinacoes();
            });
          },
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Criar código de barras automaticamente'),
          value: _criarCodigoBarrasAutomaticamente,
          onChanged: (value) {
            setState(() {
              _criarCodigoBarrasAutomaticamente = value ?? false;
            });
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Prévia: ${_coresSelecionadas.length} cor(es) x ${_tamanhosSelecionados.length} tamanho(s) = ${_coresSelecionadas.length * _tamanhosSelecionados.length} combinação(ões)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEtapaCombinacoes(BuildContext context) {
    if (_combinacoes.isEmpty) {
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
              if (!_criarCodigoBarrasAutomaticamente)
                const DataColumn(label: Text('Código de barras')),
            ],
            rows: _combinacoes.map((item) {
              return DataRow(
                selected: item.selecionada,
                cells: [
                  DataCell(
                    Checkbox(
                      value: item.selecionada,
                      onChanged: (value) {
                        setState(() {
                          item.selecionada = value ?? false;
                        });
                      },
                    ),
                  ),
                  DataCell(Text(item.cor.nome)),
                  DataCell(Text(item.tamanho.nome)),
                  if (!_criarCodigoBarrasAutomaticamente)
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
                            onPressed: () => _editarCodigoDeBarras(item),
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
        if (_criarCodigoBarrasAutomaticamente) ...[
          const SizedBox(height: 8),
          Text(
            'Os códigos de barras serão gerados automaticamente ao confirmar o cadastro.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Selecionadas: ${_combinacoes.where((item) => item.selecionada).length} de ${_combinacoes.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEtapaConfirmacao(BuildContext context) {
    final selecionadas = _combinacoes
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
          subtitle: Text(_referenciaSelecionada?.nome ?? '-'),
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

  String _labelAcaoPrincipal() {
    if (_etapaAtual == 2) {
      return 'Confirmar cadastro';
    }
    return 'Próximo';
  }

  void _avancarFluxo(BuildContext context) {
    if (_etapaAtual == 0) {
      if (_referenciaSelecionada == null) {
        _mostrarMensagem('Selecione uma referência para continuar.');
        return;
      }
      if (_coresSelecionadas.isEmpty) {
        _mostrarMensagem('Selecione ao menos uma cor.');
        return;
      }
      if (_tamanhosSelecionados.isEmpty) {
        _mostrarMensagem('Selecione ao menos um tamanho.');
        return;
      }

      setState(() {
        _sincronizarCombinacoes();
        _etapaAtual = 1;
      });
      return;
    }

    if (_etapaAtual == 1) {
      final selecionadas = _combinacoes
          .where((item) => item.selecionada)
          .toList();
      if (selecionadas.isEmpty) {
        _mostrarMensagem('Selecione ao menos uma combinação para continuar.');
        return;
      }

      if (!_criarCodigoBarrasAutomaticamente) {
        final temSemCodigo = selecionadas.any(
          (item) => item.codigoDeBarras.trim().isEmpty,
        );
        if (temSemCodigo) {
          _mostrarMensagem(
            'Informe o código de barras para todas as combinações selecionadas.',
          );
          return;
        }

        final codigosDuplicados = _obterCodigosDuplicados(selecionadas);
        if (codigosDuplicados.isNotEmpty) {
          _mostrarMensagem(
            'Existem códigos de barras duplicados: ${codigosDuplicados.join(', ')}.',
          );
          return;
        }
      }

      setState(() {
        _etapaAtual = 2;
      });
      return;
    }

    final referenciaId = _referenciaSelecionada?.id;
    if (referenciaId == null) {
      _mostrarMensagem('Referência inválida para cadastro.');
      return;
    }

    final selecionadas = _combinacoes
        .where((item) => item.selecionada)
        .where((item) => item.cor.id != null && item.tamanho.id != null)
        .map(
          (item) => ProdutoCombinacaoSelecao(
            corId: item.cor.id!,
            tamanhoId: item.tamanho.id!,
            codigoDeBarras: _criarCodigoBarrasAutomaticamente
                ? null
                : (item.codigoDeBarras.trim().isEmpty
                      ? null
                      : item.codigoDeBarras.trim()),
          ),
        )
        .toList();

    if (selecionadas.isEmpty) {
      _mostrarMensagem(
        'As combinações selecionadas precisam ter cor e tamanho válidos.',
      );
      return;
    }

    context.read<ProdutoBloc>().add(
      ProdutoSalvouCombinacoes(
        referenciaId: referenciaId,
        combinacoes: selecionadas,
        criarCodigoDeBarrasAutomaticamente: _criarCodigoBarrasAutomaticamente,
      ),
    );
  }

  void _sincronizarCombinacoes() {
    final statusAnterior = <String, _CombinacaoCadastro>{
      for (final item in _combinacoes) item.chave: item,
    };

    final novas = <_CombinacaoCadastro>[];

    for (final cor in _coresSelecionadas) {
      for (final tamanho in _tamanhosSelecionados) {
        final chave = _CombinacaoCadastro.gerarChave(cor, tamanho);
        final anterior = statusAnterior[chave];
        novas.add(
          _CombinacaoCadastro(
            cor: cor,
            tamanho: tamanho,
            selecionada: anterior?.selecionada ?? true,
            codigoDeBarras: anterior?.codigoDeBarras ?? '',
          ),
        );
      }
    }

    _combinacoes = novas;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _editarCodigoDeBarras(_CombinacaoCadastro item) async {
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
        _combinacoes.any(
          (combinacao) =>
              !identical(combinacao, item) &&
              combinacao.codigoDeBarras.trim() == codigoNormalizado,
        );

    if (codigoDuplicado) {
      _mostrarMensagem('Código de barras já informado em outra combinação.');
      return;
    }

    setState(() {
      item.codigoDeBarras = codigoNormalizado;
    });
  }

  List<String> _obterCodigosDuplicados(List<_CombinacaoCadastro> combinacoes) {
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

class _CombinacaoCadastro {
  final Cor cor;
  final Tamanho tamanho;
  bool selecionada;
  String codigoDeBarras;

  _CombinacaoCadastro({
    required this.cor,
    required this.tamanho,
    this.selecionada = true,
    this.codigoDeBarras = '',
  });

  String get chave => gerarChave(cor, tamanho);

  static String gerarChave(Cor cor, Tamanho tamanho) {
    final corKey = cor.id?.toString() ?? cor.nome;
    final tamanhoKey = tamanho.id?.toString() ?? tamanho.nome;
    return '$corKey|$tamanhoKey';
  }
}
