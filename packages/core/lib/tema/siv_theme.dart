import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta e medidas do redesign SIV / Vale do Ceará. Toda cor, raio e
/// espaçamento usado em `presentation/` deve vir daqui -- nenhum widget deve
/// declarar valor literal.
class SivColors extends ThemeExtension<SivColors> {
  final Color papel;
  final Color superficie;
  final Color superficieRecuada;
  final Color acoEscuro;
  final Color acoAtivo;
  final Color aco;
  final Color acoProfundo;
  final Color ceu;
  final Color tinta;
  final Color vinho;
  final Color atencao;
  final Color hairline;
  final Color selecaoFundo;
  final Color atencaoFundo;
  final Color atencaoBorda;
  final Color falhaFundo;
  final Color falhaBorda;
  final Color emAndamentoFundo;

  const SivColors({
    required this.papel,
    required this.superficie,
    required this.superficieRecuada,
    required this.acoEscuro,
    required this.acoAtivo,
    required this.aco,
    required this.acoProfundo,
    required this.ceu,
    required this.tinta,
    required this.vinho,
    required this.atencao,
    required this.hairline,
    required this.selecaoFundo,
    required this.atencaoFundo,
    required this.atencaoBorda,
    required this.falhaFundo,
    required this.falhaBorda,
    required this.emAndamentoFundo,
  });

  static const SivColors padrao = SivColors(
    papel: Color(0xFFF4F3F0),
    superficie: Color(0xFFFFFFFF),
    superficieRecuada: Color(0xFFFBFAF8),
    acoEscuro: Color(0xFF22323F),
    acoAtivo: Color(0xFF31485A),
    aco: Color(0xFF5980A6),
    acoProfundo: Color(0xFF416180),
    ceu: Color(0xFF94BCE3),
    tinta: Color(0xFF26282A),
    vinho: Color(0xFF8A2F2F),
    atencao: Color(0xFF7A5D1D),
    hairline: Color(0x1726282A), // #26282A a 9%
    selecaoFundo: Color(0xFFF0F5FA),
    atencaoFundo: Color(0xFFF5EFE0),
    atencaoBorda: Color(0xFFCBB27A),
    falhaFundo: Color(0xFFF6E9E9),
    falhaBorda: Color(0xFFC99B9B),
    emAndamentoFundo: Color(0xFFD6EBFF),
  );

  /// Texto principal sobre papel (100%).
  Color get textoPrincipal => tinta;

  /// Texto de apoio sobre papel (52%).
  Color get textoApoio => tinta.withValues(alpha: 0.52);

  /// Texto desabilitado sobre papel (38%).
  Color get textoDesabilitado => tinta.withValues(alpha: 0.38);

  /// Título sobre o aço escuro.
  Color get textoSobreEscuroTitulo => const Color(0xFFFFFFFF);

  /// Texto de apoio sobre o aço escuro.
  Color get textoSobreEscuroApoio => ceu;

  /// Texto terciário sobre o aço escuro.
  Color get textoSobreEscuroTerciario => const Color(0xFF88A2B5);

  @override
  SivColors copyWith({
    Color? papel,
    Color? superficie,
    Color? superficieRecuada,
    Color? acoEscuro,
    Color? acoAtivo,
    Color? aco,
    Color? acoProfundo,
    Color? ceu,
    Color? tinta,
    Color? vinho,
    Color? atencao,
    Color? hairline,
    Color? selecaoFundo,
    Color? atencaoFundo,
    Color? atencaoBorda,
    Color? falhaFundo,
    Color? falhaBorda,
    Color? emAndamentoFundo,
  }) {
    return SivColors(
      papel: papel ?? this.papel,
      superficie: superficie ?? this.superficie,
      superficieRecuada: superficieRecuada ?? this.superficieRecuada,
      acoEscuro: acoEscuro ?? this.acoEscuro,
      acoAtivo: acoAtivo ?? this.acoAtivo,
      aco: aco ?? this.aco,
      acoProfundo: acoProfundo ?? this.acoProfundo,
      ceu: ceu ?? this.ceu,
      tinta: tinta ?? this.tinta,
      vinho: vinho ?? this.vinho,
      atencao: atencao ?? this.atencao,
      hairline: hairline ?? this.hairline,
      selecaoFundo: selecaoFundo ?? this.selecaoFundo,
      atencaoFundo: atencaoFundo ?? this.atencaoFundo,
      atencaoBorda: atencaoBorda ?? this.atencaoBorda,
      falhaFundo: falhaFundo ?? this.falhaFundo,
      falhaBorda: falhaBorda ?? this.falhaBorda,
      emAndamentoFundo: emAndamentoFundo ?? this.emAndamentoFundo,
    );
  }

