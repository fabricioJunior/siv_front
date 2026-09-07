part of 'lista_personalizada_bloc.dart';

enum ListaPersonalizadaStep { formulario, salvando, criada }

class ListaPersonalizadaState extends Equatable {
  final ListaPersonalizadaStep step;
  final ListaPersonalizada? lista;
  final bool atualizandoItens;
  final String? link;
  final String? erro;

  const ListaPersonalizadaState({
    this.step = ListaPersonalizadaStep.formulario,
    this.lista,
    this.atualizandoItens = false,
    this.link,
    this.erro,
  });

  ListaPersonalizadaState copyWith({
    ListaPersonalizadaStep? step,
    ListaPersonalizada? lista,
    bool? atualizandoItens,
    String? link,
    String? erro,
  }) {
    return ListaPersonalizadaState(
      step: step ?? this.step,
      lista: lista ?? this.lista,
      atualizandoItens: atualizandoItens ?? this.atualizandoItens,
      link: link ?? this.link,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, lista, atualizandoItens, link, erro];
}
