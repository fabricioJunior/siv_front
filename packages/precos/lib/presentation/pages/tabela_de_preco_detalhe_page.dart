import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';

class TabelaDePrecoDetalhePage extends StatefulWidget {
  final int idTabelaDePreco;
  const TabelaDePrecoDetalhePage({super.key, required this.idTabelaDePreco});

  @override
  State<TabelaDePrecoDetalhePage> createState() =>
      _TabelaDePrecoDetalhePageState();
}

class _TabelaDePrecoDetalhePageState extends State<TabelaDePrecoDetalhePage> {
  final _formTabelaKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _terminadorController = TextEditingController();
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String _busca = '';
  _OrdenacaoPreco _ordenacaoSelecionada = _OrdenacaoPreco.referenciaAsc;

  @override
  void dispose() {
    _nomeController.dispose();
    _terminadorController.dispose();
    _buscaController.dispose();
    _debouncer.cancel();
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

        final precosFiltrados = _filtrarPrecos(state.precos);
        final precosOrdenados = _ordenarPrecos(precosFiltrados);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.price_check_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preços da Tabela',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${precosOrdenados.length} de ${state.precos.length} itens',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _buscaController,
                      onChanged: (value) {
                        _debouncer.run(() {
                          if (!mounted) return;
                          setState(() => _busca = value.trim());
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Buscar por referência ou ID',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _busca.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _buscaController.clear();
                                  setState(() => _busca = '');
                                },
                                icon: const Icon(Icons.close),
                                tooltip: 'Limpar busca',
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<_OrdenacaoPreco>(
                          tooltip: 'Ordenar preços',
                          onSelected: (ordenacao) {
                            setState(() => _ordenacaoSelecionada = ordenacao);
                          },
                          itemBuilder: (context) =>
                              _OrdenacaoPreco.values.map((ordenacao) {
                                return PopupMenuItem<_OrdenacaoPreco>(
                                  value: ordenacao,
                                  child: Row(
                                    children: [
                                      if (_ordenacaoSelecionada == ordenacao)
                                        const Icon(Icons.check, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Text(ordenacao.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                          child: Row(
                            children: [
                              const Icon(Icons.sort, size: 18),
                              const SizedBox(width: 6),
                              Text(_ordenacaoSelecionada.label),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (precosOrdenados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Nenhum preço encontrado para o filtro informado.',
                  ),
                ),
              ...precosOrdenados.map((preco) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: const Icon(Icons.sell_outlined),
                  ),
                  title: Text(preco.referenciaNome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Ref: ${preco.referenciaIdExterno} (ID ${preco.referenciaId})',
                      ),
                      const SizedBox(height: 2),

                      Text(
                        'Atualizado: ${_formatarDataHora(preco.atualizadoEm)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        preco.valor.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar preço',
                        onPressed: () => _abrirEdicaoPreco(context, preco),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<PrecoDaReferencia> _filtrarPrecos(List<PrecoDaReferencia> precos) {
    if (_busca.isEmpty) {
      return precos;
    }

    final termo = _busca.toLowerCase();
    return precos.where((preco) {
      final nome = preco.referenciaNome.toLowerCase();
      final id = preco.referenciaId.toString();
      final idExterno = preco.referenciaIdExterno.toLowerCase();

      return nome.contains(termo) ||
          id.contains(termo) ||
          idExterno.contains(termo);
    }).toList();
  }

  List<PrecoDaReferencia> _ordenarPrecos(List<PrecoDaReferencia> precos) {
    final lista = [...precos];
    lista.sort((a, b) {
      int comparacao;
      switch (_ordenacaoSelecionada) {
        case _OrdenacaoPreco.referenciaAsc:
          comparacao = a.referenciaNome.toLowerCase().compareTo(
            b.referenciaNome.toLowerCase(),
          );
          break;
        case _OrdenacaoPreco.referenciaDesc:
          comparacao = b.referenciaNome.toLowerCase().compareTo(
            a.referenciaNome.toLowerCase(),
          );
          break;
        case _OrdenacaoPreco.valorAsc:
          comparacao = a.valor.compareTo(b.valor);
          break;
        case _OrdenacaoPreco.valorDesc:
          comparacao = b.valor.compareTo(a.valor);
          break;
        case _OrdenacaoPreco.atualizadoEmAsc:
          comparacao = (a.atualizadoEm ?? DateTime(0)).compareTo(
            b.atualizadoEm ?? DateTime(0),
          );
          break;
        case _OrdenacaoPreco.atualizadoEmDesc:
          comparacao = (b.atualizadoEm ?? DateTime(0)).compareTo(
            a.atualizadoEm ?? DateTime(0),
          );
          break;
      }

      if (comparacao == 0) {
        comparacao = a.referenciaId.compareTo(b.referenciaId);
      }
      return comparacao;
    });
    return lista;
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) return '';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto';
  }

  Future<void> _abrirEdicaoPreco(
    BuildContext context,
    PrecoDaReferencia preco,
  ) async {
    final atualizou = await Navigator.of(context).pushNamed(
      '/preco_da_referencia_page',
      arguments: {
        'tabelaDePrecoId': widget.idTabelaDePreco,
        'referenciaId': preco.referenciaId,
        'referenciaNome': preco.referenciaNome,
        'valorInicial': preco.valor,
      },
    );

    if (atualizou == true && context.mounted) {
      context.read<PrecosDaTabelaBloc>().add(
        PrecosDaTabelaIniciou(tabelaDePrecoId: widget.idTabelaDePreco),
      );
    }
  }

  bool _possuiAteDuasCasas(String value) {
    return RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(value.trim());
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}

enum _OrdenacaoPreco {
  referenciaAsc('Referência (A-Z)'),
  referenciaDesc('Referência (Z-A)'),
  valorAsc('Valor (menor primeiro)'),
  valorDesc('Valor (maior primeiro)'),
  atualizadoEmAsc('Atualizado em (mais antigo)'),
  atualizadoEmDesc('Atualizado em (mais recente)');

  final String label;
  const _OrdenacaoPreco(this.label);
}
