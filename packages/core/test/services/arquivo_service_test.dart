import 'dart:io';
import 'dart:typed_data';

import 'package:core/arquivos.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Simula o file_picker de desktop: só devolve o caminho escolhido e, como no macOS, recusa `bytes`.
class _FilePickerDesktopFake extends FilePicker with MockPlatformInterfaceMixin {
  final String? caminho;
  Uint8List? bytesRecebidos;
  String? nomeRecebido;

  _FilePickerDesktopFake(this.caminho);

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    bytesRecebidos = bytes;
    nomeRecebido = fileName;
    if (bytes != null) throw UnsupportedError('Bytes are not supported on macOS');
    return caminho;
  }
}

void main() {
  final desktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  test('desktop: não passa bytes ao file_picker (macOS recusa) e grava o arquivo no caminho escolhido', () async {
    final pasta = Directory.systemTemp.createTempSync('arquivo_service_test');
    final destino = '${pasta.path}/modelo.csv';
    final fake = _FilePickerDesktopFake(destino);
    FilePicker.platform = fake;

    final path = await ArquivoService().salvarBytes(
      bytes: Uint8List.fromList([1, 2, 3]),
      nomeSugerido: 'modelo.csv',
    );

    expect(fake.bytesRecebidos, isNull);
    expect(fake.nomeRecebido, 'modelo.csv');
    expect(path, destino);
    expect(File(destino).readAsBytesSync(), [1, 2, 3]);
    pasta.deleteSync(recursive: true);
  }, skip: !desktop);

  test('desktop: usuário cancela o diálogo -> null e nada é gravado', () async {
    FilePicker.platform = _FilePickerDesktopFake(null);

    final path = await ArquivoService().salvarBytes(
      bytes: Uint8List.fromList([1]),
      nomeSugerido: 'x.csv',
    );

    expect(path, isNull);
  }, skip: !desktop);
}
