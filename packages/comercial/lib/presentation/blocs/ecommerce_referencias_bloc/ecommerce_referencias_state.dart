part of 'ecommerce_referencias_bloc.dart';

abstract class EcommerceReferenciasState extends Equatable {
  int? get ecommerceId => null;
  List<EcommerceReferencia> get referencias => const [];
  bool get processandoLote => false;
  String? get busca => null;

  const EcommerceReferenciasState();

  @override
  List<Object?> get props =>
      [ecommerceId, referencias, processandoLote, busca];
}

class EcommerceReferenciasInitial extends EcommerceReferenciasState {
  const EcommerceReferenciasInitial();
}

class EcommerceReferenciasCarregarEmProgresso
    extends EcommerceReferenciasState {
  const EcommerceReferenciasCarregarEmProgresso();
}

class EcommerceReferenciasCarregarSucesso extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;
  @override
  final bool processandoLote;
  @override
  final String? busca;

  const EcommerceReferenciasCarregarSucesso({
    required this.ecommerceId,
    required this.referencias,
    this.processandoLote = false,
    this.busca,
  });
}

class EcommerceReferenciasCarregarFalha extends EcommerceReferenciasState {
  const EcommerceReferenciasCarregarFalha();
}

class EcommerceReferenciasAdicionarFalha extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;

  const EcommerceReferenciasAdicionarFalha({
    required this.ecommerceId,
    required this.referencias,
  });
}

class EcommerceReferenciasDespublicarTodasFalha
    extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;

  const EcommerceReferenciasDespublicarTodasFalha({
    required this.ecommerceId,
    required this.referencias,
  });
}
