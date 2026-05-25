import 'package:flutter/material.dart';

class EtiquetaCampoOpcaoModal {
  const EtiquetaCampoOpcaoModal({
    required this.nome,
    required this.descricao,
  });

  final String nome;
  final String descricao;
}

Future<String?> showEtiquetaAddFieldModal(
  BuildContext context, {
  required List<EtiquetaCampoOpcaoModal> opcoes,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return ListView(
        shrinkWrap: true,
        children: [
          const ListTile(
            title: Text('Adicionar campo'),
            subtitle: Text('Escolha qual dado sera exibido na etiqueta.'),
          ),
          ...opcoes.map(
            (opcao) => ListTile(
              title: Text(opcao.nome),
              subtitle: Text(opcao.descricao),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => Navigator.of(sheetContext).pop(opcao.nome),
            ),
          ),
        ],
      );
    },
  );
}
