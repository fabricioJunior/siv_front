import 'package:core/cep.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formulário de endereço usado nos pontos de partida/destino da entrega
/// avulsa. Não reaproveita o cadastro de endereço de `pessoas` (wizard
/// passo-a-passo com CEP + bloc próprio) porque o contrato do backend exige
/// lat/lng e referência, campos que o modelo `Endereco` de `pessoas` não tem
/// — mais simples um formulário dedicado e enxuto aqui.
class EnderecoEntregaControllers {
  final cep = TextEditingController();
  final endereco = TextEditingController();
  final bairro = TextEditingController();
  final complemento = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final referencia = TextEditingController();
  final lat = TextEditingController();
  final lng = TextEditingController();

  void dispose() {
    cep.dispose();
    endereco.dispose();
    bairro.dispose();
    complemento.dispose();
    cidade.dispose();
    estado.dispose();
    referencia.dispose();
    lat.dispose();
    lng.dispose();
  }
}

class EnderecoEntregaForm extends StatefulWidget {
  final String titulo;
  final EnderecoEntregaControllers controllers;

  const EnderecoEntregaForm({
    super.key,
    required this.titulo,
    required this.controllers,
  });

  @override
  State<EnderecoEntregaForm> createState() => _EnderecoEntregaFormState();
}

class _EnderecoEntregaFormState extends State<EnderecoEntregaForm> {
  bool _buscandoCep = false;
  String? _erroCep;

  Future<void> _buscarCep() async {
    final cep = widget.controllers.cep.text.trim();
    if (cep.length != 8) {
      setState(() => _erroCep = 'Digite um CEP válido');
      return;
    }
    setState(() {
      _buscandoCep = true;
      _erroCep = null;
    });
    try {
      final endereco = await sl<CepService>().recuperaEnderecoPeloCep(cep);
      widget.controllers.endereco.text = endereco.logradouro;
      widget.controllers.bairro.text = endereco.bairro;
      widget.controllers.cidade.text = endereco.localidade;
      widget.controllers.estado.text = endereco.uf;
      setState(() => _buscandoCep = false);
    } catch (_) {
      setState(() {
        _buscandoCep = false;
        _erroCep = 'CEP não encontrado. Preencha manualmente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllers = widget.controllers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.cep,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                enabled: !_buscandoCep,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  border: const OutlineInputBorder(),
                  errorText: _erroCep,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _buscandoCep ? null : _buscarCep,
              icon: _buscandoCep
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Buscar CEP'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers.endereco,
          decoration: const InputDecoration(
            labelText: 'Endereço *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.bairro,
                decoration: const InputDecoration(
                  labelText: 'Bairro *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controllers.complemento,
                decoration: const InputDecoration(
                  labelText: 'Complemento',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.cidade,
                decoration: const InputDecoration(
                  labelText: 'Cidade *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: controllers.estado,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'UF *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers.referencia,
          decoration: const InputDecoration(
            labelText: 'Ponto de referência',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.lat,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controllers.lng,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
