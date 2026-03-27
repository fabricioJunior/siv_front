import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation.dart';

class TabelaDePrecoDetalhePage extends StatefulWidget {
  final int idTabelaDePreco;
  final ISeletor referenciaSeletor;
  const TabelaDePrecoDetalhePage({
    super.key,
    required this.idTabelaDePreco,
    required this.referenciaSeletor,
  });

  @override
  State<TabelaDePrecoDetalhePage> createState() =>
      _TabelaDePrecoDetalhePageState();
}

class _TabelaDePrecoDetalhePageState extends State<TabelaDePrecoDetalhePage> {
  final _formTabelaKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _terminadorController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _terminadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabelaDePrecoBloc>(
          create: (context) => sl<TabelaDePrecoBloc>()
            ..add(
              TabelaDePrecoIniciou(idTabelaDePreco: widget.idTabelaDePreco),
            ),
        ),
        BlocProvider<PrecosDaTabelaBloc>(
          create: (context) => sl<PrecosDaTabelaBloc>()
            ..add(
              PrecosDaTabelaIniciou(tabelaDePrecoId: widget.idTabelaDePreco),
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TabelaDePrecoBloc, TabelaDePrecoState>(
            listener: (context, state) {
              if (state.nome != null && _nomeController.text != state.nome) {
                _nomeController.text = state.nome!;
              }
              if (state.terminador != null &&
                  _terminadorController.text != state.terminador.toString()) {
                _terminadorController.text = state.terminador.toString();
              }
              if (state.tabelaDePrecoStep == TabelaDePrecoStep.salvo) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tabela de preço salva.')),
                );
              }
            },
          ),
          BlocListener<PrecosDaTabelaBloc, PrecosDaTabelaState>(
            listener: (context, state) {
              if (state.erro != null && state.erro!.isNotEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.erro!)));
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: const Text('Tabela de Preço')),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () async {
                final adicionou = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => PrecoDaReferenciaPage(
                      tabelaDePrecoId: widget.idTabelaDePreco,
                      referenciaSeletor: widget.referenciaSeletor,
                    ),
                  ),
                );
                if (adicionou == true && context.mounted) {
                  context.read<PrecosDaTabelaBloc>().add(
                    PrecosDaTabelaIniciou(
                      tabelaDePrecoId: widget.idTabelaDePreco,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar preço'),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<TabelaDePrecoBloc>().add(
                  TabelaDePrecoIniciou(idTabelaDePreco: widget.idTabelaDePreco),
                );
                context.read<PrecosDaTabelaBloc>().add(
                  PrecosDaTabelaIniciou(
                    tabelaDePrecoId: widget.idTabelaDePreco,
                  ),
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _buildCardTabela(),
                  const SizedBox(height: 12),
                  _buildListaPrecos(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTabela() {
    return BlocBuilder<TabelaDePrecoBloc, TabelaDePrecoState>(
      builder: (context, state) {
        final carregando =
            state.tabelaDePrecoStep == TabelaDePrecoStep.carregando;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formTabelaKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dados da Tabela',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeController,
                    enabled: !carregando,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome da tabela';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _terminadorController,
                    enabled: !carregando,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Terminador (opcional)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (!_possuiAteDuasCasas(value)) {
                        return 'Use no máximo 2 casas decimais';
                      }
                      if (_parseDouble(value) == null) {
                        return 'Informe um número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: carregando
                          ? null
                          : () {
                              if (!(_formTabelaKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              context.read<TabelaDePrecoBloc>().add(
                                TabelaDePrecoEditou(
                                  nome: _nomeController.text.trim(),
                                  terminador: _parseDouble(
                                    _terminadorController.text,
                                  ),
                                ),
                              );
                              context.read<TabelaDePrecoBloc>().add(
                                TabelaDePreceSalvou(),
                              );
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar tabela'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaPrecos() {
    return BlocBuilder<PrecosDaTabelaBloc, PrecosDaTabelaState>(
      builder: (context, state) {
        if (state.step == PrecosDaTabelaStep.carregando) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        if (state.precos.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhum preço cadastrado para esta tabela.'),
            ),
          );
        }

        return Card(
          child: Column(
            children: state.precos.map((preco) {
              return ListTile(
                title: Text(preco.referenciaNome),
                subtitle: Text(
                  'Ref: ${preco.referenciaIdExterno} (ID ${preco.referenciaId})',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    Text(
                      preco.valor.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => _abrirEdicaoPreco(context, preco),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () =>
                          _confirmarRemocao(context, preco.referenciaId),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _abrirEdicaoPreco(BuildContext context, dynamic preco) async {
    final controller = TextEditingController(
      text: preco.valor.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar preço'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(labelText: 'Valor'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o valor';
                }
                if (!_possuiAteDuasCasas(value)) {
                  return 'Use no máximo 2 casas decimais';
                }
                if (_parseDouble(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                context.read<PrecosDaTabelaBloc>().add(
                  PrecoDaTabelaAtualizarSolicitado(
                    referenciaId: preco.referenciaId,
                    valor: _parseDouble(controller.text)!,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _confirmarRemocao(BuildContext context, int referenciaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover preço'),
          content: const Text('Deseja remover este preço da tabela?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    context.read<PrecosDaTabelaBloc>().add(
      PrecoDaTabelaRemoverSolicitado(referenciaId: referenciaId),
    );
  }

  bool _possuiAteDuasCasas(String value) {
    return RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(value.trim());
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
