import 'package:core/impressora.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fluxo reutilizavel de impressao de documentos (nota fiscal, romaneio)
/// em impressora termica: seleciona a impressora (pre-marcada com a
/// preferida salva para [TipoImpressora.documento]), gera os bytes do PDF
/// sob demanda e envia para impressao, com feedback de loading/erro.
///
/// [obterAvisoServidor], se informado, e chamado logo apos [gerarBytes] pra
/// checar se o PDF gerado veio de um fallback local por falha ao buscar o
/// documento oficial no servidor (ex: DANFE indisponivel na webMania) --
/// quando retorna nao-nulo, mostra o erro do servidor mesmo com a impressao
/// tendo dado certo (com o layout local).
Future<void> imprimirDocumentoPdf(
  BuildContext context, {
  required String titulo,
  required Future<Uint8List> Function() gerarBytes,
  required String nomeDocumento,
  Object? Function()? obterAvisoServidor,
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

    final avisoServidor = obterAvisoServidor?.call();

    if (!sucesso) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final motivoServidor = avisoServidor == null
          ? ''
          : '\n\nAlém disso, o documento oficial não pôde ser buscado no servidor: '
              '${mensagemDeErroApi(avisoServidor, avisoServidor.toString())}';
      await _mostrarErroImpressao(
        context,
        'Erro ao imprimir',
        'A impressora "${impressoraSelecionada.name}" recusou o trabalho de impressão '
            '(sem detalhe adicional retornado pelo driver).$motivoServidor',
      );
      return;
    }

    await sl<SalvarImpressoraPreferida>().call(
      tipo: TipoImpressora.documento,
      nomeImpressora: impressoraSelecionada.name,
    );

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (avisoServidor != null) {
      // Impressao deu certo, mas com o layout de fallback local -- o
      // documento oficial (ex: DANFE da webMania) nao pode ser buscado no
      // servidor. Erro real do servidor precisa aparecer mesmo com sucesso
      // na impressao, senao o usuario nunca fica sabendo que imprimiu uma
      // versao provisoria.
      await _mostrarErroImpressao(
        context,
        'Impresso com layout local (documento oficial indisponível)',
        'Enviado para impressão em ${impressoraSelecionada.name}, mas usando um layout '
            'local simplificado -- não foi possível buscar o documento oficial no '
            'servidor:\n\n${mensagemDeErroApi(avisoServidor, avisoServidor.toString())}',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviado para impressão em ${impressoraSelecionada.name}.'),
      ),
    );
  } catch (erro, stackTrace) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    await _mostrarErroImpressao(
      context,
      'Erro ao imprimir',
      '${mensagemDeErroApi(erro, '$erro')}\n\n$erro\n\n$stackTrace',
    );
  }
}

/// Adapta um gerador de PDF que retorna `(bytes, erroServidor)` (ex:
/// [NotaFiscalPdfExporter.gerarBytes]) pro par `gerarBytes`/
/// `obterAvisoServidor` esperado por [imprimirDocumentoPdf].
({
  Future<Uint8List> Function() gerarBytes,
  Object? Function() obterAvisoServidor,
}) comAvisoServidor(
  Future<({Uint8List bytes, Object? erroServidor})> Function() gerar,
) {
  Object? ultimoErro;
  return (
    gerarBytes: () async {
      final resultado = await gerar();
      ultimoErro = resultado.erroServidor;
      return resultado.bytes;
    },
    obterAvisoServidor: () => ultimoErro,
  );
}

/// Mostra o erro/excecao completo em dialog selecionavel (com botao de
/// copiar), pra usuario poder ler ou repassar pro suporte -- em vez do
/// snackbar generico que escondia a causa real da falha (de impressao ou
/// de comunicacao com o servidor).
Future<void> _mostrarErroImpressao(
  BuildContext context,
  String titulo,
  String detalhe,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(titulo),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: SelectableText(detalhe, style: const TextStyle(fontSize: 12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: detalhe));
            if (dialogContext.mounted) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Erro copiado.')),
              );
            }
          },
          child: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}
