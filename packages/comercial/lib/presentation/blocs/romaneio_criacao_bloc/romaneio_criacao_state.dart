part of 'romaneio_criacao_bloc.dart';

enum RomaneioCriacaoStep { inicial, processando, sucesso, falha }

class RomaneioCriacaoState extends Equatable {
  final RomaneioCriacaoStep step;
  final String? hashLista;
  final ListaDeProdutosCompartilhada? listaCompartilhada;
  final List<ProdutoCompartilhado> produtosCompartilhados;
  final Romaneio? romaneio;
  final String? erro;
  final int totalItensProcessados;

  const RomaneioCriacaoState({
    required this.step,
    this.hashLista,
    this.listaCompartilhada,
    this.produtosCompartilhados = const [],
    this.romaneio,
    this.erro,
    this.totalItensProcessados = 0,
  });

  const RomaneioCriacaoState.initial()
      : step = RomaneioCriacaoStep.inicial,
        hashLista = null,
        listaCompartilhada = null,
        produtosCompartilhados = const [],
        romaneio = null,
        erro = null,
        totalItensProcessados = 0;

  RomaneioCriacaoState copyWith({
    RomaneioCriacaoStep? step,
    String? hashLista,
    ListaDeProdutosCompartilhada? listaCompartilhada,
    List<ProdutoCompartilhado>? produtosCompartilhados,
    Romaneio? romaneio,
    String? erro,
    int? totalItensProcessados,
  }) {
    return RomaneioCriacaoState(
      step: step ?? this.step,
      hashLista: hashLista ?? this.hashLista,
      listaCompartilhada: listaCompartilhada ?? this.listaCompartilhada,
      produtosCompartilhados:
          produtosCompartilhados ?? this.produtosCompartilhados,
      romaneio: romaneio ?? this.romaneio,
      erro: erro ?? this.erro,
      totalItensProcessados:
          totalItensProcessados ?? this.totalItensProcessados,
    );
  }

  @override
  List<Object?> get props => [
        step,
        hashLista,
        listaCompartilhada,
        produtosCompartilhados,
        romaneio,
        erro,
        totalItensProcessados,
      ];
}
