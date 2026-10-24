import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/widgets/barra_indeterminada_siv.dart';

const syncFundo = Color(0xFFF4F3F0);
const syncTexto = Color(0xFF26282A);
const syncTextoSuave = Color(0x9926282A);
const syncLinha = Color(0x2426282A);
const syncLinhaFina = Color(0x1426282A);
const syncMarinho = Color(0xFF22323F);
const syncAcento = Color(0xFF5980A6);
const syncAcentoClaro = Color(0xFF94BCE3);
const syncSubtitulo = Color(0xFFBDD8F2);
const syncRotulo = Color(0xFF88A2B5);
const syncBarraOk = Color(0xFF9DB4CA);
const syncLinhaAtiva = Color(0xFFF0F5FA);
const syncErro = Color(0xFF8A2F2F);
const syncErroFundo = Color(0xFFF6E9E9);
const syncLinhaErro = Color(0xFFFBF4F4);
const syncBarraErroGeral = Color(0xFFC98080);

const _tabular = [FontFeature.tabularFigures()];

TextStyle syncBarlow(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = syncTexto,
  double? ls,
  double? h,
}) => TextStyle(
  fontFamily: sivFonteBarlow,
  fontSize: size,
  fontWeight: w,
  color: c,
  letterSpacing: ls,
  height: h,
  fontFeatures: _tabular,
);

TextStyle syncCond(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = syncTexto,
  double? ls,
  double? h,
}) => TextStyle(
  fontFamily: sivFonteCondensed,
  fontSize: size,
  fontWeight: w,
  color: c,
  letterSpacing: ls,
  height: h,
  fontFeatures: _tabular,
);

String syncNum(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

Duration syncDur(BuildContext context, int ms) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: ms);

/// Troca de texto com fade + deslocamento vertical de baixo para cima.
class SyncTroca extends StatelessWidget {
  final Widget child;
  const SyncTroca({super.key, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: syncDur(context, 200),
    transitionBuilder: (c, anim) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .3),
          end: Offset.zero,
        ).animate(anim),
        child: c,
      ),
    ),
    layoutBuilder: (atual, antigos) =>
        Stack(alignment: Alignment.centerLeft, children: [...antigos, ?atual]),
    child: child,
  );
}

/// Quadrado que pisca (1.0 <-> 0.25). Parado com animações desligadas.
class QuadradoPiscanteSync extends StatefulWidget {
  final double lado;
  final Color cor;
  const QuadradoPiscanteSync({super.key, this.lado = 8, this.cor = syncAcento});

  @override
  State<QuadradoPiscanteSync> createState() => _QuadradoPiscanteSyncState();
}

class _QuadradoPiscanteSyncState extends State<QuadradoPiscanteSync>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(
      begin: 1.0,
      end: .25,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: Container(
      width: widget.lado,
      height: widget.lado,
      color: widget.cor,
    ),
  );
}

/// Ponto do menu lateral: aparece só durante a sincronização.
class SyncPontoMenu extends StatelessWidget {
  const SyncPontoMenu({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SyncDataBloc, SyncDataState, bool>(
        bloc: sl<SyncDataBloc>(),
        selector: (s) => s.sincronizando,
        builder: (context, on) => AnimatedOpacity(
          opacity: on ? 1 : 0,
          duration: syncDur(context, 200),
          child: TickerMode(
            enabled: on,
            child: const QuadradoPiscanteSync(lado: 7, cor: syncAcentoClaro),
          ),
        ),
      );
}

class SyncStatusIcone extends StatelessWidget {
  final SyncModuloStatus status;
  final double caixa;
  const SyncStatusIcone({super.key, required this.status, this.caixa = 18});

  @override
  Widget build(BuildContext context) {
    final lado = caixa >= 18 ? 8.0 : 7.0;
    final icone = switch (status) {
      SyncModuloStatus.concluido => Icon(
        Icons.check,
        size: caixa - 2,
        color: syncAcento,
      ),
      SyncModuloStatus.sincronizando => QuadradoPiscanteSync(lado: lado),
      SyncModuloStatus.aguardando => Container(
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x6626282A)),
        ),
      ),
      SyncModuloStatus.falha => Icon(
        Icons.close,
        size: caixa - 2,
        color: syncErro,
      ),
    };
    return SizedBox(
      width: caixa,
      height: caixa,
      child: AnimatedSwitcher(
        duration: syncDur(context, 180),
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(begin: .8, end: 1.0).animate(a),
            child: c,
          ),
        ),
        child: Center(key: ValueKey(status), child: icone),
      ),
    );
  }
}