  @override
  SivColors lerp(ThemeExtension<SivColors>? other, double t) {
    if (other is! SivColors) return this;
    return SivColors(
      papel: Color.lerp(papel, other.papel, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
      superficieRecuada: Color.lerp(
        superficieRecuada,
        other.superficieRecuada,
        t,
      )!,
      acoEscuro: Color.lerp(acoEscuro, other.acoEscuro, t)!,
      acoAtivo: Color.lerp(acoAtivo, other.acoAtivo, t)!,
      aco: Color.lerp(aco, other.aco, t)!,
      acoProfundo: Color.lerp(acoProfundo, other.acoProfundo, t)!,
      ceu: Color.lerp(ceu, other.ceu, t)!,
      tinta: Color.lerp(tinta, other.tinta, t)!,
      vinho: Color.lerp(vinho, other.vinho, t)!,
      atencao: Color.lerp(atencao, other.atencao, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      selecaoFundo: Color.lerp(selecaoFundo, other.selecaoFundo, t)!,
      atencaoFundo: Color.lerp(atencaoFundo, other.atencaoFundo, t)!,
      atencaoBorda: Color.lerp(atencaoBorda, other.atencaoBorda, t)!,
      falhaFundo: Color.lerp(falhaFundo, other.falhaFundo, t)!,
      falhaBorda: Color.lerp(falhaBorda, other.falhaBorda, t)!,
      emAndamentoFundo: Color.lerp(
        emAndamentoFundo,
        other.emAndamentoFundo,
        t,
      )!,
    );
  }
}

/// Estilos de texto nomeados do design system (Barlow / Barlow Condensed).
class SivTextStyles extends ThemeExtension<SivTextStyles> {
  final TextStyle display;
  final TextStyle titulo;
  final TextStyle secao;
  final TextStyle valor;
  final TextStyle corpo;
  final TextStyle apoio;
  final TextStyle rotulo;
  final TextStyle codigo;

  const SivTextStyles({
    required this.display,
    required this.titulo,
    required this.secao,
    required this.valor,
    required this.corpo,
    required this.apoio,
    required this.rotulo,
    required this.codigo,
  });

  factory SivTextStyles.padrao(Color corTinta) {
    TextStyle condensed({
      required double tamanho,
      required double altura,
      required FontWeight peso,
      double? espacamento,
    }) => GoogleFonts.barlowCondensed(
      fontSize: tamanho,
      height: altura,
      fontWeight: peso,
      letterSpacing: espacamento,
      color: corTinta,
    );

    TextStyle barlow({
      required double tamanho,
      required double altura,
      required FontWeight peso,
      double? espacamento,
    }) => GoogleFonts.barlow(
      fontSize: tamanho,
      height: altura,
      fontWeight: peso,
      letterSpacing: espacamento,
      color: corTinta,
    );

    return SivTextStyles(
      display: condensed(tamanho: 52, altura: 1.0, peso: FontWeight.w600),
      titulo: condensed(tamanho: 32, altura: 1.1, peso: FontWeight.w600),
      secao: condensed(tamanho: 20, altura: 1.15, peso: FontWeight.w600),
      valor: condensed(tamanho: 46, altura: 1.02, peso: FontWeight.w600),
      corpo: barlow(tamanho: 15, altura: 1.55, peso: FontWeight.w400),
      apoio: barlow(tamanho: 12.5, altura: 1.5, peso: FontWeight.w400),
      rotulo: barlow(
        tamanho: 11,
        altura: 1.4,
        peso: FontWeight.w400,
        espacamento: 1.8,
      ),
      codigo: TextStyle(
        fontSize: 12,
        fontFamily: 'monospace',
        color: corTinta,
      ),
    );
  }

  @override
  SivTextStyles copyWith({
    TextStyle? display,
    TextStyle? titulo,
    TextStyle? secao,
    TextStyle? valor,
    TextStyle? corpo,
    TextStyle? apoio,
    TextStyle? rotulo,
    TextStyle? codigo,
  }) {
    return SivTextStyles(
      display: display ?? this.display,
      titulo: titulo ?? this.titulo,
      secao: secao ?? this.secao,
      valor: valor ?? this.valor,
      corpo: corpo ?? this.corpo,
      apoio: apoio ?? this.apoio,
      rotulo: rotulo ?? this.rotulo,
      codigo: codigo ?? this.codigo,
    );
  }

  @override
  SivTextStyles lerp(ThemeExtension<SivTextStyles>? other, double t) {
    if (other is! SivTextStyles) return this;
    return SivTextStyles(
      display: TextStyle.lerp(display, other.display, t)!,
      titulo: TextStyle.lerp(titulo, other.titulo, t)!,
      secao: TextStyle.lerp(secao, other.secao, t)!,
      valor: TextStyle.lerp(valor, other.valor, t)!,
      corpo: TextStyle.lerp(corpo, other.corpo, t)!,
      apoio: TextStyle.lerp(apoio, other.apoio, t)!,
      rotulo: TextStyle.lerp(rotulo, other.rotulo, t)!,
      codigo: TextStyle.lerp(codigo, other.codigo, t)!,
    );
  }
}

/// Espaçamentos e raios fixos do design system. Consumidos pelos widgets
/// compartilhados em `presentation/`.
abstract final class SivDimensoes {
  static const double raio = 4;
  static const double paddingCard = 20;
  static const double gapCards = 18;
  static const double paginaHorizontal = 28;
  static const double paginaVertical = 30;
  static const double linhaTabelaVertical = 16;
  static const double linhaTabelaHorizontal = 22;
  static const double cabecalhoTabelaVertical = 14;
  static const double cabecalhoTabelaHorizontal = 22;
  static const double alturaBarraTitulo = 72;
  static const double paddingBarraTituloHorizontal = 34;
  static const double itemMenuVertical = 11;
  static const double itemMenuHorizontal = 22;
  static const double gapItemMenu = 3;
  static const double alvoToqueMinimo = 44;
  static const double larguraMenuLateral = 236;
  static const double larguraMenuLateralRail = 72;
  static const double larguraBarraSelecionada = 3;
  static const double breakpointMenuRail = 1100;
  static const double breakpointMenuDrawer = 820;
}

/// Tema central do SIV. Nada de cor/raio/espaçamento literal fora daqui.
class SivTheme {
  static ThemeData get tema {
    const cores = SivColors.padrao;
    final textos = SivTextStyles.padrao(cores.tinta);
    final borda = BorderSide(color: cores.hairline);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: cores.aco,
      brightness: Brightness.light,
      primary: cores.aco,
      onPrimary: Colors.white,
      surface: cores.superficie,
      onSurface: cores.tinta,
      error: cores.vinho,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cores.papel,
      fontFamily: GoogleFonts.barlow().fontFamily,
      extensions: [cores, textos],
      textTheme: TextTheme(
        displayLarge: textos.display,
        headlineLarge: textos.titulo,
        headlineMedium: textos.valor,
        titleLarge: textos.secao,
        bodyLarge: textos.corpo,
        bodyMedium: textos.corpo,
        bodySmall: textos.apoio,
        labelLarge: textos.rotulo,
      ),
      dividerColor: cores.hairline,
      cardTheme: CardThemeData(
        color: cores.superficie,
        elevation: 0,
        shadowColor: const Color(0x0D26282A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          borderSide: borda,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          borderSide: borda,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          borderSide: BorderSide(color: cores.aco, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          borderSide: BorderSide(color: cores.vinho, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cores.aco,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cores.aco.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
          minimumSize: const Size(0, SivDimensoes.alvoToqueMinimo),
          textStyle: textos.corpo.copyWith(
            fontFamily: GoogleFonts.barlowCondensed().fontFamily,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cores.acoProfundo,
          side: borda,
          minimumSize: const Size(0, SivDimensoes.alvoToqueMinimo),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cores.acoProfundo,
          minimumSize: const Size(0, SivDimensoes.alvoToqueMinimo),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cores.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(cores.superficieRecuada),
        dataRowColor: WidgetStateProperty.all(cores.superficie),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cores.superficieRecuada,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          side: borda,
        ),
        labelStyle: textos.apoio,
      ),
      dividerTheme: DividerThemeData(color: cores.hairline, thickness: 1),
    );
  }
}

extension SivThemeContextX on BuildContext {
  SivColors get sivColors =>
      Theme.of(this).extension<SivColors>() ?? SivColors.padrao;

  SivTextStyles get sivTextos =>
      Theme.of(this).extension<SivTextStyles>() ??
      SivTextStyles.padrao(SivColors.padrao.tinta);
}
