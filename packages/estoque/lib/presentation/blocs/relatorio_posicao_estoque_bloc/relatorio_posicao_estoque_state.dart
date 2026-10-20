part of 'relatorio_posicao_estoque_bloc.dart';

enum PosicaoEstoqueStep { inicial, carregando, sucesso, falha }

class RelatorioPosicaoEstoqueState {
  final PosicaoEstoqueStep step;
  final RelatorioPosicaoEstoque? dados;
  final String? erro;
  final List<int> categoriaIds;
  final List<int> corIds;
  final List<int> tamanhoIds;
  final String? situacao;
  final String ordenarPor;
  final String ordem;

  const RelatorioPosicaoEstoqueState({
    this.step = PosicaoEstoqueStep.inicial,
    this.dados,
    this.erro,
    this.categoriaIds = const [],
    this.corIds = const [],
    this.tamanhoIds = const [],
    this.situacao,
    this.ordenarPor = 'valor',
    this.ordem = 'desc',
  });

  bool get ruptura => situacao == 'ruptura';

  RelatorioPosicaoEstoqueState copyWith({
    PosicaoEstoqueStep? step,
    RelatorioPosicaoEstoque? dados,
    String? erro,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    String? ordenarPor,
    String? ordem,
    bool alteraSituacao = false,
    String? situacao,
  }) =>
      RelatorioPosicaoEstoqueState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        categoriaIds: categoriaIds ?? this.categoriaIds,
        corIds: corIds ?? this.corIds,
        tamanhoIds: tamanhoIds ?? this.tamanhoIds,
        situacao: alteraSituacao ? situacao : this.situacao,
        ordenarPor: ordenarPor ?? this.ordenarPor,
        ordem: ordem ?? this.ordem,
      );
}
