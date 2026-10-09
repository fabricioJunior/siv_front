part of 'ecommerce_vitrine_bloc.dart';

abstract class EcommerceVitrineEvent extends Equatable {
  const EcommerceVitrineEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceVitrineIniciou extends EcommerceVitrineEvent {
  final int ecommerceId;

  const EcommerceVitrineIniciou({required this.ecommerceId});

  @override
  List<Object?> get props => [ecommerceId];
}

class EcommerceVitrineItemAdicionou extends EcommerceVitrineEvent {
  final VitrineLocal local;
  final VitrineItemTipo tipo;
  final int itemId;

  const EcommerceVitrineItemAdicionou({
    required this.local,
    required this.tipo,
    required this.itemId,
  });

  @override
  List<Object?> get props => [local, tipo, itemId];
}

class EcommerceVitrineItemRemoveu extends EcommerceVitrineEvent {
  final VitrineLocal local;
  final VitrineItemTipo tipo;
  final int itemId;

  const EcommerceVitrineItemRemoveu({
    required this.local,
    required this.tipo,
    required this.itemId,
  });

  @override
  List<Object?> get props => [local, tipo, itemId];
}

/// Move o item para o [indice] (0-based) da lista; os demais deslocam e a
/// ordem é renumerada 0..n-1.
class EcommerceVitrineItemMoveu extends EcommerceVitrineEvent {
  final VitrineLocal local;
  final VitrineItemTipo tipo;
  final int itemId;
  final int indice;

  const EcommerceVitrineItemMoveu({
    required this.local,
    required this.tipo,
    required this.itemId,
    required this.indice,
  });

  @override
  List<Object?> get props => [local, tipo, itemId, indice];
}

class EcommerceVitrineSalvou extends EcommerceVitrineEvent {
  final VitrineLocal local;

  const EcommerceVitrineSalvou({required this.local});

  @override
  List<Object?> get props => [local];
}
