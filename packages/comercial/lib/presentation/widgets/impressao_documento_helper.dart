import 'dart:typed_data';

import 'package:core/impressora.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

/// Fluxo reutilizavel de impressao de documentos (nota fiscal, romaneio)
/// em impressora termica: seleciona a impressora (pre-marcada com a
/// preferida salva para [TipoImpressora.documento]), gera os bytes do PDF
/// sob demanda e envia para impressao, com feedback de loading/erro.
Future<void> imprimirDocumentoPdf(
  BuildContext context, {
  required String titulo,
  required Future<Uint8List> Function() gerarBytes,
  required String nomeDocumento,
}) async {
  final impressoras = sl<IPrintersService>()
      .getAvailablePrinters()
      .where((impressora) => impressora.isAvailable)
      .toList(growable: false);

  if (impressoras.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nenhuma impressora disponível.')),
    );
    return;
  }

  Impressora? selecionada;

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: 380,
          child: SeletorImpressora(
            tipo: TipoImpressora.documento,
            onChanged: (impressora) => selecionada = impressora,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Imprimir'),
          ),
        ],
      );
    },
  );

  if (confirmou != true || selecionada == null || !context.mounted) return;
  final impressoraSelecionada = selecionada!;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final bytes = await gerarBytes();
    final sucesso = await sl<IPrintersService>().printPdf(
      impressoraSelecionada,
      bytes,
      docName: nomeDocumento,
    );

    if (sucesso) {
      await sl<SalvarImpressoraPreferida>().call(
        tipo: TipoImpressora.documento,
        nomeImpressora: impressoraSelecionada.name,
      );
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Enviado para impressão em ${impressoraSelecionada.name}.'
              : 'Falha ao enviar para impressão.',
        ),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao preparar ou imprimir o documento.')),
    );
  }
}
