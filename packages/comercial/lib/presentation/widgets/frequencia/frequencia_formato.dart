import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Formatadores pt-BR e cores de classe, compartilhados pelos widgets de Frequência.
String frequenciaDec(num v, [int casas = 1]) {
  final neg = v < 0;
  final partes = v.abs().toStringAsFixed(casas).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${neg ? '-' : ''}$inteiro${partes.length > 1 ? ',${partes[1]}' : ''}';
}

String frequenciaInt(num v) => frequenciaDec(v, 0);

String frequenciaMoeda(num v) => 'R\$ ${frequenciaDec(v, 2)}';

String frequenciaPct(num v, [int casas = 1]) => '${frequenciaDec(v, casas)}%';

String _d2(int n) => n.toString().padLeft(2, '0');

String frequenciaDia(DateTime d) => '${_d2(d.day)}/${_d2(d.month)}';

String frequenciaDiaAno(DateTime d) => '${frequenciaDia(d)}/${d.year}';

Color frequenciaCorBarra(SivColors c, String classe) => switch (classe) {
  'A' => c.acoEscuro,
  'B' => c.aco,
  _ => c.classeCBarra,
};

/// Cor do rótulo/tag da classe sobre papel (A escuro, B aço profundo, C neutro).
Color frequenciaCorTexto(SivColors c, String classe) => switch (classe) {
  'A' => c.acoEscuro,
  'B' => c.acoProfundo,
  _ => c.classeCTagTexto,
};

Color frequenciaTagFundo(SivColors c, String classe) => switch (classe) {
  'A' => c.acoEscuro,
  'B' => c.classeBTagFundo,
  _ => c.classeCTagFundo,
};

Color frequenciaTagTexto(SivColors c, String classe) => switch (classe) {
  'A' => c.textoSobreEscuroTitulo,
  'B' => c.classeBTagTexto,
  _ => c.classeCTagTexto,
};

/// Tag de classe (A/B/C) ou rótulo livre ([texto]).
class FrequenciaTag extends StatelessWidget {
  final String classe;
  final String? texto;
  const FrequenciaTag(this.classe, {super.key, this.texto});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: frequenciaTagFundo(c, classe),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        texto ?? classe,
        style: context.sivTextos.apoio.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: frequenciaTagTexto(c, classe),
        ),
      ),
    );
  }
}
