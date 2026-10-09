part of 'pedido_entrada_bloc.dart';

abstract class PedidoEntradaEvent extends Equatable {
  const PedidoEntradaEvent();

  @override
  List<Object?> get props => [];
}

class PedidoEntradaCarregou extends PedidoEntradaEvent {
  final int pedidoId;
  const PedidoEntradaCarregou(this.pedidoId);

  @override
  List<Object?> get props => [pedidoId];
}

class PedidoEntradaImportouNfe extends PedidoEntradaEvent {
  final String filePath;
  final int tabelaPrecoId;
  const PedidoEntradaImportouNfe({
    required this.filePath,
    required this.tabelaPrecoId,
  });

  @override
  List<Object?> get props => [filePath, tabelaPrecoId];
}

class PedidoEntradaCriouPorContagem extends PedidoEntradaEvent {
  final int pessoaId;
  final int tabelaPrecoId;

  /// Funcionário responsável pela entrada: vai no romaneio do faturamento.
  final int funcionarioId;
  const PedidoEntradaCriouPorContagem({
    required this.pessoaId,
    required this.tabelaPrecoId,
    required this.funcionarioId,
  });

  @override
  List<Object?> get props => [pessoaId, tabelaPrecoId];
}

class PedidoEntradaVinculouLinha extends PedidoEntradaEvent {
  final int linhaId;
  final int referenciaId;
  const PedidoEntradaVinculouLinha(this.linhaId, this.referenciaId);

  @override
  List<Object?> get props => [linhaId, referenciaId];
}

class PedidoEntradaPreCadastrouLinha extends PedidoEntradaEvent {
  final int linhaId;
  final int categoriaId;
  final String? nome;
  const PedidoEntradaPreCadastrouLinha(
    this.linhaId, {
    required this.categoriaId,
    this.nome,
  });

  @override
  List<Object?> get props => [linhaId, categoriaId, nome];
}

class PedidoEntradaIgnorouLinha extends PedidoEntradaEvent {
  final int linhaId;
  final bool ignorar;
  const PedidoEntradaIgnorouLinha(this.linhaId, {required this.ignorar});

  @override
  List<Object?> get props => [linhaId, ignorar];
}

class PedidoEntradaResolveuDivergencia extends PedidoEntradaEvent {
  final int linhaId;
  final String? observacao;
  const PedidoEntradaResolveuDivergencia(this.linhaId, {this.observacao});

  @override
  List<Object?> get props => [linhaId, observacao];
}

class PedidoEntradaRegistrouContagem extends PedidoEntradaEvent {
  final List<ItemContagem> itens;

  /// Auditoria: de onde veio a edição (contagem|edicao) e o motivo opcional.
  final String? origem;
  final String? motivo;
  const PedidoEntradaRegistrouContagem(
    this.itens, {
    this.origem,
    this.motivo,
  });

  @override
  List<Object?> get props => [itens.length, origem, motivo];
}

/// Troca o passo visível da trilha (toque na trilha, "Terminei", "Voltar").
class PedidoEntradaSelecionouPasso extends PedidoEntradaEvent {
  final int passo;
  const PedidoEntradaSelecionouPasso(this.passo);

  @override
  List<Object?> get props => [passo];
}

/// Corrige o contado de um produto (nunca abaixo do lido).
class PedidoEntradaCorrigiuContagem extends PedidoEntradaEvent {
  final int produtoId;
  final double para;
  final String? motivo;
  final String origem;
  const PedidoEntradaCorrigiuContagem(
    this.produtoId,
    this.para, {
    this.motivo,
    required this.origem,
  });

  @override
  List<Object?> get props => [produtoId, para, motivo, origem];
}

class PedidoEntradaDecidiuDivergencia extends PedidoEntradaEvent {
  final int produtoId;
  final AcaoDivergencia acao;
  final String? observacao;
  const PedidoEntradaDecidiuDivergencia(
    this.produtoId,
    this.acao, {
    this.observacao,
  });

  @override
  List<Object?> get props => [produtoId, acao, observacao];
}

/// "Já etiquetado · pular".
class PedidoEntradaPulouEtiquetas extends PedidoEntradaEvent {
  const PedidoEntradaPulouEtiquetas();
}

/// Etiquetas impressas (produtoId -> quantidade); registra e segue pra Conferir.
class PedidoEntradaImprimiuEtiquetas extends PedidoEntradaEvent {
  final Map<int, double> itens;
  const PedidoEntradaImprimiuEtiquetas(this.itens);

  @override
  List<Object?> get props => [itens];
}

class PedidoEntradaFaturou extends PedidoEntradaEvent {
  const PedidoEntradaFaturou();
}

class PedidoEntradaRegistrouContagemLivre extends PedidoEntradaEvent {
  final List<ItemContagem> itens;
  const PedidoEntradaRegistrouContagemLivre(this.itens);

  @override
  List<Object?> get props => [itens.length];
}

/// Associa contagens sem referência a uma referência existente
/// ([referenciaId]) ou a uma nova ([categoriaId] + [nome]).
class PedidoEntradaAssociouContagemLivre extends PedidoEntradaEvent {
  final List<int> ids;
  final int? referenciaId;
  final int? categoriaId;
  final String? nome;
  const PedidoEntradaAssociouContagemLivre(
    this.ids, {
    this.referenciaId,
    this.categoriaId,
    this.nome,
  });

  @override
  List<Object?> get props => [ids, referenciaId, categoriaId, nome];
}

/// Bipe LOCAL (sem rede): soma [delta] (+1 bipe, -1 remover) às leituras
/// pendentes de envio do produto.
class PedidoEntradaLeu extends PedidoEntradaEvent {
  final int produtoId;
  final int delta;
  const PedidoEntradaLeu(this.produtoId, this.delta);

  @override
  List<Object?> get props => [produtoId, delta];
}

/// Envia as leituras pendentes numa só chamada; se [irParaRevisar] e der
/// certo, segue para o passo Revisar.
class PedidoEntradaEnviouLeituras extends PedidoEntradaEvent {
  final bool irParaRevisar;
  const PedidoEntradaEnviouLeituras({this.irParaRevisar = false});

  @override
  List<Object?> get props => [irParaRevisar];
}

class PedidoEntradaDescartouLeituras extends PedidoEntradaEvent {
  const PedidoEntradaDescartouLeituras();
}
