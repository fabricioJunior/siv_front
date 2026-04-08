import 'package:flutter/material.dart';
import 'package:core/seletores.dart';

class SeletorPessoa extends StatelessWidget implements ISeletor {
  final bool retornarSomenteId;
  final Map<String, String>? valorAtual;
  final ValueChanged<Map<String, String>> onSelecionado;
  final String rotaSelecao;
  final String? titulo;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  const SeletorPessoa({
    super.key,
    required this.retornarSomenteId,
    required this.onSelecionado,
    this.valorAtual,
    this.rotaSelecao = '/selecionar_pessoa',
    this.titulo,
    this.itemsSelecionadosInicial,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nome = valorAtual?['nome'] ?? '';
    final documento = valorAtual?['documento'] ?? '';
    final possuiValor = nome.trim().isNotEmpty || documento.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) ...[
          Text(
            titulo!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
              rotaSelecao,
              arguments: {
                'retornarSomenteId': retornarSomenteId,
              },
            );

            if (result is Map<String, String>) {
              onSelecionado(result);
              onChanged?.call([
                SelectData(
                  id: int.tryParse(result['id'] ?? '') ?? 0,
                  nome: result['nome'] ?? '',
                  data: result,
                ),
              ]);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Pessoa',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.search),
            ),
            child: possuiValor
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nome),
                      if (documento.trim().isNotEmpty)
                        Text(
                          documento,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  )
                : const Text('Toque para selecionar uma pessoa'),
          ),
        ),
      ],
    );
  }
}
