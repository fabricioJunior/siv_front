import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:flutter/material.dart';

class SelecionarPermissaoModal extends StatefulWidget {
  static Future<List<Permissao>?> show(
    BuildContext context,
    List<Permissao> permissoes,
  ) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      useSafeArea: true,
      context: context,
      builder: (context) => SelecionarPermissaoModal(permissoes: permissoes),
    );
  }

  final List<Permissao> permissoes;
  const SelecionarPermissaoModal({required this.permissoes, super.key});

  @override
  State<SelecionarPermissaoModal> createState() =>
      _SelecionarPermissaoModalState();
}

class _SelecionarPermissaoModalState extends State<SelecionarPermissaoModal> {
  final Set<String> _categoriasExpandidas = <String>{};
  final Set<String> _selecionados = <String>{};
  final TextEditingController _buscaController = TextEditingController();
  bool _mostrarDescontinuados = false;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _toggleCategoria(String categoria) {
    setState(() {
      if (_categoriasExpandidas.contains(categoria)) {
        _categoriasExpandidas.remove(categoria);
      } else {
        _categoriasExpandidas.add(categoria);
      }
    });
  }

  void _toggleSelecionado(String id) {
    setState(() {
      if (_selecionados.contains(id)) {
        _selecionados.remove(id);
      } else {
        _selecionados.add(id);
      }
    });
  }

  void _toggleFluxo(List<Permissao> itensDoFluxo) {
    final todosSelecionados =
        itensDoFluxo.every((p) => _selecionados.contains(p.id));
    setState(() {
      if (todosSelecionados) {
        for (final p in itensDoFluxo) {
          _selecionados.remove(p.id);
        }
      } else {
        for (final p in itensDoFluxo) {
          _selecionados.add(p.id);
        }
      }
    });
  }

  // Acentos não deveriam importar na busca ("caixa" == "caixa" mas também
  // "consignacao" == "consignação"). Mesma tabela usada em
  // core/seletores/generic_seletor.dart -- duplicada aqui (arquivo
  // pequeno, sem justificar dependência cruzada de pacote só por isso).
  static const _comAcento =
      'àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ';
  static const _semAcento =
      'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';

  String _normalizar(String texto) {
    final buffer = StringBuffer();
    for (final codeUnit in texto.toLowerCase().runes) {
      final char = String.fromCharCode(codeUnit);
      final indice = _comAcento.indexOf(char);
      buffer.write(indice >= 0 ? _semAcento[indice] : char);
    }
    return buffer.toString();
  }

  Map<String, List<Permissao>> _permissoesFiltradas() {
    final busca = _normalizar(_buscaController.text.trim());

    final disponiveis = widget.permissoes.where((p) {
      if (!_mostrarDescontinuados && p.descontinuado) return false;
      if (busca.isEmpty) return true;
      return _normalizar(p.nomeExibicao).contains(busca) ||
          _normalizar(p.id).contains(busca);
    }).toList();

    return agruparPermissoesPorFluxo(disponiveis);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissoesClassificadas = _permissoesFiltradas();
    final buscando = _buscaController.text.trim().isNotEmpty;
    final totalDisponivel =
        permissoesClassificadas.values.fold<int>(0, (a, l) => a + l.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              BackButton(),
            ],
          ),
        ),
        Text(
          'Selecione as permissões',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar permissão...',
              border: const OutlineInputBorder(),
              suffixIcon: buscando
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _buscaController.clear(),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(
                    () => _mostrarDescontinuados = !_mostrarDescontinuados,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _mostrarDescontinuados,
                        onChanged: (value) => setState(
                          () => _mostrarDescontinuados = value ?? false,
                        ),
                      ),
                      const Text('Mostrar descontinuadas'),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_categoriasExpandidas.length ==
                        permissoesClassificadas.length) {
                      _categoriasExpandidas.clear();
                    } else {
                      _categoriasExpandidas
                        ..clear()
                        ..addAll(permissoesClassificadas.keys);
                    }
                  });
                },
                child: Text(
                  _categoriasExpandidas.length ==
                              permissoesClassificadas.length &&
                          permissoesClassificadas.isNotEmpty
                      ? 'Recolher tudo'
                      : 'Expandir tudo',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: permissoesClassificadas.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Nenhuma permissão encontrada.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final entry in permissoesClassificadas.entries) ...[
                      _fluxoHeader(context, entry.key, entry.value),
                      if (_categoriasExpandidas.contains(entry.key) || buscando)
                        ...entry.value.map(
                          (permissao) => _permissaoCard(context, permissao),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalDisponivel == widget.permissoes.length
                        ? '$totalDisponivel permissões disponíveis'
                        : '$totalDisponivel de ${widget.permissoes.length} permissões',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                FilledButton.icon(
                  key: const Key('adicionar_permissoes_selecionadas_button'),
                  onPressed: _selecionados.isEmpty
                      ? null
                      : () {
                          final selecionadas = widget.permissoes
                              .where((p) => _selecionados.contains(p.id))
                              .toList();
                          Navigator.of(context).pop(selecionadas);
                        },
                  icon: const Icon(Icons.add),
                  label: Text(
                    _selecionados.isEmpty
                        ? 'Adicionar'
                        : 'Adicionar (${_selecionados.length})',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fluxoHeader(
    BuildContext context,
    String fluxo,
    List<Permissao> itens,
  ) {
    final theme = Theme.of(context);
    final selecionadosNoFluxo =
        itens.where((p) => _selecionados.contains(p.id)).length;
    final tudoSelecionado =
        itens.isNotEmpty && selecionadosNoFluxo == itens.length;
    final algumSelecionado = selecionadosNoFluxo > 0;

    return InkWell(
      onTap: () => _toggleCategoria(fluxo),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
        child: Row(
          children: [
            Checkbox(
              tristate: true,
              value: tudoSelecionado ? true : (algumSelecionado ? null : false),
              onChanged: (_) => _toggleFluxo(itens),
            ),
            Expanded(
              child: Text(
                fluxo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                algumSelecionado
                    ? '$selecionadosNoFluxo/${itens.length}'
                    : '${itens.length}',
                style: theme.textTheme.labelSmall,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _categoriasExpandidas.contains(fluxo)
                  ? Icons.expand_less
                  : Icons.expand_more,
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissaoCard(BuildContext context, Permissao permissao) {
    final theme = Theme.of(context);
    final selecionado = _selecionados.contains(permissao.id);

    return InkWell(
      onTap: () => _toggleSelecionado(permissao.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: selecionado,
              onChanged: (_) => _toggleSelecionado(permissao.id),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permissao.nomeExibicao,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (permissao.descontinuado) ...[
                        Icon(
                          Icons.block,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Descontinuada · ${permissao.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ] else
                        Text(
                          permissao.id,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
