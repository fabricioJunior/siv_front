part of 'lista_grupo_bloc.dart';

enum ListaGrupoStep { inicial, carregando, pronto, salvando, salvo, falha }

class ListaGrupoState extends Equatable {
  final ListaGrupoStep step;
  final ListaGrupo? grupo;
  final List<ListaPersonalizadaResumo> opcoes;
  final ArquivoSelecionado? iconeLocal;
  final String? erro;

  const ListaGrupoState({
    this.step = ListaGrupoStep.inicial,
    this.grupo,
    this.opcoes = const [],
    this.iconeLocal,
    this.erro,
  });

  ListaGrupoState copyWith({
    ListaGrupoStep? step,
    ListaGrupo? grupo,
    List<ListaPersonalizadaResumo>? opcoes,
    ArquivoSelecionado? iconeLocal,
    String? erro,
  }) =>
      ListaGrupoState(
        step: step ?? this.step,
        grupo: grupo ?? this.grupo,
        opcoes: opcoes ?? this.opcoes,
        iconeLocal: iconeLocal ?? this.iconeLocal,
        erro: erro,
      );

  @override
  List<Object?> get props => [step, grupo, opcoes, iconeLocal, erro];
}
