import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

/// Visualizador de foto em tela cheia (modal por cima da lista).
/// [onContar] = "CONTAR ESTA" (lista). [onAssociar] = "É ESTA" (Associar).
Future<void> showFotoAmpliada(
  BuildContext context, {
  required String referenciaNome,
  required String referenciaCodigo,
  required List<ReferenciaMidiaSimples> fotos,
  int indiceInicial = 0,
  VoidCallback? onContar,
  VoidCallback? onAssociar,
}) {
  assert(fotos.isNotEmpty);
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar foto',
    barrierColor: Colors.black87,
    pageBuilder: (ctx, _, __) => _FotoAmpliadaPage(
      referenciaNome: referenciaNome,
      referenciaCodigo: referenciaCodigo,
      fotos: fotos,
      indiceInicial: indiceInicial,
      onContar: onContar,
      onAssociar: onAssociar,
    ),
  );
}

class _FotoAmpliadaPage extends StatefulWidget {
  final String referenciaNome;
  final String referenciaCodigo;
  final List<ReferenciaMidiaSimples> fotos;
  final int indiceInicial;
  final VoidCallback? onContar;
  final VoidCallback? onAssociar;

  const _FotoAmpliadaPage({
    required this.referenciaNome,
    required this.referenciaCodigo,
    required this.fotos,
    required this.indiceInicial,
    this.onContar,
    this.onAssociar,
  });

  @override
  State<_FotoAmpliadaPage> createState() => _FotoAmpliadaPageState();
}

class _FotoAmpliadaPageState extends State<_FotoAmpliadaPage> {
  late final PageController _controller;
  late int _atual;

  @override
  void initState() {
    super.initState();
    _atual = widget.indiceInicial.clamp(0, widget.fotos.length - 1);
    _controller = PageController(initialPage: _atual);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _rotuloOrigem(ReferenciaMidiaSimples foto) {
    if (foto.doFornecedor) return 'FOTO DO FORNECEDOR';
    if (foto.daChegada) return 'TIRADA NA CHEGADA';
    return 'FOTO DA REFERÊNCIA';
  }

  Color _corOrigem(ReferenciaMidiaSimples foto) {
    if (foto.doFornecedor) return const Color(0xFF34495E);
    if (foto.daChegada) return const Color(0xFF416180);
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final foto = widget.fotos[_atual];
    final total = widget.fotos.length;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            // cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.referenciaNome,
                          style: textos.corpo.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.referenciaCodigo,
                          style: textos.apoio.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // selo de origem + posição
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _corOrigem(foto),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _rotuloOrigem(foto),
                      style: textos.rotulo.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (total > 1)
                    Text(
                      '${_atual + 1} de $total',
                      style: textos.apoio.copyWith(color: Colors.white70),
                    ),
                ],
              ),
            ),
            // viewer principal com setas
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: total,
                    onPageChanged: (i) => setState(() => _atual = i),
                    itemBuilder: (ctx, i) => InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Center(
                        child: Image.network(
                          widget.fotos[i].url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (total > 1) ...[
                    if (_atual > 0)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: Colors.white, size: 36),
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                    if (_atual < total - 1)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.white, size: 36),
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            // miniaturas
            if (total > 1)
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: total,
                  itemBuilder: (ctx, i) {
                    final selecionada = i == _atual;
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: selecionada
                                ? Colors.white
                                : Colors.white24,
                            width: selecionada ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.network(
                            widget.fotos[i].urlParaMiniatura,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // botões de ação
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('VOLTAR À LISTA'),
                    ),
                  ),
                  if (widget.onContar != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onContar!();
                        },
                        child: const Text('CONTAR ESTA'),
                      ),
                    ),
                  ],
                  if (widget.onAssociar != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onAssociar!();
                        },
                        child: const Text('É ESTA'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
