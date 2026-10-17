import 'package:core/tema.dart';
import 'package:flutter/material.dart';

import 'form_promocional_layout.dart';

/// Campo de data no estilo de input, formato dd/MM/aaaa.
class CampoData extends StatelessWidget {
  final String rotulo;
  final DateTime? data;
  final ValueChanged<DateTime> onSelecionado;
  final String? erro;

  const CampoData({
    super.key,
    required this.rotulo,
    required this.data,
    required this.onSelecionado,
    this.erro,
  });

  static String formatar(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _escolher(BuildContext context) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) onSelecionado(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return RotuloCampo(
      rotulo: rotulo,
      filho: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: () => _escolher(context),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          child: InputDecorator(
            isEmpty: data == null,
            decoration: InputDecoration(
              hintText: 'dd/mm/aaaa',
              errorText: erro,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: Text(data == null ? '' : formatar(data!)),
          ),
        ),
      ),
    );
  }
}