class SyncTag extends StatelessWidget {
  final SyncModuloStatus status;
  const SyncTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (rotulo, fundo, texto, borda) = switch (status) {
      SyncModuloStatus.concluido => (
        'Concluído',
        const Color(0xFFDDE7F1),
        const Color(0xFF2F4A63),
        false,
      ),
      SyncModuloStatus.sincronizando => (
        'Sincronizando',
        Colors.transparent,
        syncAcento,
        true,
      ),
      SyncModuloStatus.aguardando => (
        'Aguardando',
        const Color(0xFFE6E6E7),
        const Color(0xFF4A4C4E),
        false,
      ),
      SyncModuloStatus.falha => ('Falha', syncErroFundo, syncErro, false),
    };
    return AnimatedSwitcher(
      duration: syncDur(context, 180),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: fundo,
          border: borda ? Border.all(color: syncAcento) : null,
        ),
        child: Text(
          rotulo,
          style: syncBarlow(11, w: FontWeight.w600, c: texto),
        ),
      ),
    );
  }
}

/// Barra de progresso quadrada; [valor] null + [indeterminada] mostra a barra
/// indeterminada.
class SyncBarra extends StatelessWidget {
  final double? valor;
  final double altura;
  final Color cor;
  final Color trilha;
  final bool indeterminada;

  const SyncBarra({
    super.key,
    required this.valor,
    required this.cor,
    this.altura = 4,
    this.trilha = syncLinhaFina,
    this.indeterminada = false,
  });

  @override
  Widget build(BuildContext context) {
    if (valor == null && indeterminada) {
      return BarraIndeterminadaSiv(altura: altura, cor: cor, trilha: trilha);
    }
    return Container(
      height: altura,
      color: trilha,
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: valor ?? 0),
        duration: syncDur(context, 500),
        curve: Curves.easeOut,
        builder: (_, v, _) => FractionallySizedBox(
          widthFactor: v.clamp(0.0, 1.0),
          child: ColoredBox(
            color: cor,
            child: SizedBox(height: altura),
          ),
        ),
      ),
    );
  }
}

Color syncCorBarra(SyncModuloStatus s) => switch (s) {
  SyncModuloStatus.sincronizando => syncAcento,
  SyncModuloStatus.concluido => syncBarraOk,
  SyncModuloStatus.falha => syncErro,
  SyncModuloStatus.aguardando => syncAcento,
};

Color syncCorFundo(SyncModuloStatus s) => switch (s) {
  SyncModuloStatus.sincronizando => syncLinhaAtiva,
  SyncModuloStatus.falha => syncLinhaErro,
  _ => Colors.transparent,
};

/// Texto de erro do módulo, entra com AnimatedSize + fade.
class SyncErro extends StatelessWidget {
  final String? texto;
  final double tamanho;
  final EdgeInsets padding;
  const SyncErro({
    super.key,
    required this.texto,
    required this.tamanho,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: syncDur(context, 200),
    alignment: Alignment.topLeft,
    child: AnimatedSwitcher(
      duration: syncDur(context, 200),
      child: texto == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              key: ValueKey(texto),
              padding: padding,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  texto!,
                  style: syncBarlow(tamanho, c: syncErro, h: 1.45),
                ),
              ),
            ),
    ),
  );
}

/// Marcas de registro "+" nos 4 cantos (cruz de 9 px de braço, traço 1 px).
class SyncMarcasRegistro extends StatelessWidget {
  final Widget child;
  const SyncMarcasRegistro({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(foregroundPainter: _MarcasPainter(), child: child);
}

class _MarcasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = syncAcento
      ..strokeWidth = 1;
    for (final c in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      canvas.drawLine(c - const Offset(9, 0), c + const Offset(9, 0), p);
      canvas.drawLine(c - const Offset(0, 9), c + const Offset(0, 9), p);
    }
  }

  @override
  bool shouldRepaint(_MarcasPainter old) => false;
}
