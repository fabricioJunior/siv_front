abstract class Codigo {
  String get codigo;
  TipoCodigo get tipo;
  int get produtoId;
}

enum TipoCodigo { ean13, rfid, ean8, upca, upce }
