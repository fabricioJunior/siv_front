import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

import 'formato_codigo.dart';

const mensagemPermissaoNegada =
    'Permissão da câmera negada. Libere o acesso à câmera nas configurações para ler o código.';

/// Constrói a câmera. Seam para testes: substitui o mobile_scanner real.
typedef ConstrutorCamera = Widget Function(
  BuildContext context,
  List<FormatoCodigo> formatos,
  void Function(String codigo) onCodigo,
  void Function(Object erro, bool permissaoNegada) onErro,
);

/// Câmera embutível com mira e linha de leitura. Chama [onCodigo] uma vez.
class LeitorCameraView extends StatefulWidget {
  const LeitorCameraView({
    super.key,
    required this.onCodigo,
    this.formatos = FormatoCodigo.padrao,
    this.onErro,
    this.onPermissaoNegada,
    this.construtorCamera,
  });

  final void Function(String codigo) onCodigo;
  final List<FormatoCodigo> formatos;
  final void Function(Object erro)? onErro;
  final VoidCallback? onPermissaoNegada;
  final ConstrutorCamera? construtorCamera;

  @override
  State<LeitorCameraView> createState() => _LeitorCameraViewState();
}

class _LeitorCameraViewState extends State<LeitorCameraView>
    with SingleTickerProviderStateMixin {
  late final _linha = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  ms.MobileScannerController? _controller;
  bool _resolvido = false;
  bool _permissaoNegada = false;

  @override
  void initState() {
    super.initState();
    if (widget.construtorCamera == null) {
      _controller = ms.MobileScannerController(
        detectionSpeed: ms.DetectionSpeed.noDuplicates,
        facing: ms.CameraFacing.back,
        formats: [for (final f in widget.formatos) f.interno],
      );
    }
  }

  @override
  void dispose() {
    _linha.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _codigo(String codigo) {
    if (_resolvido || codigo.isEmpty) return;
    _resolvido = true;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    widget.onCodigo(codigo);
  }

  void _erro(Object erro, bool permissaoNegada) {
    if (_resolvido) return;
    _resolvido = true;
    // Notifica fora do build (chamado de errorBuilder).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (permissaoNegada) {
        setState(() => _permissaoNegada = true);
        widget.onPermissaoNegada?.call();
      }
      widget.onErro?.call(erro);
    });
  }

  void _onDetect(ms.BarcodeCapture captura) {
    for (final b in captura.barcodes) {
      final valor = b.rawValue;
      if (valor != null && valor.isNotEmpty) return _codigo(valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissaoNegada) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(mensagemPermissaoNegada, textAlign: TextAlign.center),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.scrim,
      child: LayoutBuilder(builder: (context, c) {
        final janela = Rect.fromCenter(
          center: c.biggest.center(Offset.zero),
          width: (c.maxWidth - 32).clamp(0, 280).toDouble(),
          height: (c.maxHeight - 32).clamp(0, 180).toDouble(),
        );
        final fonte = widget.construtorCamera;
        return Stack(fit: StackFit.expand, children: [
          if (fonte != null)
            fonte(context, widget.formatos, _codigo, _erro)
          else
            ms.MobileScanner(
              controller: _controller,
              scanWindow: janela,
              onDetect: _onDetect,
              errorBuilder: (context, e) {
                _erro(e, e.errorCode == ms.MobileScannerErrorCode.permissionDenied);
                return const SizedBox.expand();
              },
            ),
          Positioned.fromRect(
            rect: janela,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.onInverseSurface, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedBuilder(
                  animation: _linha,
                  builder: (_, _) => Align(
                    alignment: Alignment(0, _linha.value * 2 - 1),
                    child: Container(height: 2, color: scheme.error),
                  ),
                ),
              ),
            ),
          ),
          if (_controller != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: _Acoes(controller: _controller!),
            ),
        ]);
      }),
    );
  }
}

class _Acoes extends StatelessWidget {
  const _Acoes({required this.controller});

  final ms.MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onInverseSurface;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, estado, _) {
        final temLanterna = estado.torchState != ms.TorchState.unavailable;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          if (temLanterna)
            IconButton(
              tooltip: 'Lanterna',
              color: cor,
              onPressed: controller.toggleTorch,
              icon: Icon(estado.torchState == ms.TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off),
            ),
          if ((estado.availableCameras ?? 2) > 1)
            IconButton(
              tooltip: 'Trocar câmera',
              color: cor,
              onPressed: controller.switchCamera,
              icon: const Icon(Icons.cameraswitch),
            ),
        ]);
      },
    );
  }
}
