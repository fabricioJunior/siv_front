part of 'lista_grupo_bloc.dart';

abstract class ListaGrupoEvent extends Equatable {
  const ListaGrupoEvent();

  @override
  List<Object?> get props => [];
}

/// [id] nulo = novo grupo.
class ListaGrupoAbriu extends ListaGrupoEvent {
  final int? id;

  const ListaGrupoAbriu({this.id});

  @override
  List<Object?> get props => [id];
}

class ListaGrupoIconeEscolheu extends ListaGrupoEvent {
  const ListaGrupoIconeEscolheu();
}

/// [listaIds] na ordem desejada (a posição vira o índice).
class ListaGrupoSalvou extends ListaGrupoEvent {
  final String nome;
  final String? descricao;
  final List<int> listaIds;
  final bool? ativo;

  const ListaGrupoSalvou({
    required this.nome,
    this.descricao,
    required this.listaIds,
    this.ativo,
  });

  @override
  List<Object?> get props => [nome, descricao, listaIds, ativo];
}
