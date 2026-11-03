import 'dart:typed_data';

import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart';
import 'package:produtos/presentantion/modals/referencia_midia_metadados_modal.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_formato.dart';
import 'package:produtos/presentantion/widgets/consulta/foto_editar_sheet.dart';
import 'package:produtos/presentantion/widgets/consulta/fotos_ordem.dart';

/// Fotos da referência na tela de consulta: reordenar (a primeira é a capa), editar,
/// excluir, selecionar e compartilhar/baixar. Usa o mesmo [ReferenciaMidiasBloc] do cadastro.
class ConsultaFotos extends StatelessWidget {
  final int referenciaId;
  final String nomeReferencia;
  final List<ProdutoDaGrade> produtos;

  const ConsultaFotos({
    super.key,
    required this.referenciaId,
    required this.nomeReferencia,
    required this.produtos,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferenciaMidiasBloc>()..add(ReferenciasIniciou(referenciaId)),
      child: _Corpo(
        referenciaId: referenciaId,
        nomeReferencia: nomeReferencia,
        opcoes: OpcoesAssociacaoFoto(produtos),
      ),
    );
  }
}

class _Corpo extends StatefulWidget {
  final int referenciaId;
  final String nomeReferencia;
  final OpcoesAssociacaoFoto opcoes;

  const _Corpo({
    required this.referenciaId,
    required this.nomeReferencia,
    required this.opcoes,
  });

  @override
  State<_Corpo> createState() => _CorpoState();
}

class _CorpoState extends State<_Corpo> {
  final _selecionadas = <int>{};
  final _bytes = <int, Uint8List>{};
  final _baixando = <int>{};

  ReferenciaMidiasBloc get _bloc => context.read<ReferenciaMidiasBloc>();
  bool get _desktop => MediaQuery.sizeOf(context).width >= larguraDesktopConsulta;

  /// Pré-carrega os arquivos: o share do iOS não aceita `await` antes da chamada.
  void _preCarregar(List<ReferenciaMidia> midias) {
    final servico = sl<CompartilharService>();
    for (final m in midias) {
      if (_bytes.containsKey(m.id) || !_baixando.add(m.id)) continue;
      servico.baixar(m.url).then((b) {
        if (mounted) _bytes[m.id] = b;
      }).catchError((_) {});
    }
  }

  Future<void> _adicionar(int total) async {
    if (total >= limiteFotosPorReferencia) {
      _aviso('Limite de $limiteFotosPorReferencia fotos atingido.');
      return;
    }
    final bloc = _bloc;
    final escolhidas = await showSelecionarImagemModal(context, allowMultiple: true);
    if (!mounted || escolhidas == null || escolhidas.isEmpty) return;
    final vagas = limiteFotosPorReferencia - total;
    if (escolhidas.length > vagas) _aviso('Somente $vagas foto(s) couberam no limite.');
    final meta = await ReferenciaMidiaMetadadosModal.show(
      context,
      imagens: [
        for (final i in escolhidas.take(vagas)) Imagem(path: i.path, bytes: i.bytes, field: 'file'),
      ],
      opcoes: widget.opcoes,
    );
    if (meta == null || meta.imagens.isEmpty) return;
    bloc.add(ReferenciasMidiaAdicinou(widget.referenciaId, meta.imagens, validarAssociacao: true));
  }

  Future<void> _editar(ReferenciaMidia m) async {
    final bloc = _bloc;
    final r = await FotoEditarSheet.show(context, midia: m, opcoes: widget.opcoes);
    if (r == null) return;
    if (r.acao == FotoEdicaoAcao.excluir) {
      bloc.add(ReferenciaMidiasRemoveu(widget.referenciaId, m.id));
      return;
    }
    bloc.add(ReferenciaMidiasAtualizou(
      referenciaId: widget.referenciaId,
      midia: ReferenciaMidia.create(
        id: m.id,
        url: m.url,
        referenciaId: m.referenciaId,
        ePrincipal: m.ePrincipal,
        ePublica: m.ePublica,
        descricao: r.descricao,
        cor: r.associacao.cor,
        estampa: r.associacao.estampa,
        tamanho: r.associacao.tamanho,
      ),
      ePrincipal: m.ePrincipal,
      ePublica: m.ePublica,
      validarAssociacao: true,
    ));
  }

