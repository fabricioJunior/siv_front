part of 'ecommerce_referencia_detalhe_bloc.dart';

abstract class EcommerceReferenciaDetalheEvent extends Equatable {
  const EcommerceReferenciaDetalheEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceReferenciaDetalheIniciou
    extends EcommerceReferenciaDetalheEvent {
  final int ecommerceId;
  // id do vínculo EcommerceReferencia (usado pra publicar/despublicar).
  final int referenciaEcommerceId;
  // id da referência de produto em si (usado pra listar os SKUs).
  final int referenciaId;
  final bool rascunho;

  const EcommerceReferenciaDetalheIniciou({
    required this.ecommerceId,
    required this.referenciaEcommerceId,
    required this.referenciaId,
    required this.rascunho,
  });

  @override
  List<Object?> get props =>
      [ecommerceId, referenciaEcommerceId, referenciaId, rascunho];
}

class EcommerceProdutoDisponibilidadeAlterou
    extends EcommerceReferenciaDetalheEvent {
  final int produtoId;
  final bool disponivel;

  const EcommerceProdutoDisponibilidadeAlterou({
    required this.produtoId,
    required this.disponivel,
  });

  @override
  List<Object?> get props => [produtoId, disponivel];
}

class EcommercePublicacaoAlterou extends EcommerceReferenciaDetalheEvent {
  final bool rascunho;

  const EcommercePublicacaoAlterou({required this.rascunho});

  @override
  List<Object?> get props => [rascunho];
}

class EcommercePublicarDisponiveisSolicitou
    extends EcommerceReferenciaDetalheEvent {
  const EcommercePublicarDisponiveisSolicitou();
}

class EcommerceRemoverSemEstoqueSolicitou
    extends EcommerceReferenciaDetalheEvent {
  const EcommerceRemoverSemEstoqueSolicitou();
}
