import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Posição (1-based) de um item numa lista ordenável.
///
/// Desktop: campo numérico de 56x40 que confirma no Enter e ao perder o foco.
/// Mobile ([aoAbrir] preenchido): botão quadrado de 44x44 que abre a folha de
/// posições.
class SivCampoPosicao extends StatefulWidget {
  final int posicao;
  final int total;
  final ValueChanged<int> onMover;
  final VoidCallback? aoAbrir;

  const SivCampoPosicao({
    super.key,
    required this.posicao,
    required this.total,
    required this.onMover,
    this.aoAbrir,
  });

  @override
  State<SivCampoPosicao> createState() => _SivCampoPosicaoState();
}

class _SivCampoPosicaoState extends State<SivCampoPosicao> {
  late final TextEditingController _c =
      TextEditingController(text: '${widget.posicao}');

  @override
  void didUpdateWidget(SivCampoPosicao old) {
    super.didUpdateWidget(old);
    if (old.posicao != widget.posicao) _c.text = '${widget.posicao}';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _enviar() {
    final n = int.tryParse(_c.text.trim());
    if (n == null) {
      _c.text = '${widget.posicao}';
      return;
    }
    final alvo = n.clamp(1, widget.total);
    widget.onMover(alvo);
    _c.text = '$alvo';
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: cores.tinta.withValues(alpha: 0.2)),
    );
    final estilo = TextStyle(
      fontFamily: sivFonteBarlow,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: cores.acoProfundo,
    );

    if (widget.aoAbrir != null) {
      return SizedBox(
        width: SivDimensoes.alvoToqueMinimo,
        height: SivDimensoes.alvoToqueMinimo,
        child: OutlinedButton(
          onPressed: widget.aoAbrir,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: BorderSide(color: cores.tinta.withValues(alpha: 0.2)),
            shape: const RoundedRectangleBorder(),
          ),
          child: Text('${widget.posicao}', style: estilo),
        ),
      );
    }

    return SizedBox(
      width: 56,
      height: 40,
      child: Focus(
        onFocusChange: (f) {
          if (!f) _enviar();
        },
        child: TextField(
          controller: _c,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: estilo,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _enviar(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            border: borda,
            enabledBorder: borda,
            focusedBorder: borda.copyWith(
              borderSide: BorderSide(color: cores.aco, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
