part of 'lista_personalizada_bloc.dart';

abstract class ListaPersonalizadaEvent extends Equatable {
  const ListaPersonalizadaEvent();

  @override
  List<Object?> get props => [];
}

class ListaPersonalizadaCriou extends ListaPersonalizadaEvent {
  final int tabelaPrecoId;
  final DateTime dataExpiracao;

  const ListaPersonalizadaCriou({
    required this.tabelaPrecoId,
    required this.dataExpiracao,
  });

  @override
  List<Object?> get props => [tabelaPrecoId, dataExpiracao];
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
