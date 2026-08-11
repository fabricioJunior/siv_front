part of 'ecommerce_referencias_bloc.dart';

abstract class EcommerceReferenciasState extends Equatable {
  int? get ecommerceId => null;
  List<EcommerceReferencia> get referencias => const [];

  const EcommerceReferenciasState();

  @override
  List<Object?> get props => [ecommerceId, referencias];
}

class EcommerceReferenciasInitial extends EcommerceReferenciasState {
  const EcommerceReferenciasInitial();
}

class EcommerceReferenciasCarregarEmProgresso extends EcommerceReferenciasState {
  const EcommerceReferenciasCarregarEmProgresso();
}

class EcommerceReferenciasCarregarSucesso extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;

  const EcommerceReferenciasCarregarSucesso({
    required this.ecommerceId,
    required this.referencias,
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
