part of 'produto_bloc.dart';

abstract class ProdutoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProdutoIniciou extends ProdutoEvent {
  final Produto? produto;
  final int? referenciaId;
  final int? corId;
  final int? tamanhoId;
  final int? estampaId;

  ProdutoIniciou({
    this.produto,
    this.referenciaId,
    this.corId,
    this.tamanhoId,
    this.estampaId,
  });

  @override
  List<Object?> get props => [
    produto,
    referenciaId,
    corId,
    tamanhoId,
    estampaId,
  ];
}

class ProdutoEditou extends ProdutoEvent {
  final int? referenciaId;
  final String? idExterno;
  final int? corId;
  final int? tamanhoId;
  final int? estampaId;

  ProdutoEditou({
    this.referenciaId,
    this.idExterno,
    this.corId,
    this.tamanhoId,
    this.estampaId,
  });

  @override
  List<Object?> get props => [
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    estampaId,
  ];
}

class ProdutoSalvou extends ProdutoEvent {}

class ProdutoEtapaAtualizou extends ProdutoEvent {
  final int etapaAtual;

  ProdutoEtapaAtualizou({required this.etapaAtual});

  @override
  List<Object?> get props => [etapaAtual];
}

class ProdutoCriacaoCodigoBarrasAutomaticaAlternou extends ProdutoEvent {
  final bool criarCodigoBarrasAutomaticamente;

  ProdutoCriacaoCodigoBarrasAutomaticaAlternou({
    required this.criarCodigoBarrasAutomaticamente,
  });

  @override
  List<Object?> get props => [criarCodigoBarrasAutomaticamente];
}

class ProdutoReferenciaSelecionou extends ProdutoEvent {
  final Referencia? referencia;

  ProdutoReferenciaSelecionou({required this.referencia});

  @override
  List<Object?> get props => [referencia];
}

class ProdutoCoresSelecionou extends ProdutoEvent {
  final List<Cor> cores;

  ProdutoCoresSelecionou({required this.cores});

  @override
  List<Object?> get props => [cores];
}

class ProdutoTamanhosSelecionou extends ProdutoEvent {
  final List<Tamanho> tamanhos;

  ProdutoTamanhosSelecionou({required this.tamanhos});

  @override
  List<Object?> get props => [tamanhos];
}

class ProdutoEstampasSelecionou extends ProdutoEvent {
  final List<Estampa> estampas;

  ProdutoEstampasSelecionou({required this.estampas});

  @override
  List<Object?> get props => [estampas];
}

class ProdutoCombinacaoSelecionou extends ProdutoEvent {
  final String chave;
  final bool selecionada;

  ProdutoCombinacaoSelecionou({required this.chave, required this.selecionada});

  @override
  List<Object?> get props => [chave, selecionada];
}

class ProdutoCombinacaoCodigoBarrasEditou extends ProdutoEvent {
  final String chave;
  final String codigoDeBarras;

  ProdutoCombinacaoCodigoBarrasEditou({
    required this.chave,
    required this.codigoDeBarras,
  });

  @override
  List<Object?> get props => [chave, codigoDeBarras];
}

class ProdutoCombinacaoSelecao extends Equatable {
  final int corId;
  final int tamanhoId;
  final int? estampaId;
  final String? codigoDeBarras;

  const ProdutoCombinacaoSelecao({
    required this.corId,
    required this.tamanhoId,
    this.estampaId,
    this.codigoDeBarras,
  });

  @override
  List<Object?> get props => [corId, tamanhoId, estampaId, codigoDeBarras];
}

class ProdutoSalvouCombinacoes extends ProdutoEvent {
  final int referenciaId;
  final List<ProdutoCombinacaoSelecao> combinacoes;
  final bool criarCodigoDeBarrasAutomaticamente;

  ProdutoSalvouCombinacoes({
    required this.referenciaId,
    required this.combinacoes,
    this.criarCodigoDeBarrasAutomaticamente = false,
  });

  @override
  List<Object?> get props => [
    referenciaId,
    combinacoes,
    criarCodigoDeBarrasAutomaticamente,
  ];
}
