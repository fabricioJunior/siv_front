import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/modals/referencia_midia_metadados_modal.dart';
import '../bloc/referencia_midias_bloc/referencia_midias_bloc.dart';

const int _limiteMaximoMidias = 20;

class ReferenciaMidiasWidget extends StatelessWidget {
  final int referenciaId;

  const ReferenciaMidiasWidget({super.key, required this.referenciaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReferenciaMidiasBloc>()..add(ReferenciasIniciou(referenciaId)),
      child: BlocBuilder<ReferenciaMidiasBloc, ReferenciaMidiasState>(
        builder: (context, state) {
          final carregando = state is ReferenciaMidiasCarregando;
          final midias = state is ReferenciaMidiasCarregado
              ? state.midias
              : <ReferenciaMidia>[];
          final limiteAtingido = midias.length >= _limiteMaximoMidias;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mídias (${midias.length}/$_limiteMaximoMidias)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (carregando)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: limiteAtingido
                          ? null
                          : () => _adicionarMidia(context),
                      tooltip: limiteAtingido
                          ? 'Limite de imagens atingido'
                          : 'Adicionar imagem',
                    ),
                ],
              ),
              if (state is ReferenciaMidiasErro)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.mensagem,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (midias.isEmpty && !carregando)
                _MidiasEmptyState(
                  limiteAtingido: limiteAtingido,
                  onAdicionar: () => _adicionarMidia(context),
                ),
              if (midias.isNotEmpty)
                _MidiasCarousel(
                  midias: midias,
                  onRemover: (midiaId) => _removerMidia(context, midiaId),
                  onEditar: (midia, ePrincipal, ePublica) =>
                      _atualizarMidia(context, midia, ePrincipal, ePublica),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _adicionarMidia(BuildContext context) async {
    final bloc = context.read<ReferenciaMidiasBloc>();
    final state = bloc.state;
    final total = state is ReferenciaMidiasCarregado ? state.midias.length : 0;

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

    final picked = await showSelecionarImagemModal(context);
    if (picked == null || picked.isEmpty) return;

    // Metadados opcionais: descrição livre + cor e tamanho associados
    // ignore: use_build_context_synchronously
    final metadados = await ReferenciaMidiaMetadadosModal.show(context);
    if (metadados == null) return; // usuário cancelou

    final cor = metadados.cor;
    final tamanho = metadados.tamanho;

    // Monta a field key usando cor_tamanho com underscore como separador

    final imagem = Imagem(
      path: picked.first.path,
      bytes: picked.first.bytes,
      field: 'image',
      descricao: metadados.descricao,
    );

    bloc.add(
      ReferenciasMidiaAdicinou(
        referenciaId,
        [imagem],
        cor: cor?.nome,
        tamanho: tamanho?.nome,
      ),
    );
  }

  void _removerMidia(BuildContext context, int midiaId) {
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
  final VoidCallback onAdicionar;

  const _MidiasEmptyState({
    required this.limiteAtingido,
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
            'Adicione imagens para facilitar a visualização da referência.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: limiteAtingido ? null : onAdicionar,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Adicionar mídia'),
          ),
        ],
      ),
    );
  }
}

class _MidiasCarousel extends StatefulWidget {
  final List<ReferenciaMidia> midias;
  final void Function(int midiaId) onRemover;
  final void Function(ReferenciaMidia midia, bool ePrincipal, bool ePublica)
  onEditar;

  const _MidiasCarousel({
    required this.midias,
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
              height: 210,
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
                            onRemover: () => widget.onRemover(midia.id),
                            onEditar: (ePrincipal, ePublica) =>
                                widget.onEditar(midia, ePrincipal, ePublica),
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
  final VoidCallback onRemover;
  final void Function(bool ePrincipal, bool ePublica) onEditar;

  const _MidiaCarouselCard({
    super.key,
    required this.midia,
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

    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar configurações da mídia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
            );
          },
        );
      },
    );

    if (salvo == true) {
      onEditar(ePrincipal, ePublica);
    }
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
                    key: UniqueKey(),
                    onlyFromCache: false,
                    cacheKey: midia.id.toString(),
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
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
      ],
    );
  }
}
