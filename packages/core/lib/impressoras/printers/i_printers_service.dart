abstract class IPrintersService {
  List<Impressora> getAvailablePrinters();
  Future<bool> printZpl(Impressora printer, String zplCommands);
}

class Impressora {
  final String name;
  final String model;
  final String location;
  final bool isAvailable;

  Impressora({
    required this.name,
    required this.model,
    required this.location,
    required this.isAvailable,
  });
}
