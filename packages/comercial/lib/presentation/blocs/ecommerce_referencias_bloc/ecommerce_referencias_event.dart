part of 'ecommerce_referencias_bloc.dart';

abstract class EcommerceReferenciasEvent extends Equatable {
  const EcommerceReferenciasEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceReferenciasIniciou extends EcommerceReferenciasEvent {
  final int ecommerceId;

  const EcommerceReferenciasIniciou({required this.ecommerceId});

  @override
  List<Object?> get props => [ecommerceId];
}

class EcommerceReferenciaAdicionou extends EcommerceReferenciasEvent {
  final int ecommerceId;
  final int referenciaId;
  final int? tabelaDePrecoId;

  const EcommerceReferenciaAdicionou({
    required this.ecommerceId,
    required this.referenciaId,
    this.tabelaDePrecoId,
  });

  @override
  List<Object?> get props => [ecommerceId, referenciaId, tabelaDePrecoId];
}

class EcommerceReferenciaPublicarSolicitou
    extends EcommerceReferenciasEvent {
  final int ecommerceId;
  final int referenciaEcommerceId;

  const EcommerceReferenciaPublicarSolicitou({
    required this.ecommerceId,
    required this.referenciaEcommerceId,
  });

  @override
  List<Object?> get props => [ecommerceId, referenciaEcommerceId];
}

class EcommerceReferenciasDespublicarTodasSolicitou
    extends EcommerceReferenciasEvent {
  final int ecommerceId;

  const EcommerceReferenciasDespublicarTodasSolicitou({
    required this.ecommerceId,
  });

  @override
  List<Object?> get props => [ecommerceId];
}
