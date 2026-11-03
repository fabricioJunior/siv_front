import 'package:flutter/material.dart';

import 'formato_codigo.dart';
import 'leitor_camera_view.dart';

class LeitorCamera {
  const LeitorCamera._();

  @visibleForTesting
  static ConstrutorCamera? construtorTeste;

  /// Abre a câmera em tela cheia. Retorna o código lido, ou `null` se
  /// cancelou, permissão negada, erro ou plataforma sem câmera.
  static Future<String?> escanear(
    BuildContext context, {
    List<FormatoCodigo> formatos = FormatoCodigo.padrao,
    String? titulo,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _TelaLeitura(formatos: formatos, titulo: titulo),
        fullscreenDialog: true,
      ),
    );
  }
}

class _TelaLeitura extends StatelessWidget {
  const _TelaLeitura({required this.formatos, this.titulo});

  final List<FormatoCodigo> formatos;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    void fechar([String? codigo]) {
      if (navigator.canPop()) navigator.pop(codigo);
    }

    return Scaffold(
      appBar: AppBar(title: Text(titulo ?? 'Escanear código de barras')),
      body: LeitorCameraView(
        formatos: formatos,
        construtorCamera: LeitorCamera.construtorTeste,
        onCodigo: fechar,
        onErro: (_) => fechar(),
        onPermissaoNegada: () {
          messenger?.showSnackBar(const SnackBar(content: Text(mensagemPermissaoNegada)));
          fechar();
        },
      ),
    );
  }
}
