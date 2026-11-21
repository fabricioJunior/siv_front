import 'package:core/tema.dart';
import 'package:flutter/material.dart';

import 'form_promocional_layout.dart';

/// Campo de data no estilo de input, formato dd/MM/aaaa.
class CampoData extends StatelessWidget {
  final String rotulo;
  final DateTime? data;
  final ValueChanged<DateTime> onSelecionado;
  final String? erro;

  /// 'HH:mm' ou vazio (= dia todo). Só aparece quando [onHora] é informado.
  final String? hora;

  /// Recebe 'HH:mm', ou '' ao limpar.
  final ValueChanged<String>? onHora;

  const CampoData({
    super.key,
    required this.rotulo,
    required this.data,
    required this.onSelecionado,
    this.erro,
    this.hora,
    this.onHora,
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

  Future<void> _escolherHora(BuildContext context) async {
    final partes = (hora ?? '').split(':');
    final atual = partes.length >= 2
        ? TimeOfDay(
            hour: int.tryParse(partes[0]) ?? 0,
            minute: int.tryParse(partes[1]) ?? 0,
          )
        : TimeOfDay.now();
    final escolhida = await showTimePicker(
      context: context,
      initialTime: atual,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (escolhida == null) return;
    onHora!(
      '${escolhida.hour.toString().padLeft(2, '0')}:${escolhida.minute.toString().padLeft(2, '0')}',
    );
  }

  Widget _campo({
    required String rotulo,
    required String texto,
    required String hint,
    required IconData icone,
    required VoidCallback onTap,
    String? erro,
    VoidCallback? onLimpar,
  }) {
    return RotuloCampo(
      rotulo: rotulo,
      filho: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: onTap,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          child: InputDecorator(
            isEmpty: texto.isEmpty,
            decoration: InputDecoration(
              hintText: hint,
              errorText: erro,
              suffixIcon: onLimpar != null && texto.isNotEmpty
                  ? IconButton(
                      tooltip: 'Limpar',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: onLimpar,
                    )
                  : Icon(icone, size: 18),
            ),
            child: Text(texto),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campoData = Builder(
      builder: (context) => _campo(
        rotulo: rotulo,
        texto: data == null ? '' : formatar(data!),
        hint: 'dd/mm/aaaa',
        icone: Icons.calendar_today_outlined,
        onTap: () => _escolher(context),
        erro: erro,
      ),
    );
    if (onHora == null) return campoData;
    final temHora = hora != null && hora!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: campoData),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Builder(
            builder: (context) => _campo(
              rotulo: 'Hora',
              texto: temHora ? hora! : '',
              hint: 'dia todo',
              icone: Icons.schedule,
              onTap: () => _escolherHora(context),
              onLimpar: () => onHora!(''),
            ),
          ),
        ),
      ],
    );
  }
}
