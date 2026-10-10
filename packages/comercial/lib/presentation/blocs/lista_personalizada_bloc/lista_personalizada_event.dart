part of 'lista_personalizada_bloc.dart';

abstract class ListaPersonalizadaEvent extends Equatable {
  const ListaPersonalizadaEvent();

  @override
  List<Object?> get props => [];
}

class ListaPersonalizadaCriou extends ListaPersonalizadaEvent {
  final ListaPersonalizadaInput input;

  const ListaPersonalizadaCriou({required this.input});

  @override
  List<Object?> get props => [input];
}

/// Edita os dados da lista já criada (PATCH).
class ListaPersonalizadaAtualizou extends ListaPersonalizadaEvent {
  final ListaPersonalizadaInput input;

  const ListaPersonalizadaAtualizou({required this.input});

  @override
  List<Object?> get props => [input];
}

/// Abre o seletor de imagem. Com lista criada envia na hora; sem lista
/// guarda no estado e envia logo após a criação.
class ListaPersonalizadaIconeEscolheu extends ListaPersonalizadaEvent {
  const ListaPersonalizadaIconeEscolheu();
}

class ListaPersonalizadaItensPorFiltroAdicionou extends ListaPersonalizadaEvent {
  final ListaItensLote lote;

  const ListaPersonalizadaItensPorFiltroAdicionou({required this.lote});

  @override
  List<Object?> get props => [lote];
}

class ListaPersonalizadaPreviaSolicitou extends ListaPersonalizadaEvent {
  final int page;

  const ListaPersonalizadaPreviaSolicitou({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ListaPersonalizadaTituloAtualizou extends ListaPersonalizadaEvent {
  final String? titulo;

  const ListaPersonalizadaTituloAtualizou({required this.titulo});

  @override
  List<Object?> get props => [titulo];
}

class ListaPersonalizadaAbriu extends ListaPersonalizadaEvent {
  final int id;

  const ListaPersonalizadaAbriu({required this.id});

  @override
  List<Object?> get props => [id];
}

class ListaPersonalizadaReferenciasAdicionou extends ListaPersonalizadaEvent {
  final List<int> referenciaIds;

  const ListaPersonalizadaReferenciasAdicionou({required this.referenciaIds});

  @override
  List<Object?> get props => [referenciaIds];
}

class ListaPersonalizadaReferenciasRemoveu extends ListaPersonalizadaEvent {
  final List<int> referenciaIds;

  const ListaPersonalizadaReferenciasRemoveu({required this.referenciaIds});

  @override
  List<Object?> get props => [referenciaIds];
}

/// Adiciona e remove em uma única transação de estado -- usado quando o
/// seletor de referências volta com a seleção final (diff contra o que já
/// estava na lista). Evita a corrida entre dois eventos concorrentes que
/// cada um devolveria sua própria foto da lista vinda do servidor.
class ListaPersonalizadaItensAjustou extends ListaPersonalizadaEvent {
  final List<int> paraAdicionar;
  final List<int> paraRemover;

  const ListaPersonalizadaItensAjustou({
    this.paraAdicionar = const [],
    this.paraRemover = const [],
  });

  @override
  List<Object?> get props => [paraAdicionar, paraRemover];
}
