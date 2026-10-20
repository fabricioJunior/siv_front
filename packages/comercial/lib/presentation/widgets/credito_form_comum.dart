import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

bool ehMobileCredito(BuildContext c) =>
    MediaQuery.sizeOf(c).width < SivDimensoes.breakpointMenuDrawer;

/// Desktop: modal (SivModal montado pelo [builder]); mobile: página inteira
/// com rodapé fixo. O [builder] deve devolver um [CreditoFormCasca].
Future<void> mostrarFormCredito(BuildContext context, WidgetBuilder builder) {
  if (ehMobileCredito(context)) {
    return Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: builder));
  }
  return showDialog<void>(
    context: context,
    barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
    builder: builder,
  );
}

/// Valor digitado em reais ("1.234,50" ou "50.5") -> double com 2 casas.
double? parseValorBr(String texto) {
  var t = texto.trim();
  if (t.isEmpty) return null;
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  final v = double.tryParse(t);
  return v == null ? null : double.parse(v.toStringAsFixed(2));
}

String formatarDiaMes(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Casca comum de 2b/2c/2d: SivModal no desktop; no mobile, página com
/// ação principal fixa no rodapé (SivRodapeAcoes).
class CreditoFormCasca extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget corpo;
  final String rotuloConfirmar;
  final VoidCallback? aoConfirmar;
  final bool enviando;
  final String? erro;
  final bool perigo;

  /// Texto à esquerda do rodapé (desktop) / status do rodapé (mobile).
  final String? nota;
  final String? notaMobile;
  final String rotuloVoltar;

  const CreditoFormCasca({
    super.key,
    required this.titulo,
    required this.corpo,
    required this.rotuloConfirmar,
    required this.aoConfirmar,
    this.subtitulo,
    this.enviando = false,
    this.erro,
    this.perigo = false,
    this.nota,
    this.notaMobile,
    this.rotuloVoltar = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subtitulo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              subtitulo!,
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ),
        corpo,
        if (erro != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(erro!, style: textos.apoio.copyWith(color: cores.vinho)),
          ),
      ],
    );
    final botao = ElevatedButton(
      style: perigo
          ? ElevatedButton.styleFrom(
              backgroundColor: cores.vinho,
              foregroundColor: cores.textoSobreEscuroTitulo,
            )
          : null,
      onPressed: enviando ? null : aoConfirmar,
      child: Text(rotuloConfirmar),
    );

    if (ehMobileCredito(context)) {
      return Scaffold(
        backgroundColor: cores.superficie,
        appBar: AppBar(title: Text(titulo)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: conteudo,
          ),
        ),
        bottomNavigationBar: SivRodapeAcoes(
          mobile: true,
          status: notaMobile ?? nota ?? titulo,
          primaria: botao,
        ),
      );
    }
    return SivModal(
      titulo: titulo,
      larguraMaxima: 560,
      corpo: conteudo,
      contadorSelecao: nota,
      acoes: [
        TextButton(
          onPressed: enviando ? null : () => Navigator.of(context).pop(),
          child: Text(rotuloVoltar),
        ),
        botao,
      ],
    );
  }
}

/// Escolha única em chips (motivo, quanto remover, validade...).
class CreditoOpcoes<T> extends StatelessWidget {
  final String rotulo;
  final List<(T, String)> opcoes;
  final T? selecionado;
  final ValueChanged<T> aoEscolher;

  const CreditoOpcoes({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.selecionado,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: context.sivTextos.apoio),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (valor, texto) in opcoes)
              ChoiceChip(
                label: Text(texto),
                selected: valor == selecionado,
                onSelected: (_) => aoEscolher(valor),
              ),
          ],
        ),
      ],
    );
  }
}

/// Faixa "Saldo depois: X -> Y".
class CreditoSaldoDepois extends StatelessWidget {
  final double antes;
  final double depois;

  const CreditoSaldoDepois(
      {super.key, required this.antes, required this.depois});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cores.selecaoFundo,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Saldo depois', style: textos.apoio)),
          Text('${formatarMoedaBr(antes)} → ',
              style: textos.apoio.copyWith(color: cores.textoApoio)),
          Text(formatarMoedaBr(depois),
              style: textos.valor.copyWith(fontSize: 17)),
        ],
      ),
    );
  }
}
