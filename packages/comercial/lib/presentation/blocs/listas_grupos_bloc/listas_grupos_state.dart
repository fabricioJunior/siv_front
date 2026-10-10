part of 'listas_grupos_bloc.dart';

enum ListasGruposStep { inicial, carregando, carregado, falha }

class ListasGruposState extends Equatable {
  final ListasGruposStep step;
  final List<ListaGrupo> itens;
  final String? erro;

  const ListasGruposState({
    this.step = ListasGruposStep.inicial,
    this.itens = const [],
    this.erro,
  });

  ListasGruposState copyWith({
    ListasGruposStep? step,
    List<ListaGrupo>? itens,
    String? erro,
  }) =>
      ListasGruposState(
        step: step ?? this.step,
        itens: itens ?? this.itens,
        erro: erro,
      );

  @override
  List<Object?> get props => [step, itens, erro];
}
