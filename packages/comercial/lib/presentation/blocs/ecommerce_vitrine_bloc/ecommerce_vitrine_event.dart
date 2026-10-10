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

class VitrineItemRef extends Equatable {
  final VitrineItemTipo tipo;
  final int itemId;

  const VitrineItemRef(this.tipo, this.itemId);

  @override
  List<Object?> get props => [tipo, itemId];
}

/// Multi-seleção do diálogo Adicionar: entra no fim do [local], na ordem dada.
class EcommerceVitrineItensAdicionou extends EcommerceVitrineEvent {
  final VitrineLocal local;
  final List<VitrineItemRef> itens;

  const EcommerceVitrineItensAdicionou(
      {required this.local, required this.itens});

  @override
  List<Object?> get props => [local, itens];
}

/// Publica (PUT) só os locais que diferem do publicado.
class EcommerceVitrinePublicou extends EcommerceVitrineEvent {
  const EcommerceVitrinePublicou();
}

/// Restaura o rascunho para a versão publicada.
class EcommerceVitrineDescartou extends EcommerceVitrineEvent {
  const EcommerceVitrineDescartou();
}

/// Relê listas e grupos sem mexer na vitrine em edição -- lista criada em outra
/// aba (ou por outra pessoa) só aparecia no diálogo depois de reabrir a página.
class EcommerceVitrineRecarregouCatalogo extends EcommerceVitrineEvent {
  const EcommerceVitrineRecarregouCatalogo();
}