  void _mover(List<int> ids, int de, int para) {
    if (para < 0 || para >= ids.length || de == para) return;
    _bloc.add(ReferenciaMidiasReordenou(widget.referenciaId, reordenarIds(ids, de, para)));
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  List<ArquivoParaCompartilhar>? _arquivosSelecionados(List<ReferenciaMidia> midias) {
    final arquivos = <ArquivoParaCompartilhar>[];
    var n = 0;
    for (final m in midias.where((m) => _selecionadas.contains(m.id))) {
      final b = _bytes[m.id];
      if (b == null) return null;
      arquivos.add(ArquivoParaCompartilhar(
        nome: nomeArquivoFoto(widget.nomeReferencia, m.associacao, ++n),
        bytes: b,
      ));
    }
    return arquivos;
  }

  /// Sem `await` antes do share (exigência do iOS): os bytes já estão em memória.
  void _compartilhar(List<ReferenciaMidia> midias) {
    final arquivos = _arquivosSelecionados(midias);
    if (arquivos == null) {
      _aviso('Fotos ainda carregando, tente novamente em instantes.');
      return;
    }
    final servico = sl<CompartilharService>();
    if (servico.suportaCompartilharArquivos) {
      servico
          .compartilhar(arquivos: arquivos, texto: widget.nomeReferencia)
          .catchError((_) => _baixar(arquivos));
    } else {
      _baixar(arquivos);
    }
  }

  Future<void> _baixar(List<ArquivoParaCompartilhar> arquivos) async {
    final n = await sl<ArquivoService>().salvarVarios({
      for (final a in arquivos) a.nome: a.bytes,
    });
    if (mounted && n > 0) _aviso('$n foto(s) salva(s).');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ReferenciaMidiasBloc, ReferenciaMidiasState>(
      listener: (_, s) {
        _selecionadas.removeWhere((id) => !s.midias.any((m) => m.id == id));
        _preCarregar(s.midias);
      },
      builder: (context, state) {
        final midias = [for (final m in state.midias) if (!m.doFornecedor) m];
        final total = midias.length + state.uploadsPendentes.length;
        final ids = [for (final m in midias) m.id];
        final desktop = _desktop;
        final compartilha = sl<CompartilharService>().suportaCompartilharArquivos;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Fotos ($total/$limiteFotosPorReferencia)', style: theme.textTheme.titleSmall),
                ),
                if (state.carregando)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    tooltip: 'Adicionar fotos',
                    icon: const Icon(Icons.add_a_photo_outlined),
                    onPressed: total >= limiteFotosPorReferencia ? null : () => _adicionar(total),
                  ),
              ],
            ),
            if (state is ReferenciaMidiasErro)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(state.mensagem, style: TextStyle(color: theme.colorScheme.error)),
              ),
            if (state.uploadsPendentes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Enviando ${state.uploadsPendentes.length} foto(s)…'),
              ),
            if (_selecionadas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${_selecionadas.length} selecionada(s)'),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _compartilhar(midias),
                      icon: Icon(compartilha ? Icons.share : Icons.download),
                      label: Text(compartilha ? 'Compartilhar' : 'Baixar'),
                    ),
                    TextButton(
                      onPressed: () => setState(_selecionadas.clear),
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              ),
            if (midias.isEmpty && !state.carregando)
              Text('Nenhuma foto cadastrada.', style: theme.textTheme.bodyMedium)
            else
              SizedBox(
                height: desktop ? 310 : 330,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: midias.length,
                  onReorder: (de, para) => _mover(ids, de, para > de ? para - 1 : para),
                  itemBuilder: (context, i) {
                    final m = midias[i];
                    final tile = FotoTile(
                      key: ValueKey('foto-${m.id}'),
                      midia: m,
                      capa: i == 0,
                      selecionada: _selecionadas.contains(m.id),
                      desktop: desktop,
                      podeEsquerda: i > 0,
                      podeDireita: i < midias.length - 1,
                      onSelecionar: () => setState(() {
                        if (!_selecionadas.remove(m.id)) _selecionadas.add(m.id);
                      }),
                      onEditar: () => _editar(m),
                      onExcluir: () => _bloc.add(ReferenciaMidiasRemoveu(widget.referenciaId, m.id)),
                      onMover: (delta) => _mover(ids, i, i + delta),
                    );
                    return desktop
                        ? ReorderableDragStartListener(key: ValueKey('drag-${m.id}'), index: i, child: tile)
                        : ReorderableDelayedDragStartListener(key: ValueKey('drag-${m.id}'), index: i, child: tile);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class FotoTile extends StatefulWidget {
  final ReferenciaMidia midia;
  final bool capa;
  final bool selecionada;
  final bool desktop;
  final bool podeEsquerda;
  final bool podeDireita;
  final VoidCallback onSelecionar;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final ValueChanged<int> onMover;

  const FotoTile({
    super.key,
    required this.midia,
    required this.capa,
    required this.selecionada,
    required this.desktop,
    required this.podeEsquerda,
    required this.podeDireita,
    required this.onSelecionar,
    required this.onEditar,
    required this.onExcluir,
    required this.onMover,
  });

  @override
  State<FotoTile> createState() => _FotoTileState();
}

class _FotoTileState extends State<FotoTile> {
  bool _confirmando = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final a = widget.midia.associacao;
    final aviso = a.avisoFalta;

    return SizedBox(
      width: 168,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: widget.onSelecionar,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.selecionada ? cs.primary : cs.outlineVariant,
                        width: widget.selecionada ? 3 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ImagemViewWidget(
                      url: widget.midia.url,
                      onlyFromCache: false,
                      cacheKey: widget.midia.id.toString(),
                      placeholder: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                if (widget.capa)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Chip(
                      label: const Text('Capa'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: cs.primaryContainer,
                    ),
                  ),
                if (widget.selecionada)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Icon(Icons.check_circle, color: cs.primary),
                  ),
                if (widget.desktop && !_confirmando)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: widget.onEditar,
                        ),
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => setState(() => _confirmando = true),
                        ),
                      ],
                    ),
                  ),
                if (_confirmando)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Excluir esta foto?'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: cs.error),
                                onPressed: widget.onExcluir,
                                child: const Text('Excluir'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => setState(() => _confirmando = false),
                                child: const Text('Não'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.desktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Mover para a esquerda',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: widget.podeEsquerda ? () => widget.onMover(-1) : null,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Mover para a direita',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: widget.podeDireita ? () => widget.onMover(1) : null,
                  ),
                ],
              ),
            Text(a.resumo, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
            if (aviso != null)
              Text(
                aviso,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            if (!widget.desktop)
              TextButton(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: widget.onEditar,
                child: Text(aviso != null ? 'Completar' : 'Editar'),
              )
            else if (aviso != null)
              TextButton(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: widget.onEditar,
                child: const Text('Completar'),
              ),
          ],
        ),
      ),
    );
  }
}
