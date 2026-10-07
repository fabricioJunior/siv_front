import 'package:core/tema.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:flutter/material.dart';

const giroPapel = Color(0xFFF4F3F0);
const giroTinta = Color(0xFF26282A);
const giroLinha = Color(0x2426282A);
const giroLinhaFina = Color(0x1226282A);
const giroDestaque = Color(0xFFF0F5FA);
const giroAcento = Color(0xFF5980A6);
const giroAcentoEscuro = Color(0xFF2F4A63);
const giroErro = Color(0xFF8A2F2F);
final giroApoio = giroTinta.withValues(alpha: .55);
const giroTabular = [FontFeature.tabularFigures()];

class EstiloFaixaGiro {
  final Color fundo;
  final Color texto;
  final Color borda;
  final Color barra;
  const EstiloFaixaGiro(this.fundo, this.texto, this.borda, this.barra);
}

/// Cores das faixas de giro (§5), num só lugar.
const estilosGiro = <ClassificacaoGiro, EstiloFaixaGiro>{
  ClassificacaoGiro.excepcional: EstiloFaixaGiro(
      Color(0xFF22323F), Color(0xFFFFFFFF), Color(0xFF22323F), Color(0xFF22323F)),
  ClassificacaoGiro.rapido: EstiloFaixaGiro(
      Color(0xFFDDE7F1), Color(0xFF2F4A63), Color(0xFFDDE7F1), Color(0xFF5980A6)),
  ClassificacaoGiro.normal: EstiloFaixaGiro(
      Color(0xFFE6E6E7), Color(0xFF4A4C4E), Color(0xFFE6E6E7), Color(0xFF9AA5AE)),
  ClassificacaoGiro.lento: EstiloFaixaGiro(
      Color(0xFFF3EADB), Color(0xFF7A5418), Color(0xFFF3EADB), Color(0xFFC08A3E)),
  ClassificacaoGiro.parado: EstiloFaixaGiro(
      Color(0xFFF6E9E9), Color(0xFF8A2F2F), Color(0xFFF6E9E9), Color(0xFF8A2F2F)),
  ClassificacaoGiro.semHistorico: EstiloFaixaGiro(
      Colors.transparent, Color(0xFF4A4C4E), Color(0x4D26282A), Color(0xFFD0D3D6)),
};

/// Faixas exibidas no painel (sem "sem histórico").
const faixasGiro = [
  ClassificacaoGiro.excepcional,
  ClassificacaoGiro.rapido,
  ClassificacaoGiro.normal,
  ClassificacaoGiro.lento,
  ClassificacaoGiro.parado,
];

TextStyle giroNumero(BuildContext context, double tamanho, {Color? cor}) =>
    context.sivTextos.valor.copyWith(
      fontSize: tamanho,
      height: 1.1,
      color: cor,
      fontFeatures: giroTabular,
    );

TextStyle giroCorpo(BuildContext context, double tamanho,
        {Color? cor, FontWeight? peso}) =>
    context.sivTextos.corpo.copyWith(
      fontSize: tamanho,
      color: cor ?? giroTinta,
      fontWeight: peso,
      fontFeatures: giroTabular,
    );

class GiroTag extends StatelessWidget {
  final ClassificacaoGiro classificacao;
  const GiroTag(this.classificacao, {super.key});

  @override
  Widget build(BuildContext context) {
    final e = estilosGiro[classificacao]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: e.fundo, border: Border.all(color: e.borda)),
      child: Text(
        classificacao.label,
        style: giroCorpo(context, 11.5, cor: e.texto, peso: FontWeight.w600),
      ),
    );
  }
}

/// Chip removível "Classificação: X" (filtro vindo do painel).
class GiroChipClassificacao extends StatelessWidget {
  final ClassificacaoGiro classificacao;
  final VoidCallback onRemover;
  const GiroChipClassificacao({
    super.key,
    required this.classificacao,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final e = estilosGiro[classificacao]!;
    return InkWell(
      onTap: onRemover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: e.fundo, border: Border.all(color: e.borda)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Classificação: ${classificacao.label}',
              style: giroCorpo(context, 12, cor: e.texto, peso: FontWeight.w600)),
          const SizedBox(width: 6),
          Icon(Icons.close, size: 12, color: e.texto),
        ]),
      ),
    );
  }
}

/// Barra fina de % (4 px por padrão).
class GiroBarra extends StatelessWidget {
  final double? pct;
  final Color cor;
  final double altura;
  const GiroBarra({super.key, required this.pct, required this.cor, this.altura = 4});

  @override
  Widget build(BuildContext context) => Container(
        height: altura,
        color: giroTinta.withValues(alpha: .08),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ((pct ?? 0) / 100).clamp(0.0, 1.0),
          child: Container(color: cor),
        ),
      );
}

/// Painel branco com marcas "+" nos cantos (.blueprint).
class GiroPainel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GiroPainel({super.key, required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    Widget marca(double? t, double? b, double? l, double? r) => Positioned(
          top: t, bottom: b, left: l, right: r,
          child: IgnorePointer(
            child: SizedBox(
              width: 11, height: 11,
              child: Stack(children: [
                Positioned(left: 5, top: 0, bottom: 0, child: Container(width: 1, color: giroTinta.withValues(alpha: .55))),
                Positioned(top: 5, left: 0, right: 0, child: Container(height: 1, color: giroTinta.withValues(alpha: .55))),
              ]),
            ),
          ),
        );
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: giroLinha)),
        child: child,
      ),
      marca(-6, null, -6, null),
      marca(-6, null, null, -6),
      marca(null, -6, -6, null),
      marca(null, -6, null, -6),
    ]);
  }
}

/// Linha de grade: largura fixa ([largura]) ou flexível quando null.
class GiroGrade extends StatelessWidget {
  final List<(double?, Widget)> colunas;
  final double gap;
  const GiroGrade({super.key, required this.colunas, this.gap = 12});

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < colunas.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          colunas[i].$1 == null
              ? Expanded(child: colunas[i].$2)
              : SizedBox(width: colunas[i].$1, child: colunas[i].$2),
        ],
      ]);
}
