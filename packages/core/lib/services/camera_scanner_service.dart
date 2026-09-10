import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

/// Encapsula o pacote mobile_scanner. Nenhuma outra camada deve importar
/// mobile_scanner diretamente -- sempre passar por este service.
class CameraScannerService {
  /// Abre uma tela em tela cheia com a câmera para ler um código de barras.
  ///
  /// Retorna o código lido, ou `null` se o usuário cancelou, a permissão de
  /// câmera foi negada, ou o scanner falhou por qualquer outro motivo.
  Future<String?> escanearCodigoDeBarras(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _TelaDeEscaneamento(),
        fullscreenDialog: true,
      ),
    );
  }
}

class _TelaDeEscaneamento extends StatefulWidget {
  const _TelaDeEscaneamento();

  @override
  State<_TelaDeEscaneamento> createState() => _TelaDeEscaneamentoState();
}

class _TelaDeEscaneamentoState extends State<_TelaDeEscaneamento> {
  final _controller = ms.MobileScannerController(
    detectionSpeed: ms.DetectionSpeed.noDuplicates,
  );
  bool _resolvido = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resolver([String? codigo]) {
    if (_resolvido || !mounted) return;
    _resolvido = true;
    Navigator.of(context).pop(codigo);
  }

  void _onDetect(ms.BarcodeCapture captura) {
    final codigo = captura.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((valor) => valor != null && valor.isNotEmpty,
            orElse: () => null);
    if (codigo != null) {
      _resolver(codigo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanhoTela = MediaQuery.sizeOf(context);
    final scanWindow = Rect.fromCenter(
      center: Offset(tamanhoTela.width / 2, tamanhoTela.height / 2),
      width: 260,
      height: 180,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear código de barras'),
      ),
      body: ms.MobileScanner(
        controller: _controller,
        scanWindow: scanWindow,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          // Permissão negada ou qualquer outra falha do scanner: cancela e
          // deixa a tela chamadora cair de volta pra busca manual.
          WidgetsBinding.instance.addPostFrameCallback((_) => _resolver());
          return const ColoredBox(color: Colors.black);
        },
        overlayBuilder: (context, constraints) => CustomPaint(
          painter: _MiraDeLeituraPainter(scanWindow: scanWindow),
        ),
      ),
    );
  }
}

class _MiraDeLeituraPainter extends CustomPainter {
  final Rect scanWindow;

  _MiraDeLeituraPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiraDeLeituraPainter oldPainter) =>
      oldPainter.scanWindow != scanWindow;
}
