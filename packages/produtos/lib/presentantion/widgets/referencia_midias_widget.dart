import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/modals/referencia_midia_metadados_modal.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentantion/widgets/tamanho_seletor.dart';
import '../bloc/referencia_midias_bloc/referencia_midias_bloc.dart';

const int _limiteMaximoMidias = 20;
const _duracaoTransicaoSuave = Duration(milliseconds: 280);
const _curvaTransicaoSuave = Curves.easeOutCubic;

Widget _transicaoSuave(Widget child, Animation<double> animation) {
  final animacaoCurva = CurvedAnimation(
    parent: animation,
    curve: _curvaTransicaoSuave,
  );

  return FadeTransition(
    opacity: animacaoCurva,
    child: SizeTransition(
      sizeFactor: animacaoCurva,
      axisAlignment: -1,
      child: child,
    ),
  );
}

class ReferenciaMidiasWidget extends StatelessWidget {
  final int referenciaId;
  final bool permiteEditar;

  const ReferenciaMidiasWidget({
    super.key,
    required this.referenciaId,
    this.permiteEditar = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReferenciaMidiasBloc>()..add(ReferenciasIniciou(referenciaId)),
      child: BlocBuilder<ReferenciaMidiasBloc, ReferenciaMidiasState>(
        builder: (context, state) {
          final carregando = state.carregando;
          final midias = state.midias;
          final uploadsPendentes = state.uploadsPendentes;
          final totalMidias = midias.length + uploadsPendentes.length;
          final limiteAtingido = totalMidias >= _limiteMaximoMidias;
          final progressoMedioUpload = uploadsPendentes.isEmpty
              ? 0.0
              : uploadsPendentes.fold<double>(
                      0,
                      (total, item) => total + item.progresso,
                    ) /
                    uploadsPendentes.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: _duracaoTransicaoSuave,
                    transitionBuilder: _transicaoSuave,
                    child: Text(
                      'Mídias ($totalMidias/$_limiteMaximoMidias)',
                      key: ValueKey(totalMidias),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: _duracaoTransicaoSuave,
                    switchInCurve: _curvaTransicaoSuave,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: _transicaoSuave,
                    child: carregando
                        ? const SizedBox(
                            key: ValueKey('midias_loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : permiteEditar
                        ? IconButton(
                            key: const ValueKey('midias_add_button'),
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: limiteAtingido
                                ? null
                                : () => _adicionarMidia(context),
                            tooltip: limiteAtingido
                                ? 'Limite de imagens atingido'
                                : 'Adicionar imagem',
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('midias_no_action'),
                          ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: _duracaoTransicaoSuave,
                transitionBuilder: _transicaoSuave,
                child: state is ReferenciaMidiasErro
                    ? Padding(
                        key: ValueKey(state.mensagem),
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          state.mensagem,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('sem_erro_midias')),
              ),
              const SizedBox(height: 8),
              AnimatedSize(
                duration: _duracaoTransicaoSuave,
                curve: _curvaTransicaoSuave,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: _duracaoTransicaoSuave,
                      transitionBuilder: _transicaoSuave,
                      child: uploadsPendentes.isNotEmpty
                          ? Padding(
                              key: ValueKey(
                                'uploads_${uploadsPendentes.length}',
                              ),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MidiasUploadEmAndamento(
                                uploadsPendentes: uploadsPendentes,
                                progressoMedio: progressoMedioUpload,
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('sem_uploads_pendentes'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: _duracaoTransicaoSuave,
                      switchInCurve: _curvaTransicaoSuave,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: _transicaoSuave,
                      child:
                          midias.isEmpty &&
                              uploadsPendentes.isEmpty &&
                              !carregando
                          ? KeyedSubtree(
                              key: const ValueKey('midias_empty_state'),
                              child: _MidiasEmptyState(
                                limiteAtingido: limiteAtingido,
                                permiteEditar: permiteEditar,
                                onAdicionar: () => _adicionarMidia(context),
                              ),
                            )
                          : midias.isNotEmpty
                          ? KeyedSubtree(
                              key: ValueKey('midias_carousel_${midias.length}'),
                              child: _MidiasCarousel(
                                midias: midias,
                                permiteEditar: permiteEditar,
                                onRemover: (midiaId) =>
                                    _removerMidia(context, midiaId),
                                onEditar: (midia, ePrincipal, ePublica) =>
                                    _atualizarMidia(
                                      context,
                                      midia,
                                      ePrincipal,
                                      ePublica,
                                    ),
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('midias_placeholder'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _adicionarMidia(BuildContext context) async {
    if (!permiteEditar) return;

    final bloc = context.read<ReferenciaMidiasBloc>();
    final state = bloc.state;
    final total = state.midias.length + state.uploadsPendentes.length;

    if (total >= _limiteMaximoMidias) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Limite de $_limiteMaximoMidias imagens atingido para esta referência.',
          ),
        ),
      );
      return;
    }

    final picked = await showSelecionarImagemModal(
      context,
      allowMultiple: true,
    );
    if (!context.mounted || picked == null || picked.isEmpty) return;

    final vagasRestantes = _limiteMaximoMidias - total;
    final imagensSelecionadas = picked.take(vagasRestantes).toList();

    if (picked.length > vagasRestantes && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Somente $vagasRestantes imagem(ns) puderam ser adicionadas por causa do limite.',
          ),
        ),
      );
    }

    final imagensParaRevisao = imagensSelecionadas
        .map(
          (imagem) => Imagem(
            path: imagem.path,
            bytes: imagem.bytes,
            field: 'file',
            descricao: imagem.descricao,
          ),
        )
        .toList(growable: false);

    // ignore: use_build_context_synchronously
    final metadados = await ReferenciaMidiaMetadadosModal.show(
      context,
      imagens: imagensParaRevisao,
    );
    if (!context.mounted || metadados == null || metadados.imagens.isEmpty) {
      return;
    }

    bloc.add(ReferenciasMidiaAdicinou(referenciaId, metadados.imagens));
  }

  void _removerMidia(BuildContext context, int midiaId) {
    if (!permiteEditar) return;

    context.read<ReferenciaMidiasBloc>().add(
      ReferenciaMidiasRemoveu(referenciaId, midiaId),
    );
  }

  void _atualizarMidia(
    BuildContext context,
    ReferenciaMidia midia,
    bool ePrincipal,
    bool ePublica,
  ) {
    if (!permiteEditar) return;

    context.read<ReferenciaMidiasBloc>().add(
      ReferenciaMidiasAtualizou(
        referenciaId: referenciaId,
        midia: midia,
        ePrincipal: ePrincipal,
        ePublica: ePublica,
      ),
    );
  }
}

class _MidiasEmptyState extends StatelessWidget {
  final bool limiteAtingido;
  final bool permiteEditar;
  final VoidCallback onAdicionar;

  const _MidiasEmptyState({
    required this.limiteAtingido,
    required this.permiteEditar,
    required this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          const Text(
            'Nenhuma mídia cadastrada',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            permiteEditar
                ? 'Adicione imagens para facilitar a visualização da referência.'
                : 'Visualização apenas. A edição de mídias está desabilitada nesta página.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          if (permiteEditar) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: limiteAtingido ? null : onAdicionar,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Adicionar mídia'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MidiasUploadEmAndamento extends StatelessWidget {
  final List<MidiaUploadPendente> uploadsPendentes;
  final double progressoMedio;

  const _MidiasUploadEmAndamento({
    required this.uploadsPendentes,
    required this.progressoMedio,
  });

  @override
  Widget build(BuildContext context) {
    final percentualGeral = (progressoMedio.clamp(0.0, 1.0) * 100).round();

    return AnimatedContainer(
      duration: _duracaoTransicaoSuave,
      curve: _curvaTransicaoSuave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: _duracaoTransicaoSuave,
                  transitionBuilder: _transicaoSuave,
                  child: Text(
                    'Enviando ${uploadsPendentes.length} imagem(ns) • $percentualGeral%',
                    key: ValueKey(percentualGeral),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progressoMedio.clamp(0.0, 1.0)),
              duration: _duracaoTransicaoSuave,
              curve: _curvaTransicaoSuave,
              builder: (context, valor, _) {
                return LinearProgressIndicator(
                  value: valor == 0 ? null : valor,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: uploadsPendentes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 260,
                  child: _MidiaUploadCard(upload: uploadsPendentes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MidiaUploadCard extends StatelessWidget {
  final MidiaUploadPendente upload;

  const _MidiaUploadCard({required this.upload});

  @override
  Widget build(BuildContext context) {
    final progresso = upload.progresso.clamp(0.0, 1.0).toDouble();
    final nomeArquivo = (upload.imagem.path ?? upload.imagem.url ?? 'imagem')
        .split(RegExp(r'[/\\]'))
        .last;

    return AnimatedContainer(
      duration: _duracaoTransicaoSuave,
      curve: _curvaTransicaoSuave,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: upload.imagem.bytes != null
                            ? Image.memory(
                                upload.imagem.bytes!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: Icon(Icons.image_outlined, size: 40),
                                ),
                              ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: _duracaoTransicaoSuave,
                        opacity: progresso >= 1 ? 0.12 : 1,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black26),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          value: progresso > 0 && progresso < 1
                              ? progresso
                              : null,
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nomeArquivo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (upload.imagem.descricao?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    upload.imagem.descricao!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              if (upload.imagem.cor?.isNotEmpty == true ||
                  upload.imagem.tamanho?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (upload.imagem.cor?.isNotEmpty == true)
                        Chip(
                          label: Text('Cor: ${upload.imagem.cor}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (upload.imagem.tamanho?.isNotEmpty == true)
                        Chip(
                          label: Text('Tamanho: ${upload.imagem.tamanho}'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progresso),
                duration: _duracaoTransicaoSuave,
                curve: _curvaTransicaoSuave,
                builder: (context, valor, _) {
                  return LinearProgressIndicator(
                    value: valor > 0 ? valor : null,
                  );
                },
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: _duracaoTransicaoSuave,
                transitionBuilder: _transicaoSuave,
                child: Text(
                  upload.status,
                  key: ValueKey(upload.status),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MidiasCarousel extends StatefulWidget {
  final List<ReferenciaMidia> midias;
  final bool permiteEditar;
  final void Function(int midiaId) onRemover;
  final void Function(ReferenciaMidia midia, bool ePrincipal, bool ePublica)
  onEditar;

  const _MidiasCarousel({
    required this.midias,
    required this.permiteEditar,
    required this.onRemover,
    required this.onEditar,
  });

  @override
  State<_MidiasCarousel> createState() => _MidiasCarouselState();
}

class _MidiasCarouselState extends State<_MidiasCarousel> {
  late PageController _pageController;
  double _viewportFraction = 1;
  int _paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  double _calcularViewportFraction(double larguraDisponivel) {
    if (larguraDisponivel >= 1200) return 0.33;
    if (larguraDisponivel >= 900) return 0.45;
    if (larguraDisponivel >= 700) return 0.60;
    return 0.92;
  }

  void _atualizarViewportFractionSeNecessario(double larguraDisponivel) {
    final novaFraction = _calcularViewportFraction(larguraDisponivel);
    if ((novaFraction - _viewportFraction).abs() < 0.001) return;

    final pagina = _paginaAtual;
    _viewportFraction = novaFraction;
    _pageController.dispose();
    _pageController = PageController(
      initialPage: pagina,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void didUpdateWidget(covariant _MidiasCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ultimaPagina = widget.midias.length - 1;
    if (widget.midias.isEmpty) {
      _paginaAtual = 0;
      return;
    }

    if (_paginaAtual > ultimaPagina) {
      _paginaAtual = ultimaPagina;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_paginaAtual);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _atualizarViewportFractionSeNecessario(constraints.maxWidth);

        return Column(
          children: [
            SizedBox(
              height: 240,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                ),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  padEnds: false,
                  itemCount: widget.midias.length,
                  onPageChanged: (index) {
                    setState(() {
                      _paginaAtual = index;
                    });
                  },
                  itemBuilder: (context, i) {
                    final midia = widget.midias[i];
                    return Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _MidiaCarouselCard(
                            key: ValueKey(midia.id),
                            midia: midia,
                            permiteEditar: widget.permiteEditar,
                            onRemover: () => widget.onRemover(midia.id),
                            onEditar: widget.onEditar,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.midias.length, (index) {
                final selecionado = index == _paginaAtual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selecionado ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _MidiaCarouselCard extends StatelessWidget {
  final ReferenciaMidia midia;
  final bool permiteEditar;
  final VoidCallback onRemover;
  final void Function(ReferenciaMidia midia, bool ePrincipal, bool ePublica)
  onEditar;

  const _MidiaCarouselCard({
    super.key,
    required this.midia,
    required this.permiteEditar,
    required this.onRemover,
    required this.onEditar,
  });

  void _abrirVisualizacaoTelaCheia(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: ImagemViewWidget(
                    url: midia.url,
                    onlyFromCache: false,
                    cacheKey: midia.id.toString(),
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  tooltip: 'Fechar',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirEdicaoMidia(BuildContext context) async {
    var ePrincipal = midia.ePrincipal;
    var ePublica = midia.ePublica;
    var corSelecionada = midia.cor;
    var tamanhoSelecionado = midia.tamanho;
    final descricaoController = TextEditingController(text: midia.descricao);

    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final nomeArquivo = midia.url.split('/').last;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + mediaQuery.viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editar mídia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.black12,
                          child: ImagemViewWidget(
                            url: midia.url,
                            onlyFromCache: false,
                            cacheKey: midia.id.toString(),
                            placeholder: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nomeArquivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Ex: Vista frontal, detalhe do bordado...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 12),
                      CorSeletor(
                        modo: CorSeletorModo.unica,
                        titulo: 'Cor (opcional)',
                        coresSelecionadasIniciais: corSelecionada == null
                            ? const []
                            : [_CorTemporaria(nome: corSelecionada!)],
                        onCorChanged: (cores) {
                          setModalState(() {
                            corSelecionada = cores.firstOrNull?.nome;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TamanhoSeletor(
                        modo: TamanhoSeletorModo.unica,
                        titulo: 'Tamanho (opcional)',
                        tamanhosSelecionadosIniciais: tamanhoSelecionado == null
                            ? const []
                            : [_TamanhoTemporario(nome: tamanhoSelecionado!)],
                        onTamanhosChanged: (tamanhos) {
                          setModalState(() {
                            tamanhoSelecionado = tamanhos.firstOrNull?.nome;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Imagem padrão'),
                        subtitle: const Text(
                          'Define esta mídia como padrão da referência.',
                        ),
                        value: ePrincipal,
                        onChanged: (value) {
                          setModalState(() {
                            ePrincipal = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Imagem pública'),
                        subtitle: const Text(
                          'Controla se esta mídia é visível publicamente.',
                        ),
                        value: ePublica,
                        onChanged: (value) {
                          setModalState(() {
                            ePublica = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (salvo == true) {
      final descricao = descricaoController.text.trim();
      final midiaAtualizada = ReferenciaMidia.create(
        id: midia.id,
        url: midia.url,
        referenciaId: midia.referenciaId,
        ePrincipal: ePrincipal,
        ePublica: ePublica,
        descricao: descricao.isEmpty ? null : descricao,
        cor: corSelecionada,
        tamanho: tamanhoSelecionado,
      );
      onEditar(midiaAtualizada, ePrincipal, ePublica);
    }

    descricaoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _abrirVisualizacaoTelaCheia(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 170,
                  color: Colors.black12,
                  child: ImagemViewWidget(
                    url: midia.url,
                    key: ValueKey('midia_${midia.id}_${midia.url}'),
                    onlyFromCache: false,
                    cacheKey: midia.id.toString(),
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            if (permiteEditar)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: () => _abrirEdicaoMidia(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            if (permiteEditar)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemover,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            if (midia.ePrincipal)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        if (midia.descricao?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              midia.descricao!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (midia.cor?.isNotEmpty == true || midia.tamanho?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (midia.cor?.isNotEmpty == true)
                  Chip(
                    label: Text('Cor: ${midia.cor}'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (midia.tamanho?.isNotEmpty == true)
                  Chip(
                    label: Text('Tamanho: ${midia.tamanho}'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CorTemporaria implements Cor {
  @override
  final int? id = null;

  @override
  final bool? inativo = false;

  @override
  final String nome;

  const _CorTemporaria({required this.nome});

  @override
  List<Object?> get props => [id, nome, inativo];

  @override
  bool? get stringify => true;
}

class _TamanhoTemporario implements Tamanho {
  @override
  final int? id = null;

  @override
  final bool inativo = false;

  @override
  final String nome;

  const _TamanhoTemporario({required this.nome});

  @override
  List<Object?> get props => [id, nome, inativo];

  @override
  bool? get stringify => true;
}
