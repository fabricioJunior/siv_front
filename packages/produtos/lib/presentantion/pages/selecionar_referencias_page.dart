import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

class ReferenciaSelecionadaResultado {
  final int id;
  final String nome;
  final String? descricao;

  const ReferenciaSelecionadaResultado({
    required this.id,
    required this.nome,
    this.descricao,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
  };
}

class SelecionarReferenciasPage extends StatefulWidget {
  final List<int> idsSelecionadosIniciais;

  const SelecionarReferenciasPage({
    super.key,
    this.idsSelecionadosIniciais = const [],
  });

  @override
  State<SelecionarReferenciasPage> createState() =>
      _SelecionarReferenciasPageState();
}

class _SelecionarReferenciasPageState extends State<SelecionarReferenciasPage> {
  final TextEditingController _buscaController = TextEditingController();
  late final RecuperarReferencias _recuperarReferencias;

  final Set<int> _idsSelecionados = <int>{};
  List<Referencia> _referencias = const <Referencia>[];
  bool _carregando = true;
  String? _erro;
  String? _grupoSelecionado;

  @override
  void initState() {
    super.initState();
    _recuperarReferencias = sl<RecuperarReferencias>();
    _idsSelecionados.addAll(widget.idsSelecionadosIniciais);
    _carregarReferencias();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarReferencias() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final referencias = await _recuperarReferencias();
      if (!mounted) {
        return;
      }

      setState(() {
        _referencias = referencias;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
        _erro = 'Erro ao carregar referências.';
      });
    }
  }

  void _toggleReferencia(int referenciaId) {
    setState(() {
      if (_idsSelecionados.contains(referenciaId)) {
        _idsSelecionados.remove(referenciaId);
      } else {
        _idsSelecionados.add(referenciaId);
      }
    });
  }

  void _selecionarTodasFiltradas(List<Referencia> referenciasFiltradas) {
    final ids = referenciasFiltradas.map((e) => e.id).whereType<int>();
    setState(() {
      _idsSelecionados.addAll(ids);
    });
  }

  void _removerTodas() {
    setState(() {
      _idsSelecionados.clear();
    });
  }

  void _retornarSelecao() {
    final referenciasPorId = <int, Referencia>{
      for (final referencia in _referencias)
        if (referencia.id != null) referencia.id!: referencia,
    };
    final idsOrdenados = _idsSelecionados.toList()..sort();
    final resultado = idsOrdenados
        .map((id) {
          final referencia = referenciasPorId[id];
          return ReferenciaSelecionadaResultado(
            id: id,
            nome: referencia?.nome ?? '',
            descricao: referencia?.descricao,
          ).toJson();
        })
        .toList(growable: false);
    Navigator.of(context).pop(resultado);
  }

  String _grupoDaReferencia(Referencia referencia) {
    final categoria = referencia.categoria?.nome.trim();
    if (categoria != null && categoria.isNotEmpty) {
      return categoria;
    }

    return 'Sem grupo';
  }

  List<String> _gruposDisponiveis() {
    final grupos = _referencias.map(_grupoDaReferencia).toSet().toList()
      ..sort();
    return grupos;
  }

  List<Referencia> _referenciasFiltradas() {
    final busca = _buscaController.text.trim().toLowerCase();

    return _referencias.where((referencia) {
      final passaGrupo =
          _grupoSelecionado == null ||
          _grupoDaReferencia(referencia) == _grupoSelecionado;

      if (!passaGrupo) {
        return false;
      }

      if (busca.isEmpty) {
        return true;
      }

      final nome = referencia.nome.toLowerCase();
      final descricao = (referencia.descricao ?? '').toLowerCase();
      return nome.contains(busca) || descricao.contains(busca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final referenciasFiltradas = _referenciasFiltradas();
    final grupos = _gruposDisponiveis();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Referências'),
        actions: [
          TextButton(
            onPressed: _retornarSelecao,
            child: const Text('Concluir'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  SearchBar(
                    controller: _buscaController,
                    hintText: 'Buscar por nome ou descrição da referência',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _grupoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por grupo',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todos os grupos'),
                      ),
                      ...grupos.map(
                        (grupo) => DropdownMenuItem<String?>(
                          value: grupo,
                          child: Text(grupo),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _grupoSelecionado = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: referenciasFiltradas.isEmpty
                        ? null
                        : () => _selecionarTodasFiltradas(referenciasFiltradas),
                    child: const Text('Selecionar Todos'),
                  ),
                  TextButton(
                    onPressed: _idsSelecionados.isEmpty ? null : _removerTodas,
                    child: const Text('Remover todas'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.checklist, size: 18),
                  const SizedBox(width: 8),
                  Text('Selecionadas: ${_idsSelecionados.length}'),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (_carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (_erro != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(_erro!),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _carregarReferencias,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (referenciasFiltradas.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma referência encontrada para os filtros informados.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: referenciasFiltradas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final referencia = referenciasFiltradas[index];
                      final referenciaId = referencia.id;
                      final selecionada =
                          referenciaId != null &&
                          _idsSelecionados.contains(referenciaId);

                      return CheckboxListTile(
                        value: selecionada,
                        onChanged: referenciaId == null
                            ? null
                            : (_) => _toggleReferencia(referenciaId),
                        title: Text(referencia.nome),
                        subtitle: Text(
                          'ID: ${referencia.id ?? '-'} | Grupo: ${_grupoDaReferencia(referencia)}${(referencia.descricao != null && referencia.descricao!.isNotEmpty) ? '\n${referencia.descricao}' : ''}',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _retornarSelecao,
                  icon: const Icon(Icons.done),
                  label: const Text('Confirmar seleção'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Deprecated('Use SelecionarReferenciasPage')
class SelecionarReferenciasBalancoPage extends SelecionarReferenciasPage {
  const SelecionarReferenciasBalancoPage({
    super.key,
    super.idsSelecionadosIniciais,
  });
}
