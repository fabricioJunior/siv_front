part of 'ecommerce_referencias_bloc.dart';

abstract class EcommerceReferenciasEvent extends Equatable {
  const EcommerceReferenciasEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceReferenciasIniciou extends EcommerceReferenciasEvent {
  final int ecommerceId;
  final String? busca;

  const EcommerceReferenciasIniciou({required this.ecommerceId, this.busca});

  @override
  List<Object?> get props => [ecommerceId, busca];
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
  // false = publicar, true = despublicar (mesmo campo que o backend espera).
  final bool rascunho;

  const EcommerceReferenciaPublicarSolicitou({
    required this.ecommerceId,
    required this.referenciaEcommerceId,
    this.rascunho = false,
  });

  @override
  List<Object?> get props => [ecommerceId, referenciaEcommerceId, rascunho];
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
