import 'package:core/presentation/data_hora_formatter.dart';
import 'package:flutter/material.dart';

/// Resultado do [abrirFiltroPeriodoSheet]. `null` quando o usuário cancelou.
class PeriodoSelecionado {
  final DateTime dataInicio;
  final DateTime dataFim;
  final bool horaAjustadaManualmente;

  const PeriodoSelecionado({
    required this.dataInicio,
    required this.dataFim,
    this.horaAjustadaManualmente = false,
  });
}

class _PeriodoPreset {
  final String label;
  final DateTimeRange range;

  const _PeriodoPreset(this.label, this.range);
}

List<_PeriodoPreset> _presetsDePeriodo() {
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final ontem = hoje.subtract(const Duration(days: 1));
  final inicioMes = DateTime(agora.year, agora.month, 1);

  return [
    _PeriodoPreset('Hoje', DateTimeRange(start: hoje, end: hoje)),
    _PeriodoPreset('Ontem', DateTimeRange(start: ontem, end: ontem)),
    _PeriodoPreset(
      'Últimos 7 dias',
      DateTimeRange(start: hoje.subtract(const Duration(days: 6)), end: hoje),
    ),
    _PeriodoPreset(
      'Últimos 30 dias',
      DateTimeRange(
        start: hoje.subtract(const Duration(days: 29)),
        end: hoje,
      ),
    ),
    _PeriodoPreset('Este mês', DateTimeRange(start: inicioMes, end: hoje)),
  ];
}

/// Bottom sheet padrão de seleção de período: chips de preset (Hoje / Ontem /
/// Últimos 7 dias / Últimos 30 dias / Este mês / Personalizado), dialog
/// nativo (`showDateRangePicker` em modo `input`) para intervalo customizado
/// e, quando [permitirHora] é `true`, botões de hora inicial/final (24h) com
/// toggle "Dia inteiro". Mudanças só são aplicadas ao tocar "Aplicar";
/// cancelar ou fechar pelo barrier descarta tudo.
Future<PeriodoSelecionado?> abrirFiltroPeriodoSheet({
  required BuildContext context,
  required DateTime dataInicioAtual,
  required DateTime dataFimAtual,
  bool horaAjustadaManualmenteAtual = false,
  DateTime? firstDate,
  DateTime? lastDate,
  bool permitirHora = true,
}) async {
  var dataInicio = dataInicioAtual;
  var dataFim = dataFimAtual;
  var horaAjustadaManualmente = permitirHora && horaAjustadaManualmenteAtual;
  var aplicar = false;

  final presets = _presetsDePeriodo();

  bool diaUnicoDe(DateTime inicio, DateTime fim) =>
      inicio.year == fim.year &&
      inicio.month == fim.month &&
      inicio.day == fim.day;

  void definirDiaInteiro(
    DateTime inicio,
    DateTime fim,
    void Function(void Function()) setSheetState,
  ) {
    setSheetState(() {
      dataInicio = DateTime(inicio.year, inicio.month, inicio.day);
      dataFim = DateTime(fim.year, fim.month, fim.day, 23, 59);
      horaAjustadaManualmente = false;
    });
  }

  void aplicarPreset(
    _PeriodoPreset preset,
    BuildContext sheetContext,
    void Function(void Function()) setSheetState,
  ) {
    definirDiaInteiro(preset.range.start, preset.range.end, setSheetState);
    aplicar = true;
    Navigator.of(sheetContext).pop();
  }

  Future<void> selecionarPeriodo(
    BuildContext dialogContext,
    void Function(void Function()) setSheetState,
  ) async {
    final range = await showDateRangePicker(
      context: dialogContext,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: DateTimeRange(start: dataInicio, end: dataFim),
      firstDate: firstDate ?? DateTime(dataInicio.year - 5),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 1)),
      helpText: 'Filtrar por período',
    );
    if (range == null || !dialogContext.mounted) return;

    final diaUnico = diaUnicoDe(range.start, range.end);
    if (!permitirHora || (diaUnico && !horaAjustadaManualmente)) {
      definirDiaInteiro(range.start, range.end, setSheetState);
      return;
    }

    final horaInicio = TimeOfDay.fromDateTime(dataInicio);
    final horaFim = TimeOfDay.fromDateTime(dataFim);
    setSheetState(() {
      dataInicio = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
        horaInicio.hour,
        horaInicio.minute,
      );
      dataFim = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        horaFim.hour,
        horaFim.minute,
      );
    });
  }

  Future<void> selecionarHora(
    bool inicio,
    BuildContext dialogContext,
    void Function(void Function()) setSheetState,
  ) async {
    final atual = inicio ? dataInicio : dataFim;
    final hora = await showTimePicker(
      context: dialogContext,
      initialTime: TimeOfDay.fromDateTime(atual),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hora == null || !dialogContext.mounted) return;
    setSheetState(() {
      horaAjustadaManualmente = true;
      if (inicio) {
        dataInicio = DateTime(
          dataInicio.year,
          dataInicio.month,
          dataInicio.day,
          hora.hour,
          hora.minute,
        );
      } else {
        dataFim = DateTime(
          dataFim.year,
          dataFim.month,
          dataFim.day,
          hora.hour,
          hora.minute,
        );
      }
    });
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final diaUnico = diaUnicoDe(dataInicio, dataFim);
          final diaInteiro = diaUnico && !horaAjustadaManualmente;
          final presetSelecionado = presets.indexWhere(
            (p) =>
                dataInicio ==
                    DateTime(
                      p.range.start.year,
                      p.range.start.month,
                      p.range.start.day,
                    ) &&
                dataFim ==
                    DateTime(
                      p.range.end.year,
                      p.range.end.month,
                      p.range.end.day,
                      23,
                      59,
                    ) &&
                !horaAjustadaManualmente,
          );

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por período',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < presets.length; i++)
                      ChoiceChip(
                        label: Text(presets[i].label),
                        selected: presetSelecionado == i,
                        onSelected: (_) => aplicarPreset(
                          presets[i],
                          sheetContext,
                          setSheetState,
                        ),
                      ),
                    ChoiceChip(
                      label: const Text('Personalizado'),
                      selected: presetSelecionado == -1,
                      onSelected: (_) =>
                          selecionarPeriodo(sheetContext, setSheetState),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      selecionarPeriodo(sheetContext, setSheetState),
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    '${formatarData(dataInicio)} - ${formatarData(dataFim)}',
                  ),
                ),
                if (permitirHora) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              selecionarHora(true, sheetContext, setSheetState),
                          icon: const Icon(Icons.schedule),
                          label: Text('Início: ${formatarHora(dataInicio)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => selecionarHora(
                            false,
                            sheetContext,
                            setSheetState,
                          ),
                          icon: const Icon(Icons.schedule),
                          label: Text('Fim: ${formatarHora(dataFim)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dia inteiro'),
                    value: diaInteiro,
                    onChanged: !diaUnico
                        ? null
                        : (ligado) {
                            if (ligado) {
                              definirDiaInteiro(
                                dataInicio,
                                dataFim,
                                setSheetState,
                              );
                            } else {
                              setSheetState(
                                () => horaAjustadaManualmente = true,
                              );
                            }
                          },
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        aplicar = true;
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (!aplicar) return null;
  return PeriodoSelecionado(
    dataInicio: dataInicio,
    dataFim: dataFim,
    horaAjustadaManualmente: horaAjustadaManualmente,
  );
}
