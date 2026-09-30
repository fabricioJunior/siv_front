part of 'produtos_da_referencia_bloc.dart';

enum ProdutosDaReferenciaStep { inicial, carregando, sucesso, criandoProdutos, falha }

class ProdutosDaReferenciaState extends Equatable {
  final ProdutosDaReferenciaStep step;
  final int? referenciaId;
  final GradeDaReferencia? grade;
  final List<ItemPresente> cores;
  final List<ItemPresente> tamanhos;
  final List<EstampaPresente> estampas;
  final Map<String, ProdutoDaGrade> mapaProduto;
  final String busca;
  final FiltroProdutosDaReferencia filtro;

  const ProdutosDaReferenciaState({
    this.step = ProdutosDaReferenciaStep.inicial,
    this.referenciaId,
    this.grade,
    this.cores = const [],
    this.tamanhos = const [],
    this.estampas = const [],
    this.mapaProduto = const {},
    this.busca = '',
    this.filtro = FiltroProdutosDaReferencia.todos,
  });

  ProdutosDaReferenciaState copyWith({
    ProdutosDaReferenciaStep? step,
    int? referenciaId,
    GradeDaReferencia? grade,
    List<ItemPresente>? cores,
    List<ItemPresente>? tamanhos,
    List<EstampaPresente>? estampas,
    Map<String, ProdutoDaGrade>? mapaProduto,
    String? busca,
    FiltroProdutosDaReferencia? filtro,
  }) {
    return ProdutosDaReferenciaState(
      step: step ?? this.step,
      referenciaId: referenciaId ?? this.referenciaId,
      grade: grade ?? this.grade,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      estampas: estampas ?? this.estampas,
      mapaProduto: mapaProduto ?? this.mapaProduto,
      busca: busca ?? this.busca,
      filtro: filtro ?? this.filtro,
    );
  }

  /// Total de combinações da grade (cor x tamanho x (Liso + estampas)).
  int get totalCombinacoesDaGrade =>
      cores.length * tamanhos.length * (estampas.isEmpty ? 1 : estampas.length);

  int get totalCombinacoesComProduto => mapaProduto.length;

  bool _correspondeBusca(String texto) {
    if (busca.trim().isEmpty) return true;
    return _semAcento(texto).contains(_semAcento(busca));
  }

  static String _semAcento(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const semAcento = 'aaaaaeeeeiiiiooooouuuuc';
    var resultado = texto.toLowerCase();
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  /// Linhas (cor x estampa) visíveis já filtradas por busca e pelo filtro
  /// Todos/Faltando, na forma (cor, estampa, tamanhosFaltantes).
  List<({ItemPresente cor, EstampaPresente estampa, List<ItemPresente> faltantes})>
  get linhas {
    final resultado =
        <({ItemPresente cor, EstampaPresente estampa, List<ItemPresente> faltantes})>[];

    for (final cor in cores) {
      for (final estampa in estampas.isEmpty
          ? const [(id: null, nome: 'Liso')]
          : estampas) {
        final correspondeCor = _correspondeBusca(cor.nome);
        final correspondeEstampa = _correspondeBusca(estampa.nome);
        final correspondeTamanho = tamanhos.any((t) => _correspondeBusca(t.nome));
        if (!(correspondeCor || correspondeEstampa || correspondeTamanho)) {
          continue;
        }

        final faltantes = tamanhos
            .where(
              (tamanho) => !mapaProduto.containsKey(
                chaveComboGrade(cor.id, tamanho.id, estampa.id),
              ),
            )
            .toList();

        if (filtro == FiltroProdutosDaReferencia.faltando &&
            faltantes.isEmpty) {
          continue;
        }

        resultado.add((cor: cor, estampa: estampa, faltantes: faltantes));
      }
    }

    return resultado;
  }

  List<ComboDeGrade> get todosOsFaltantes {
    final resultado = <ComboDeGrade>[];
    for (final cor in cores) {
      for (final estampa in estampas.isEmpty
          ? const [(id: null, nome: 'Liso')]
          : estampas) {
        for (final tamanho in tamanhos) {
          if (!mapaProduto.containsKey(
            chaveComboGrade(cor.id, tamanho.id, estampa.id),
          )) {
            resultado.add(
              ComboDeGrade(
                corId: cor.id,
                tamanhoId: tamanho.id,
                estampaId: estampa.id,
              ),
            );
          }
        }
      }
    }
    return resultado;
  }

  @override
  List<Object?> get props => [
    step,
    referenciaId,
    grade,
    cores,
    tamanhos,
    estampas,
    mapaProduto,
    busca,
    filtro,
  ];
}
