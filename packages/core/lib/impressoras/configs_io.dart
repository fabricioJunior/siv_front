import 'dart:io';

import 'package:printing_ffi/printing_ffi.dart';

void initPrintingConfigs() {
  if (Platform.isWindows) {
    PrintingFfi.instance.initPdfium();
  }
}
