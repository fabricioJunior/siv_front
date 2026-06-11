import 'package:estoque/presentation/bloc/balanco/balanco_bloc.dart';
import 'package:core/bloc.dart';
import 'package:flutter/material.dart';

class AdicionarItensBalancoPage extends StatefulWidget {
  final int balancoId;

  const AdicionarItensBalancoPage({Key? key, required this.balancoId})
    : super(key: key);

  @override
  State<AdicionarItensBalancoPage> createState() =>
      _AdicionarItensBalancoPageState();
}

class _AdicionarItensBalancoPageState extends State<AdicionarItensBalancoPage> {
  late TextEditingController _buscarReferenciaController;
  final List<int> _referenciasSelecionadas = [];
  final Map<int, _ReferenciaSelecionadaInfo> _referenciasInfo =
      <int, _ReferenciaSelecionadaInfo>{};

  @override
  void initState() {
    super.initState();
    _buscarReferenciaController = TextEditingController();
  }

  @override
  void dispose() {
    _buscarReferenciaController.dispose();
    super.dispose();
  }

  void _adicionarReferencia() {
    if (_buscarReferenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite um ID de referência')),
      );
      return;
    }

    try {
      final referenciaId = int.parse(_buscarReferenciaController.text);
      if (_referenciasSelecionadas.contains(referenciaId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referência já foi adicionada')),
        );
        return;
      }

      setState(() {
        _referenciasSelecionadas.add(referenciaId);
        _referenciasInfo.remove(referenciaId);
      });
      _buscarReferenciaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ID de referência inválido: $e')));
    }
  }

  void _confirmarSelecao() {
    if (_referenciasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma referência')),
      );
      return;
    }

    context.read<BalancoBloc>().add(
      AdicionarMultiplosItensAoBalancoEvent(
        balancoId: widget.balancoId,
        referenciaIds: _referenciasSelecionadas,
      ),
    );
  }

  Future<void> _abrirSeletorDeReferencias() async {
    final resultado = await Navigator.of(context).pushNamed(
      '/selecionar_referencias',
      arguments: {'idsSelecionados': _referenciasSelecionadas},
    );

    if (!mounted || resultado == null) {
      return;
    }

    if (resultado is! List) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retorno inválido do seletor de referências'),
        ),
      );
      return;
    }

    final infoPorId = <int, _ReferenciaSelecionadaInfo>{};

    final ids =
        resultado
            .map((e) {
              if (e is int) {
                return e;
              }

              if (e is Map) {
                final dynamic idRaw = e['id'];
                final id = idRaw is int
                    ? idRaw
                    : int.tryParse(idRaw?.toString() ?? '');

                if (id != null) {
                  final nome = e['nome']?.toString();
                  final descricao = e['descricao']?.toString();
                  infoPorId[id] = _ReferenciaSelecionadaInfo(
                    id: id,
                    nome: nome,
                    descricao: descricao,
                  );
                }

                return id;
              }

              return int.tryParse(e.toString());
            })
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();

    setState(() {
      _referenciasSelecionadas
        ..clear()
        ..addAll(ids);
      _referenciasInfo
        ..clear()
        ..addAll(infoPorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Itens')),
      body: BlocListener<BalancoBloc, BalancoState>(
        listener: (context, state) {
          if (state is BalancoItemsAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Itens adicionados com sucesso')),
            );
            Navigator.of(context).pop();
          } else if (state is BalancoError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seleção de referências',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _abrirSeletorDeReferencias,
                          icon: const Icon(Icons.checklist_outlined),
                          label: const Text('Selecionar Referências em Lote'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _buscarReferenciaController,
                        decoration: InputDecoration(
                          labelText: 'ID da Referência',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _adicionarReferencia,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _adicionarReferencia(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.list_alt, size: 18),
                            label: Text(
                              '${_referenciasSelecionadas.length} selecionada(s)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _referenciasSelecionadas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 52,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma referência selecionada',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use a seleção em lote ou informe um ID de referência para adicionar itens ao balanço.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: _referenciasSelecionadas.length,
                      itemBuilder: (context, index) {
                        final referenciaId = _referenciasSelecionadas[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                              child: Text('${index + 1}'),
                            ),
                            title: Text('Referência #$referenciaId'),
                            subtitle: Builder(
                              builder: (_) {
                                final info = _referenciasInfo[referenciaId];
                                final descricao = info?.descricao?.trim();
                                final nome = info?.nome?.trim();

                                if (descricao != null && descricao.isNotEmpty) {
                                  return Text(descricao);
                                }

                                if (nome != null && nome.isNotEmpty) {
                                  return Text(nome);
                                }

                                return const Text('Sem descrição disponível');
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  final removedId =
                                      _referenciasSelecionadas[index];
                                  _referenciasSelecionadas.removeAt(index);
                                  _referenciasInfo.remove(removedId);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BlocBuilder<BalancoBloc, BalancoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state is BalancoLoading
                          ? null
                          : _confirmarSelecao,
                      icon: state is BalancoLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.done_all_outlined),
                      label: Text(
                        state is BalancoLoading
                            ? 'Adicionando itens...'
                            : 'Confirmar Adição',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenciaSelecionadaInfo {
  final int id;
  final String? nome;
  final String? descricao;

  const _ReferenciaSelecionadaInfo({
    required this.id,
    this.nome,
    this.descricao,
  });
}
