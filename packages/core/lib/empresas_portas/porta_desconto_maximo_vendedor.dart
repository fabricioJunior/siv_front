abstract class PortaDescontoMaximoVendedor {
  /// Percentual máximo de desconto manual do vendedor (0 = sem limite).
  Future<double> call({required int empresaId});
}
