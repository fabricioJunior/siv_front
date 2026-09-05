import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

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

  /// Abre o diálogo nativo "Salvar como" sugerindo [nomeSugerido] e grava
  /// [bytes] no arquivo escolhido. Retorna o path final, ou `null` se o
  /// usuário cancelar.
  Future<String?> salvarBytes({
    required Uint8List bytes,
    required String nomeSugerido,
  }) async {
    final path = await FilePicker.platform.saveFile(
      fileName: nomeSugerido,
    );
    if (path == null) return null;
    await File(path).writeAsBytes(bytes);
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
