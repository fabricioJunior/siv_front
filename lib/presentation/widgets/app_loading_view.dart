import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siv_front/presentation/widgets/assinatura_siv.dart';
import 'package:siv_front/presentation/widgets/barra_indeterminada_siv.dart';

const _fundo = Color(0xFF1D2D3D); // = fundo do PNG: a imagem some na superfície
const _acento = Color(0xFF94BCE3); // azul claro do "VALE DO CEARÁ"
const _textoAtivo = Color(0xFFF4F3F0);
const _textoFeito = Color(0xFF88A2B5);
const _textoRodape = Color(0xFF5F7A8F);
const _divisor = Color(0x24FFFFFF); // branco 14%
const _trilhaBarra = Color(0x14FFFFFF); // branco 8%

const _larguraDesktop = 720.0;
const _maxConcluidasVisiveis = 5;

/// Tela de carregamento da abertura ("marinho com etapas"): assinatura da marca,
/// as etapas reais de inicialização (as concluídas com check, a atual piscando) e
/// uma barra indeterminada na base. Só visual: as etapas vêm do AppBloc
/// (`etapaAtualInicializacao` / `etapasInicializacaoConcluidas`).
class AppLoadingView extends StatelessWidget {
  final String? etapaAtual;
  final List<String> etapasConcluidas;

  const AppLoadingView({
    super.key,
    this.etapaAtual,
    this.etapasConcluidas = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _fundo,
        body: LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth >= _larguraDesktop
              ? _Desktop(etapaAtual: etapaAtual, concluidas: etapasConcluidas)
              : _Mobile(etapaAtual: etapaAtual, concluidas: etapasConcluidas),
        ),
      ),
    );
  }
}

class _Desktop extends StatelessWidget {
  final String? etapaAtual;
  final List<String> concluidas;

  const _Desktop({required this.etapaAtual, required this.concluidas});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Stack(
      children: [
        Center(
          child: Row(
            children: [
              const Expanded(
                child: Center(
                  child: AssinaturaSiv(recortada: true, largura: 340),
                ),
              ),
              Container(width: 1, height: 240, color: _divisor),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 64, right: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INICIANDO',
                          style: textos.display.copyWith(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.6,
                            color: _acento,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ListaEtapas(
                          etapaAtual: etapaAtual,
                          concluidas: concluidas,
                          espaco: 18,
                          fonte: 15,
                          icone: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BarraIndeterminadaSiv(
            altura: 2,
            cor: _acento,
            trilha: _trilhaBarra,
          ),
        ),
        Positioned(
          left: 40,
          right: 40,
          bottom: 22,
          child: Text(
            'VALE DO CEARÁ',
            style: textos.corpo.copyWith(
              fontSize: 11,
              letterSpacing: 1.76,
              color: _textoRodape,
            ),
          ),
        ),
        const Positioned(top: 20, right: 24, child: _BotaoConfiguracao()),
      ],
    );
  }
}

class _Mobile extends StatelessWidget {
  final String? etapaAtual;
  final List<String> concluidas;

  const _Mobile({required this.etapaAtual, required this.concluidas});

  @override
  Widget build(BuildContext context) {
    final conteudo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AssinaturaSiv(recortada: true, largura: 240),
        const SizedBox(height: 44),
        SizedBox(
          width: 220,
          child: _ListaEtapas(
            etapaAtual: etapaAtual,
            concluidas: concluidas,
            espaco: 14,
            fonte: 14,
            icone: 16,
          ),
        ),
        const SizedBox(height: 28),
        const _BotaoConfiguracao(),
      ],
    );

    return Stack(
      children: [
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final centralizado = Center(child: conteudo);
              if (constraints.maxHeight >= 560) return centralizado;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: conteudo),
              );
            },
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BarraIndeterminadaSiv(
            altura: 2,
            cor: _acento,
            trilha: _trilhaBarra,
          ),
        ),
      ],
    );
  }
}

