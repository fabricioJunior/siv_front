part of 'pedido_entrada_bloc.dart';

class PedidoEntradaState extends Equatable {
  final bool carregando;
  final bool salvando;
  final EntradaResumo? resumo;

  /// Mensagens de uma exibição só (SnackBar).
  final String? erro;
  final String? mensagem;

  /// Última referência criada por pré-cadastro (a tela oferece abrir).
  final int? referenciaCriadaId;

  /// Passo escolhido pelo usuário (0..4); null = segue a etapa do pedido.
  final int? passo;

  /// Etiquetas concluídas só no app (backend antigo sem registro de etiquetas).
  final bool etiquetasLocal;

  final bool faturado;

  /// Leituras da conferência ainda não enviadas: produtoId -> variação.
  final Map<int, int> leiturasPendentes;

  /// Lote da fila atual (não muda entre tentativas de envio).
  final String? loteId;

  /// Quando a fila foi restaurada da cópia local ao abrir (faixa âmbar);
  /// null = sem faixa.
  final DateTime? restauradaEm;

  /// O último envio da fila falhou.
  final bool erroEnvio;

  const PedidoEntradaState({
    this.loteId,
    this.restauradaEm,
    this.erroEnvio = false,
    this.carregando = false,
    this.salvando = false,
    this.resumo,
    this.erro,
    this.mensagem,
    this.referenciaCriadaId,
    this.passo,
    this.etiquetasLocal = false,
    this.faturado = false,
    this.leiturasPendentes = const {},
  });

  int get etapaAtual => resumo == null
      ? 0
      : TrilhaEntrada.etapaAtual(resumo!, etiquetasLocal: etiquetasLocal);

  int get passoVisivel => passo ?? etapaAtual;

  List<PassoTrilha> get trilha => resumo == null
      ? const []
      : TrilhaEntrada.trilha(
          resumo!,
          passo: faturado ? 4 : passoVisivel,
          etiquetasLocal: etiquetasLocal,
        );

  List<EntradaDivergencia> get divergencias =>
      resumo?.divergencias ?? const [];

  List<EntradaCorrecao> get correcoes => resumo?.correcoes ?? const [];

  DiffEtiquetas get diffEtiquetas => resumo == null
      ? const DiffEtiquetas()
      : TrilhaEntrada.diffEtiquetas(resumo!);

  PedidoEntradaState copyWith({
    bool? carregando,
    bool? salvando,
    EntradaResumo? resumo,
    String? erro,
    String? mensagem,
    int? referenciaCriadaId,
    int? passo,
    bool limparPasso = false,
    bool? etiquetasLocal,
    bool? faturado,
    Map<int, int>? leiturasPendentes,
    String? loteId,
    DateTime? restauradaEm,
    bool limparLote = false,
    bool? erroEnvio,
  }) {
    return PedidoEntradaState(
      carregando: carregando ?? this.carregando,
      salvando: salvando ?? this.salvando,
      resumo: resumo ?? this.resumo,
      erro: erro,
      mensagem: mensagem,
      referenciaCriadaId: referenciaCriadaId,
      passo: limparPasso ? null : (passo ?? this.passo),
      etiquetasLocal: etiquetasLocal ?? this.etiquetasLocal,
      faturado: faturado ?? this.faturado,
      leiturasPendentes: leiturasPendentes ?? this.leiturasPendentes,
      loteId: limparLote ? null : (loteId ?? this.loteId),
      restauradaEm: limparLote ? null : (restauradaEm ?? this.restauradaEm),
      erroEnvio: erroEnvio ?? this.erroEnvio,
    );
  }

  @override
  List<Object?> get props => [
        carregando,
        salvando,
        resumo,
        erro,
        mensagem,
        referenciaCriadaId,
        passo,
        etiquetasLocal,
        faturado,
        leiturasPendentes,
        loteId,
        restauradaEm,
        erroEnvio,
      ];
}
