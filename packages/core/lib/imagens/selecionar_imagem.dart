import 'package:core/imagens.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

/// Exibe um modal com opções para selecionar imagem da galeria ou da câmera.
/// Retorna um [Imagem] ou null se o usuário cancelar.
Future<List<Imagem>?> showSelecionarImagemModal(
  BuildContext context, {
  bool allowMultiple = false,
}) async {
  return showModalBottomSheet<List<Imagem>?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () async {
                var images = await _getImagens(
                  fromCamera: false,
                  allowMultiple: allowMultiple,
                );
                if (images == null) {
                  return;
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(images);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () async {
                var images = await _getImagens(
                  fromCamera: true,
                  allowMultiple: allowMultiple,
                );
                if (images == null) {
                  return;
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(images);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<List<Imagem>?> _getImagens({
  required bool fromCamera,
  bool allowMultiple = false,
}) async {
  if (allowMultiple) {
    final List<XFile> xFiles = await _picker.pickMultiImage();
    if (xFiles.isEmpty) {
      return null;
    }
    List<Imagem> imagens = [];
    for (var xfile in xFiles) {
      final bytes = await xfile.readAsBytes();
      imagens.add(Imagem(path: xfile.path, bytes: bytes));
    }
    return imagens;
  } else {}
  final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery);
  if (image == null) {
    return null;
  }
  return [Imagem(path: image.path, bytes: await image.readAsBytes())];
}
