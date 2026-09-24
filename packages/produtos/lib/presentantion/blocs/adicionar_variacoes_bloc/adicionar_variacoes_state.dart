part of 'adicionar_variacoes_bloc.dart';

enum AdicionarVariacoesStep { inicial, carregando, pronto, salvando, sucesso, falha }

class AdicionarVariacoesState extends Equatable {
  final AdicionarVariacoesStep step;
  final int? referenciaId;
  final List<Cor> todasCores;
  final List<Tamanho> todosTamanhos;
  final List<Estampa> todasEstampas;
  final Set<int> corIdsNaGrade;
  final Set<int> tamanhoIdsNaGrade;
  final Set<int> estampaIdsNaGrade;
  final Set<String> chavesNaGrade;
  final Set<int> coresSelecionadas;
  final Set<int> tamanhosSelecionados;
  final Set<int> estampasSelecionadas;
  final bool estampasAtivo;
  final String buscaCor;
  final String buscaTamanho;
  final String buscaEstampa;
  final List<Produto> criados;

  const AdicionarVariacoesState({
    this.step = AdicionarVariacoesStep.inicial,
    this.referenciaId,
    this.todasCores = const [],
    this.todosTamanhos = const [],
    this.todasEstampas = const [],
    this.corIdsNaGrade = const {},
    this.tamanhoIdsNaGrade = const {},
    this.estampaIdsNaGrade = const {},
    this.chavesNaGrade = const {},
    this.coresSelecionadas = const {},
    this.tamanhosSelecionados = const {},
    this.estampasSelecionadas = const {},
    this.estampasAtivo = false,
    this.buscaCor = '',
    this.buscaTamanho = '',
    this.buscaEstampa = '',
    this.criados = const [],
  });

  /// Combinações selecionadas no rascunho (cores x tamanhos x estampas)
  /// que ainda não existem na grade aplicada -- o diff que o rodapé
  /// mostra ("Novos na grade: ... -> N produtos").
  List<ComboDeGrade> get combinacoesNovas {
    if (coresSelecionadas.isEmpty || tamanhosSelecionados.isEmpty) {
      return const [];
    }

    final estampasParaCruzar = (estampasAtivo && estampasSelecionadas.isNotEmpty)
        ? estampasSelecionadas.map<int?>((id) => id).toList()
        : <int?>[null];

    final resultado = <ComboDeGrade>[];
    for (final corId in coresSelecionadas) {
      for (final tamanhoId in tamanhosSelecionados) {
        for (final estampaId in estampasParaCruzar) {
          final chave = chaveComboGrade(corId, tamanhoId, estampaId);
          if (!chavesNaGrade.contains(chave)) {
            resultado.add(
              ComboDeGrade(
                corId: corId,
                tamanhoId: tamanhoId,
                estampaId: estampaId,
              ),
            );
          }
        }
      }
    }
    return resultado;
  }

  int get totalCombinacoesNovas => combinacoesNovas.length;

  bool podeDesmarcarCor(int corId) => !corIdsNaGrade.contains(corId);
  bool podeDesmarcarTamanho(int tamanhoId) =>
      !tamanhoIdsNaGrade.contains(tamanhoId);
  bool podeDesmarcarEstampa(int estampaId) =>
      !estampaIdsNaGrade.contains(estampaId);

  AdicionarVariacoesState copyWith({
    AdicionarVariacoesStep? step,
    int? referenciaId,
    List<Cor>? todasCores,
    List<Tamanho>? todosTamanhos,
    List<Estampa>? todasEstampas,
    Set<int>? corIdsNaGrade,
    Set<int>? tamanhoIdsNaGrade,
    Set<int>? estampaIdsNaGrade,
    Set<String>? chavesNaGrade,
    Set<int>? coresSelecionadas,
    Set<int>? tamanhosSelecionados,
    Set<int>? estampasSelecionadas,
    bool? estampasAtivo,
    String? buscaCor,
    String? buscaTamanho,
    String? buscaEstampa,
    List<Produto>? criados,
  }) {
    return AdicionarVariacoesState(
      step: step ?? this.step,
      referenciaId: referenciaId ?? this.referenciaId,
      todasCores: todasCores ?? this.todasCores,
      todosTamanhos: todosTamanhos ?? this.todosTamanhos,
      todasEstampas: todasEstampas ?? this.todasEstampas,
      corIdsNaGrade: corIdsNaGrade ?? this.corIdsNaGrade,
      tamanhoIdsNaGrade: tamanhoIdsNaGrade ?? this.tamanhoIdsNaGrade,
      estampaIdsNaGrade: estampaIdsNaGrade ?? this.estampaIdsNaGrade,
      chavesNaGrade: chavesNaGrade ?? this.chavesNaGrade,
      coresSelecionadas: coresSelecionadas ?? this.coresSelecionadas,
      tamanhosSelecionados: tamanhosSelecionados ?? this.tamanhosSelecionados,
      estampasSelecionadas: estampasSelecionadas ?? this.estampasSelecionadas,
      estampasAtivo: estampasAtivo ?? this.estampasAtivo,
      buscaCor: buscaCor ?? this.buscaCor,
      buscaTamanho: buscaTamanho ?? this.buscaTamanho,
      buscaEstampa: buscaEstampa ?? this.buscaEstampa,
      criados: criados ?? this.criados,
    );
  }

  @override
  List<Object?> get props => [
    step,
    referenciaId,
    todasCores,
    todosTamanhos,
    todasEstampas,
    corIdsNaGrade,
    tamanhoIdsNaGrade,
    estampaIdsNaGrade,
    chavesNaGrade,
    coresSelecionadas,
    tamanhosSelecionados,
    estampasSelecionadas,
    estampasAtivo,
    buscaCor,
    buscaTamanho,
    buscaEstampa,
    criados,
  ];
}

