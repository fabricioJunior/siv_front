import 'package:flutter/material.dart';

/// Formulário de endereço usado nos pontos de partida/destino da entrega
/// avulsa. Não reaproveita o cadastro de endereço de `pessoas` (wizard
/// passo-a-passo com CEP + bloc próprio) porque o contrato do backend exige
/// lat/lng e referência, campos que o modelo `Endereco` de `pessoas` não tem
/// — mais simples um formulário dedicado e enxuto aqui.
class EnderecoEntregaControllers {
  final endereco = TextEditingController();
  final bairro = TextEditingController();
  final complemento = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final referencia = TextEditingController();
  final lat = TextEditingController();
  final lng = TextEditingController();

  void dispose() {
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

class EnderecoEntregaForm extends StatelessWidget {
  final String titulo;
  final EnderecoEntregaControllers controllers;

  const EnderecoEntregaForm({
    super.key,
    required this.titulo,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleSmall),
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
