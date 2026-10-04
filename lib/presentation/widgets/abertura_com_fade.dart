import 'package:flutter/material.dart';

/// Transição da abertura: quando a tela de carregamento termina, ela some com
/// fade (em vez de "cortar seco") deixando o conteúdo já montado por baixo.
///
/// Não é um `AnimatedSwitcher` de propósito: o conteúdo (AppShell + Navigator, que
/// usa `GlobalKey`) existe uma única vez, sem uma segunda cópia durante a
/// transição -- e a carga continua NÃO montando o conteúdo (o Navigator só sobe
/// depois que a inicialização termina, como sempre foi).
///
/// - [carregando] != null: mostra só a carga.
/// - [conteudo] != null: mostra o conteúdo; se a carga acabou de sair, ela fica por
///   cima esmaecendo por [duracao] e depois é removida.
class AberturaComFade extends StatefulWidget {
  final Widget? carregando;
  final Widget? conteudo;
  final Duration duracao;

  const AberturaComFade({
    super.key,
    this.carregando,
    this.conteudo,
    this.duracao = const Duration(milliseconds: 250),
  }) : assert(
         (carregando == null) != (conteudo == null),
         'Informe carregando OU conteudo',
       );

  @override
  State<AberturaComFade> createState() => _AberturaComFadeState();
}

class _AberturaComFadeState extends State<AberturaComFade> {
  Widget? _saindo;

  @override
  void didUpdateWidget(AberturaComFade antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.carregando != null && widget.carregando == null) {
      _saindo = MediaQuery.disableAnimationsOf(context)
          ? null
          : antigo.carregando;
    } else if (widget.carregando != null) {
      _saindo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.conteudo != null)
          KeyedSubtree(
            key: const ValueKey('abertura_conteudo'),
            child: widget.conteudo!,
          ),
        if (widget.carregando != null)
          KeyedSubtree(
            key: const ValueKey('abertura_carga'),
            child: widget.carregando!,
          )
        else if (_saindo != null)
          IgnorePointer(
            key: const ValueKey('abertura_saindo'),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: widget.duracao,
              curve: Curves.easeOut,
              onEnd: () {
                if (mounted) setState(() => _saindo = null);
              },
              child: _saindo,
              builder: (context, opacidade, filho) =>
                  Opacity(opacity: opacidade, child: filho),
            ),
          ),
      ],
    );
  }
}
