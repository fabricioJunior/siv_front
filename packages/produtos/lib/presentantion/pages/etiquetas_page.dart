import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class EtiquetasPage extends StatelessWidget {
  EtiquetasPage({super.key});

  final bloc = sl<EtiquetasBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EtiquetasBloc>(
      create: (_) => bloc..add(const EtiquetasIniciou()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Etiquetas')),
        floatingActionButton: BlocBuilder<EtiquetasBloc, EtiquetasState>(
          builder: (context, state) {
            final carregando =
                state is EtiquetasCriarEmProgresso ||
                state is EtiquetasExcluirEmProgresso;
            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () async {
                      final dadosIniciais = await _coletarDadosIniciaisEtiqueta(
                        context,
                      );

                      if (!context.mounted || dadosIniciais == null) {
                        return;
                      }

                      final resultado = await Navigator.of(context).pushNamed(
                        '/etiqueta_preview_page',
                        arguments: {
                          'retornarResultado': true,
                          'overrides': {
                            'nomeEtiqueta': dadosIniciais.nome,
                            'quantidadeVias':
                                dadosIniciais.quantidadeVias.toString(),
                          },
                        },
                      );

                      if (!context.mounted || resultado is! Map) {
                        return;
                      }

                      final nome =
                          (resultado['nome']?.toString() ?? dadosIniciais.nome)
                              .trim();
                      final altura = _toDouble(resultado['altura']);
                      final largura = _toDouble(resultado['largura']);
                      final dpi = EtiquetaDpiX.fromValue(resultado['dpi']);
                      final elementos = _toElementos(resultado['elementos']);
                      final vias = _toVias(
                        resultado['vias'],
                        fallbackQuantidade: dadosIniciais.quantidadeVias,
                        fallbackZpl: (resultado['zpl']?.toString() ?? '').trim(),
                      );

                      if (nome.isEmpty ||
                          altura == null ||
                          largura == null ||
                          elementos.isEmpty ||
                          vias.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dados invalidos retornados da etiqueta.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      context.read<EtiquetasBloc>().add(
                        EtiquetasCriarSolicitado(
                          nome: nome,
                          altura: altura,
                          largura: largura,
                          dpi: dpi,
                          elementos: elementos,
                          vias: vias,
                        ),
                      );
                    },
              child: carregando
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : const Icon(Icons.add),
            );
          },
        ),
        body: BlocConsumer<EtiquetasBloc, EtiquetasState>(
          listener: (context, state) {
            if (state is EtiquetasCarregarFalha) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Falha ao carregar etiquetas.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is EtiquetasCriarSucesso) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Etiqueta criada com sucesso.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is EtiquetasCriarFalha) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Falha ao criar etiqueta.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is EtiquetasExcluirSucesso) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Etiqueta excluida com sucesso.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is EtiquetasExcluirFalha) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Falha ao excluir etiqueta.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is EtiquetasCarregarEmProgresso && state.etiquetas.isEmpty) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is EtiquetasCarregarFalha && state.etiquetas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erro ao carregar etiquetas.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<EtiquetasBloc>().add(const EtiquetasIniciou());
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (state.etiquetas.isEmpty) {
              return const Center(
                child: Text('Nenhuma etiqueta criada. Clique em + para criar.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final etiqueta = state.etiquetas[index];
                return Card(
                  child: ListTile(
                    title: Text(etiqueta.nome),
                    subtitle: Text(
                      'L ${etiqueta.largura.toStringAsFixed(1)} mm  •  A ${etiqueta.altura.toStringAsFixed(1)} mm  •  ${etiqueta.vias.length} via(s)  •  ${etiqueta.dpi.valor} DPI',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          onPressed: () async {
                            final resultado = await Navigator.of(context).pushNamed(
                              '/etiqueta_preview_page',
                              arguments: {
                                'retornarResultado': true,
                                'overrides': {
                                  ..._buildOverridesFromEtiqueta(etiqueta),
                                },
                              },
                            );

                            if (!context.mounted || resultado is! Map) {
                              return;
                            }

                            final nome =
                                (resultado['nome']?.toString() ?? etiqueta.nome)
                                    .trim();
                            final altura = _toDouble(resultado['altura']);
                            final largura = _toDouble(resultado['largura']);
                            final dpi = EtiquetaDpiX.fromValue(resultado['dpi']);
                            final elementos = _toElementos(resultado['elementos']);
                            final vias = _toVias(
                              resultado['vias'],
                              fallbackQuantidade: etiqueta.vias.length,
                              fallbackZpl: '',
                            );

                            if (nome.isEmpty ||
                                altura == null ||
                                largura == null ||
                                elementos.isEmpty ||
                                vias.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dados invalidos retornados da etiqueta.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            context.read<EtiquetasBloc>().add(
                              EtiquetasCriarSolicitado(
                                nome: nome,
                                altura: altura,
                                largura: largura,
                                dpi: dpi,
                                elementos: elementos,
                                vias: vias,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _showDeleteConfirmation(context, etiqueta),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: state.etiquetas.length,
            );
          },
        ),
      ),
    );
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.').trim());
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  List<EtiquetaElemento> _toElementos(dynamic value) {
    if (value is! List) {
      return const <EtiquetaElemento>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => EtiquetaElemento.create(
            nome: item['nome']?.toString().trim() ?? '',
            tipoElemento: TipoElementoEtiquetaX.fromValue(item['tipoElemento']),
            x: _toDouble(item['x']) ?? 0,
            y: _toDouble(item['y']) ?? 0,
          ),
        )
        .where((item) => item.nome.isNotEmpty)
        .toList(growable: false);
  }

  List<EtiquetaVia> _toVias(
    dynamic value, {
    required int fallbackQuantidade,
    required String fallbackZpl,
  }) {
    if (value is List) {
      final vias = value
          .whereType<Map>()
          .map(
            (item) => EtiquetaVia.create(
              ordem: _toInt(item['ordem']) ?? 0,
              zpl: item['zpl']?.toString().trim() ?? '',
            ),
          )
          .where((via) => via.zpl.isNotEmpty)
          .toList(growable: false)
        ..sort((a, b) => a.ordem.compareTo(b.ordem));

      if (vias.isNotEmpty) {
        return vias;
      }
    }

    if (fallbackZpl.isEmpty) {
      return const <EtiquetaVia>[];
    }

    return List<EtiquetaVia>.generate(
      fallbackQuantidade < 1 ? 1 : fallbackQuantidade,
      (index) => EtiquetaVia.create(ordem: index, zpl: fallbackZpl),
      growable: false,
    );
  }

  Map<String, String> _buildOverridesFromEtiqueta(Etiqueta etiqueta) {
    final overrides = <String, String>{
      'nomeEtiqueta': etiqueta.nome,
      'larguraEtiquetaMm': etiqueta.largura.toString(),
      'alturaEtiquetaMm': etiqueta.altura.toString(),
      'quantidadeVias': etiqueta.vias.length.toString(),
      'dpi': etiqueta.dpi.valor.toString(),
    };

    for (final elemento in etiqueta.elementos) {
      overrides['${elemento.nome}Xmm'] = elemento.x.toString();
      overrides['${elemento.nome}Ymm'] = elemento.y.toString();
      overrides[elemento.nome] = '{${elemento.nome}}';
    }

    return overrides;
  }

  Future<_DadosEtiquetaInicial?> _coletarDadosIniciaisEtiqueta(
    BuildContext context,
  ) async {
    return showDialog<_DadosEtiquetaInicial>(
      context: context,
      builder: (_) => const _DadosEtiquetaInicialDialog(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Etiqueta etiqueta) {
    final idEtiqueta = etiqueta.id;
    if (idEtiqueta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etiqueta sem ID nao pode ser excluida.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir etiqueta'),
        content: Text('Deseja excluir a etiqueta "${etiqueta.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<EtiquetasBloc>().add(
                EtiquetasExcluirSolicitado(id: idEtiqueta),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _DadosEtiquetaInicial {
  final String nome;
  final int quantidadeVias;

  const _DadosEtiquetaInicial({
    required this.nome,
    required this.quantidadeVias,
  });
}

class _DadosEtiquetaInicialDialog extends StatefulWidget {
  const _DadosEtiquetaInicialDialog();

  @override
  State<_DadosEtiquetaInicialDialog> createState() =>
      _DadosEtiquetaInicialDialogState();
}

class _DadosEtiquetaInicialDialogState extends State<_DadosEtiquetaInicialDialog> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova etiqueta'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da etiqueta',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da etiqueta.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantidade de vias',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final quantidade = int.tryParse(value?.trim() ?? '');
                if (quantidade == null || quantidade < 1) {
                  return 'Informe uma quantidade valida (>= 1).';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _DadosEtiquetaInicial(
                nome: _nomeController.text.trim(),
                quantidadeVias: int.parse(_quantidadeController.text.trim()),
              ),
            );
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