class _BotaoConfiguracao extends StatelessWidget {
  const _BotaoConfiguracao();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('app_loading_configuracao_dispositivo_button'),
      onPressed: () =>
          Navigator.of(context).pushNamed('/configuracao_dispositivo'),
      icon: const Icon(Icons.settings_outlined, size: 16),
      label: Text(
        'Configurações do dispositivo',
        style: context.sivTextos.corpo.copyWith(
          fontSize: 13,
          height: 1.2,
          color: _textoFeito,
        ),
      ),
      style:
          TextButton.styleFrom(
            foregroundColor: _textoFeito,
            overlayColor: Colors.transparent,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (estados) => estados.contains(WidgetState.pressed)
                  ? const Color(0x24FFFFFF)
                  : estados.contains(WidgetState.hovered)
                  ? const Color(0x14FFFFFF)
                  : null,
            ),
          ),
    );
  }
}

/// As últimas [_maxConcluidasVisiveis] concluídas mais a ativa. As mais antigas
/// saem por cima, com fade.
class _ListaEtapas extends StatelessWidget {
  final String? etapaAtual;
  final List<String> concluidas;
  final double espaco;
  final double fonte;
  final double icone;

  const _ListaEtapas({
    required this.etapaAtual,
    required this.concluidas,
    required this.espaco,
    required this.fonte,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final sobram = concluidas.length > _maxConcluidasVisiveis;
    final visiveis = sobram
        ? concluidas.sublist(concluidas.length - _maxConcluidasVisiveis)
        : concluidas;
    // Sem nenhuma etapa (ex.: SplashPage): uma linha ativa genérica.
    final ativa =
        etapaAtual ?? (concluidas.isEmpty ? 'Preparando ambiente' : null);

    final linhas = <Widget>[
      for (final etapa in visiveis)
        _LinhaEtapa(
          key: ValueKey(etapa),
          texto: etapa,
          ativa: false,
          fonte: fonte,
          icone: icone,
        ),
      if (ativa != null)
        _LinhaEtapa(
          key: ValueKey(ativa),
          texto: ativa,
          ativa: true,
          fonte: fonte,
          icone: icone,
        ),
    ];

    Widget coluna = AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < linhas.length; i++) ...[
            if (i > 0) SizedBox(height: espaco),
            linhas[i],
          ],
        ],
      ),
    );

    if (sobram) {
      // Fade na linha mais antiga: ela está prestes a sair por cima.
      coluna = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66FFFFFF), Colors.white],
          stops: [0, 0.22],
        ).createShader(rect),
        child: coluna,
      );
    }
    return coluna;
  }
}

class _LinhaEtapa extends StatelessWidget {
  final String texto;
  final bool ativa;
  final double fonte;
  final double icone;

  const _LinhaEtapa({
    super.key,
    required this.texto,
    required this.ativa,
    required this.fonte,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    final troca = reduzir ? Duration.zero : const Duration(milliseconds: 180);
    final linha = Row(
      children: [
        SizedBox.square(
          dimension: icone,
          child: Center(
            child: AnimatedSwitcher(
              duration: troca,
              child: ativa
                  ? _QuadradoPiscando(
                      key: const ValueKey('ativa'),
                      lado: icone <= 16 ? 7 : 8,
                    )
                  : Icon(
                      Icons.check,
                      key: const ValueKey('feita'),
                      size: icone <= 16 ? 15 : 16,
                      color: _acento,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: troca,
            style: context.sivTextos.corpo.copyWith(
              fontSize: fonte,
              height: 1.25,
              color: ativa ? _textoAtivo : _textoFeito,
            ),
            child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );

    final comSemantica = ativa
        ? Semantics(liveRegion: true, label: texto, child: linha)
        : linha;

    // Entrada: fade + 8px de baixo pra cima, 220 ms (só na 1ª vez que a linha aparece).
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduzir ? 1 : 0, end: 1),
      duration: reduzir ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: comSemantica,
      builder: (context, valor, filho) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - valor)),
          child: filho,
        ),
      ),
    );
  }
}

class _QuadradoPiscando extends StatefulWidget {
  final double lado;

  const _QuadradoPiscando({super.key, required this.lado});

  @override
  State<_QuadradoPiscando> createState() => _QuadradoPiscandoState();
}

class _QuadradoPiscandoState extends State<_QuadradoPiscando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final Animation<double> _opacidade = Tween(
    begin: 1.0,
    end: 0.25,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacidade,
      child: Container(width: widget.lado, height: widget.lado, color: _acento),
    );
  }
}
