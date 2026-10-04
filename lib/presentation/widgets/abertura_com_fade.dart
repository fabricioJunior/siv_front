import 'dart:async';

import 'package:flutter/material.dart';

/// Transição da abertura: a tela de carregamento não "corta seco" -- ela some com
/// fade, deixando o conteúdo já montado por baixo.
///
/// Não é um `AnimatedSwitcher` de propósito: o conteúdo (AppShell + Navigator, que
/// usa `GlobalKey`) existe uma única vez, sem uma segunda cópia durante a
/// transição -- e a carga continua NÃO montando o conteúdo (o Navigator só sobe
/// depois que a inicialização termina, como sempre foi).
///
/// - só [carregando]: mostra a carga.
/// - só [conteudo]: mostra o conteúdo; se a carga acabou de sair, ela fica por cima
///   esmaecendo por [duracao] e depois é removida.
/// - os dois: o conteúdo já está montado e a carga continua **opaca por cima**
///   (segurada, p.ex. até a navegação inicial terminar, pra não mostrar a tela
///   de login um instante antes de ir pra home). Some com fade quando [carregando]
///   vira null, ou sozinha depois de [tempoMaximo] (nunca fica presa).
class AberturaComFade extends StatefulWidget {
  final Widget? carregando;
  final Widget? conteudo;
  final Duration duracao;
  final Duration tempoMaximo;

  const AberturaComFade({
    super.key,
    this.carregando,
    this.conteudo,
    this.duracao = const Duration(milliseconds: 250),
    this.tempoMaximo = const Duration(seconds: 3),
  }) : assert(
         carregando != null || conteudo != null,
         'Informe carregando e/ou conteudo',
       );

  @override
  State<AberturaComFade> createState() => _AberturaComFadeState();
}

class _AberturaComFadeState extends State<AberturaComFade> {
  Widget? _saindo;
  Timer? _limite;
  bool _liberada = false;

  bool get _segurando => widget.carregando != null && widget.conteudo != null;

  @override
  void initState() {
    super.initState();
    _armarLimite();
  }

  @override
  void didUpdateWidget(AberturaComFade antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.carregando != null && widget.carregando == null) {
      _saindo = MediaQuery.disableAnimationsOf(context)
          ? null
          : antigo.carregando;
      _cancelarLimite();
    } else if (widget.carregando != null) {
      _saindo = null;
    }
    if (!_segurando) {
      _cancelarLimite();
    } else if (antigo.conteudo == null) {
      _armarLimite(); // começou a segurar agora
    }
  }

  void _armarLimite() {
    if (!_segurando || _limite != null) return;
    _liberada = false;
    _limite = Timer(widget.tempoMaximo, () {
      if (mounted) setState(() => _liberada = true);
    });
  }

  void _cancelarLimite() {
    _limite?.cancel();
    _limite = null;
    _liberada = false;
  }

  @override
  void dispose() {
    _limite?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Segurada além do limite: some com fade como se tivesse sido liberada.
    final carga = _liberada ? null : widget.carregando;
    final saindo = _liberada && widget.carregando != null
        ? widget.carregando
        : _saindo;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.conteudo != null)
          KeyedSubtree(
            key: const ValueKey('abertura_conteudo'),
            child: widget.conteudo!,
          ),
        if (carga != null)
          KeyedSubtree(key: const ValueKey('abertura_carga'), child: carga)
        else if (saindo != null)
          IgnorePointer(
            key: const ValueKey('abertura_saindo'),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: widget.duracao,
              curve: Curves.easeOut,
              onEnd: () {
                if (mounted) setState(() => _saindo = null);
              },
              child: saindo,
              builder: (context, opacidade, filho) =>
                  Opacity(opacity: opacidade, child: filho),
            ),
          ),
      ],
    );
  }
}
