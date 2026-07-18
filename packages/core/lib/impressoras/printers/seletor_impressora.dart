import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';
import 'package:core/impressoras/printers/use_cases/obter_impressora_preferida.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

/// Dropdown reutilizavel para selecionar impressora, ja pre-selecionando a
/// impressora preferida salva para o [tipo] informado (etiqueta ou
/// documento -- ver [TipoImpressora]).
class SeletorImpressora extends StatefulWidget {
  final TipoImpressora tipo;
  final ValueChanged<Impressora?> onChanged;

  const SeletorImpressora({
    super.key,
    required this.tipo,
    required this.onChanged,
  });

  @override
  State<SeletorImpressora> createState() => _SeletorImpressoraState();
}

class _SeletorImpressoraState extends State<SeletorImpressora> {
  List<Impressora> _impressoras = const [];
  Impressora? _selecionada;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final impressoras = sl<IPrintersService>()
        .getAvailablePrinters()
        .where((impressora) => impressora.isAvailable)
        .toList(growable: false);

    final nomePreferido =
        await sl<ObterImpressoraPreferida>().call(tipo: widget.tipo);

    Impressora? preferida;
    if (nomePreferido != null) {
      for (final impressora in impressoras) {
        if (impressora.name == nomePreferido) {
          preferida = impressora;
          break;
        }
      }
    }

    final selecionada =
        preferida ?? (impressoras.isNotEmpty ? impressoras.first : null);

    if (!mounted) return;

    setState(() {
      _impressoras = impressoras;
      _selecionada = selecionada;
      _carregando = false;
    });

    widget.onChanged(selecionada);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_impressoras.isEmpty) {
      return const Text('Nenhuma impressora disponível.');
    }

    return DropdownButton<Impressora>(
      value: _selecionada,
      isExpanded: true,
      items: _impressoras
          .map(
            (impressora) => DropdownMenuItem<Impressora>(
              value: impressora,
              child: Text(impressora.name),
            ),
          )
          .toList(growable: false),
      onChanged: (impressora) {
        setState(() => _selecionada = impressora);
        widget.onChanged(impressora);
      },
    );
  }
}
