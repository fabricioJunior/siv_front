import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:printing_ffi/printing_ffi.dart';

class PrintersService implements IPrintersService {
  @override
  List<Impressora> getAvailablePrinters() {
    final printingFfi = PrintingFfi.instance;
    final printers = printingFfi.listPrinters();

    return printers
        .map(
          (printer) => Impressora(
            name: printer.name,
            model: printer.model ?? 'Desconecido',
            location: printer.location ?? 'Desconecido',
            isAvailable: printer.isAvailable,
          ),
        )
        .toList();
  }

  @override
  Future<bool> printZpl(Impressora printer, String zplCommands) async {
    final printingFfi = PrintingFfi.instance;
    final data = Uint8List.fromList(zplCommands.codeUnits);
    log(zplCommands);
    try {
      final success = await printingFfi.rawDataToPrinter(
        printer.name,
        data,
        docName: 'ZPL Label',
        options: [
          const OrientationOption(WindowsOrientation.portrait),
        ],
      );
      return success;
    } catch (e) {
      log('Error printing ZPL: $e');
      return false;
    }
  }

  @override
  Future<bool> printPdf(
    Impressora printer,
    Uint8List pdfBytes, {
    String docName = 'Documento',
  }) async {
    try {
      final tempDir = await path_provider.getTemporaryDirectory();
      final nomeSanitizado = docName.replaceAll(RegExp(r'[^\w\-]'), '_');
      final arquivo = File(
        '${tempDir.path}/${nomeSanitizado}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await arquivo.writeAsBytes(pdfBytes);

      final printingFfi = PrintingFfi.instance;
      final success = await printingFfi.printPdf(
        printer.name,
        arquivo.path,
        docName: docName,
      );
      return success;
    } catch (e) {
      log('Error printing PDF: $e');
      return false;
    }
  }
}
