part of 'lista_personalizada_bloc.dart';

enum ListaPersonalizadaStep { formulario, salvando, criada }

class ListaPersonalizadaState extends Equatable {
  final ListaPersonalizadaStep step;
  final ListaPersonalizada? lista;
  final bool atualizandoItens;
  final bool atualizandoTitulo;
  final bool salvandoDados;
  final bool carregandoPrevia;
  final String? link;
  final String? erro;
  final ArquivoSelecionado? iconeLocal;
  final ListaPrevia? previa;
  final ListaItensLoteResultado? ultimoLote;

  const ListaPersonalizadaState({
    this.step = ListaPersonalizadaStep.formulario,
    this.lista,
    this.atualizandoItens = false,
    this.atualizandoTitulo = false,
    this.salvandoDados = false,
    this.carregandoPrevia = false,
    this.link,
    this.erro,
    this.iconeLocal,
    this.previa,
    this.ultimoLote,
  });

  ListaPersonalizadaState copyWith({
    ListaPersonalizadaStep? step,
    ListaPersonalizada? lista,
    bool? atualizandoItens,
    bool? atualizandoTitulo,
    bool? salvandoDados,
    bool? carregandoPrevia,
    String? link,
    String? erro,
    ArquivoSelecionado? iconeLocal,
    ListaPrevia? previa,
    ListaItensLoteResultado? ultimoLote,
  }) {
    return ListaPersonalizadaState(
      step: step ?? this.step,
      lista: lista ?? this.lista,
      atualizandoItens: atualizandoItens ?? this.atualizandoItens,
      atualizandoTitulo: atualizandoTitulo ?? this.atualizandoTitulo,
      salvandoDados: salvandoDados ?? this.salvandoDados,
      carregandoPrevia: carregandoPrevia ?? this.carregandoPrevia,
      link: link ?? this.link,
      erro: erro,
      iconeLocal: iconeLocal ?? this.iconeLocal,
      previa: previa ?? this.previa,
      ultimoLote: ultimoLote ?? this.ultimoLote,
    );
  }

  @override
  List<Object?> get props => [
        step,
        lista,
        atualizandoItens,
        atualizandoTitulo,
        salvandoDados,
        carregandoPrevia,
        link,
        erro,
        iconeLocal,
        previa,
        ultimoLote,
      ];
}
