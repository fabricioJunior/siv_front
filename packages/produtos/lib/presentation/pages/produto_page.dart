import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ProdutoPage extends StatefulWidget {
  final Produto? produto;

  const ProdutoPage({super.key, this.produto});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _referenciaIdController = TextEditingController();
  final _idExternoController = TextEditingController();
  final _corController = TextEditingController();
  final _tamanhoController = TextEditingController();
  late final ProdutoBloc _bloc;
  bool _camposHidratados = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProdutoBloc>()..add(ProdutoIniciou(produto: widget.produto));
  }

  @override
  void dispose() {
    _referenciaIdController.dispose();
    _idExternoController.dispose();
    _corController.dispose();
    _tamanhoController.dispose();
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
          if (!_camposHidratados &&
              (state.produtoStep == ProdutoStep.carregado ||
                  state.produtoStep == ProdutoStep.editando)) {
            _hidratatCamposComState(state);
            _camposHidratados = true;
          }

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
              floatingActionButton: FloatingActionButton.extended(
                onPressed: carregando ? null : () => _salvar(context, state),
                icon: carregando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(carregando ? 'Salvando...' : 'Salvar'),
              ),
              body: SafeArea(
                child: carregando && !_camposHidratados
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.id != null) ...[
                                TextFormField(
                                  initialValue: state.id!.toString(),
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'ID',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _referenciaIdController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Referência ID',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  context.read<ProdutoBloc>().add(
                                    ProdutoEditou(
                                      referenciaId: int.tryParse(value.trim()),
                                    ),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe referência ID';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Referência ID inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _idExternoController,
                                decoration: const InputDecoration(
                                  labelText: 'ID Externo',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  context.read<ProdutoBloc>().add(
                                    ProdutoEditou(idExterno: value),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe ID externo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildCorAutocomplete(context, state),
                              const SizedBox(height: 12),
                              _buildTamanhoAutocomplete(context, state),
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCorAutocomplete(BuildContext context, ProdutoState state) {
    return Autocomplete<Cor>(
      initialValue: TextEditingValue(text: _corController.text),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return state.cores;
        }
        return state.cores.where(
          (cor) => cor.nome.toLowerCase().contains(query),
        );
      },
      displayStringForOption: (cor) => cor.nome,
      onSelected: (cor) {
        _corController.text = cor.nome;
        context.read<ProdutoBloc>().add(ProdutoEditou(corId: cor.id));
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        if (textController.text != _corController.text) {
          textController.text = _corController.text;
          textController.selection = TextSelection.collapsed(
            offset: textController.text.length,
          );
        }

        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Cor (Autocomplete)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _corController.text = value;
            final match = _findCorByNome(state.cores, value);
            context.read<ProdutoBloc>().add(ProdutoEditou(corId: match?.id));
          },
          validator: (_) {
            if (state.corId == null) {
              return 'Selecione uma cor';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildTamanhoAutocomplete(BuildContext context, ProdutoState state) {
    return Autocomplete<Tamanho>(
      initialValue: TextEditingValue(text: _tamanhoController.text),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return state.tamanhos;
        }
        return state.tamanhos.where(
          (tamanho) => tamanho.nome.toLowerCase().contains(query),
        );
      },
      displayStringForOption: (tamanho) => tamanho.nome,
      onSelected: (tamanho) {
        _tamanhoController.text = tamanho.nome;
        context.read<ProdutoBloc>().add(ProdutoEditou(tamanhoId: tamanho.id));
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        if (textController.text != _tamanhoController.text) {
          textController.text = _tamanhoController.text;
          textController.selection = TextSelection.collapsed(
            offset: textController.text.length,
          );
        }

        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Tamanho (Autocomplete)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _tamanhoController.text = value;
            final match = _findTamanhoByNome(state.tamanhos, value);
            context.read<ProdutoBloc>().add(
              ProdutoEditou(tamanhoId: match?.id),
            );
          },
          validator: (_) {
            if (state.tamanhoId == null) {
              return 'Selecione um tamanho';
            }
            return null;
          },
        );
      },
    );
  }

  Future<void> _salvar(BuildContext context, ProdutoState state) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProdutoBloc>().add(ProdutoSalvou());
  }

  void _hidratatCamposComState(ProdutoState state) {
    _referenciaIdController.text = state.referenciaId?.toString() ?? '';
    _idExternoController.text = state.idExterno;

    final cor = _findCorById(state.cores, state.corId);
    final tamanho = _findTamanhoById(state.tamanhos, state.tamanhoId);

    _corController.text = cor?.nome ?? '';
    _tamanhoController.text = tamanho?.nome ?? '';
  }

  Cor? _findCorById(List<Cor> cores, int? id) {
    if (id == null) return null;
    for (final cor in cores) {
      if (cor.id == id) return cor;
    }
    return null;
  }

  Tamanho? _findTamanhoById(List<Tamanho> tamanhos, int? id) {
    if (id == null) return null;
    for (final tamanho in tamanhos) {
      if (tamanho.id == id) return tamanho;
    }
    return null;
  }

  Cor? _findCorByNome(List<Cor> cores, String nome) {
    for (final cor in cores) {
      if (cor.nome == nome) return cor;
    }
    return null;
  }

  Tamanho? _findTamanhoByNome(List<Tamanho> tamanhos, String nome) {
    for (final tamanho in tamanhos) {
      if (tamanho.nome == nome) return tamanho;
    }
    return null;
  }
}
