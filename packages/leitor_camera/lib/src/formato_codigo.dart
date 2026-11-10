import 'package:mobile_scanner/mobile_scanner.dart' as ms;

enum FormatoCodigo {
  ean13(ms.BarcodeFormat.ean13),
  ean8(ms.BarcodeFormat.ean8),
  code128(ms.BarcodeFormat.code128),
  code39(ms.BarcodeFormat.code39),
  qr(ms.BarcodeFormat.qrCode);

  const FormatoCodigo(this.interno);

  final ms.BarcodeFormat interno;

  static const padrao = FormatoCodigo.values;
}
