import 'dart:io';
import 'dart:typed_data';

import 'package:core/services/download_arquivo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Wrapper fino sobre `file_picker` — evita dependência direta de package
/// de terceiro fora do core (ver convenção do projeto).
class ArquivoService {
  /// Abre o seletor nativo de arquivos restrito às [extensoes] informadas
  /// (sem o ponto, ex: `['pfx', 'p12']`). Retorna o path local do arquivo
  /// escolhido, ou `null` se o usuário cancelar.
  Future<String?> selecionarArquivo({List<String>? extensoes}) async {
    final result = await FilePicker.platform.pickFiles(
      type: extensoes == null ? FileType.any : FileType.custom,
      allowedExtensions: extensoes,
    );
    return result?.files.single.path;
  }

  /// Salva [bytes] como [nomeSugerido]. Retorna o path final (ou o nome do arquivo, na web, onde
  /// o navegador decide o destino), ou `null` se o usuário cancelar.
  ///
  /// - Web: o `file_picker` não implementa `saveFile` (lança `UnimplementedError`), então o
  ///   download é feito pelo navegador.
  /// - Android/iOS: o plugin grava o arquivo e EXIGE os [bytes] no `saveFile`.
  /// - Desktop: o plugin só abre o diálogo e devolve o caminho; quem grava é o app. Não pode
  ///   receber `bytes`: no macOS lança `UnsupportedError('Bytes are not supported on macOS')`
  ///   (Windows/Linux ignoram).
  Future<String?> salvarBytes({
    required Uint8List bytes,
    required String nomeSugerido,
  }) async {
    if (kIsWeb) {
      baixarNoNavegador(bytes, nomeSugerido);
      return nomeSugerido;
    }

    final mobile = Platform.isAndroid || Platform.isIOS;
    final path = await FilePicker.platform.saveFile(
      fileName: nomeSugerido,
      bytes: mobile ? bytes : null,
    );
    if (path == null) return null;
    if (!mobile) await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Abre o seletor nativo e devolve os bytes do arquivo escolhido -- ao
  /// contrário de [selecionarArquivo] (que só devolve o path), funciona
  /// também no Flutter Web, onde não existe `dart:io` File local.
  Future<ArquivoSelecionado?> selecionarArquivoComBytes({
    List<String>? extensoes,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: extensoes == null ? FileType.any : FileType.custom,
      allowedExtensions: extensoes,
      withData: true,
    );
    final arquivo = result?.files.single;
    if (arquivo?.bytes == null) return null;
    return ArquivoSelecionado(
      nome: arquivo!.name,
      bytes: arquivo.bytes!,
      tamanho: arquivo.size,
    );
  }
}

class ArquivoSelecionado {
  final String nome;
  final Uint8List bytes;
  final int tamanho;

  const ArquivoSelecionado({
    required this.nome,
    required this.bytes,
    required this.tamanho,
  });
}
