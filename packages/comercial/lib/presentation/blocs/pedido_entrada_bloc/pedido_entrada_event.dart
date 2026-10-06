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
  const PedidoEntradaCriouPorContagem({
    required this.pessoaId,
    required this.tabelaPrecoId,
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
  const PedidoEntradaRegistrouContagem(this.itens);

  @override
  List<Object?> get props => [itens.length];
}
