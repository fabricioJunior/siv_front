part of 'promocao_bloc.dart';

abstract class PromocaoEvent {}

class PromocaoIniciou extends PromocaoEvent {
  final int? idPromocao;

  PromocaoIniciou({this.idPromocao});
}

class PromocaoCampoAlterado extends PromocaoEvent {
  final String? nome;
  final String? descricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TipoDesconto? tipoDesconto;
  final double? valorPercentual;
  final double? valorDescontoMaximo;
  final double? valorFixo;
  final double? valorMinimoCompra;
  final int? quantidadeMinima;
  final double? precoFixo;
  final TipoEscopo? tipoEscopo;
  final List<int>? referenciaIds;
  final List<ItemComboKit>? comboKit;
  final int? quantidadeLeva;
  final int? quantidadePaga;
  final int? limiteUnidadesVendidas;
  final int? limiteUsosPorCliente;
  final PeriodoLimiteCliente? periodoLimiteCliente;
  final bool? somenteAniversariante;
  final PromocaoCanal? canal;
  final bool? ativa;
  final bool? restringirFormasPagamento;
  final List<PromocaoFormaPagamento>? formasPagamento;
  // true quando o tipoEscopo mudou -- limpa os campos do escopo anterior
  // (referenciaIds/comboKit/quantidadeLeva/quantidadePaga) em vez de manter
  // valores que nao fazem mais sentido pro novo tipoEscopo.
  final bool limparEscopo;

  PromocaoCampoAlterado({
    this.nome,
    this.descricao,
    this.dataInicio,
    this.dataFim,
    this.tipoDesconto,
    this.valorPercentual,
    this.valorDescontoMaximo,
    this.valorFixo,
    this.valorMinimoCompra,
    this.quantidadeMinima,
    this.precoFixo,
    this.tipoEscopo,
    this.referenciaIds,
    this.comboKit,
    this.quantidadeLeva,
    this.quantidadePaga,
    this.limiteUnidadesVendidas,
    this.limiteUsosPorCliente,
    this.periodoLimiteCliente,
    this.somenteAniversariante,
    this.canal,
    this.ativa,
    this.restringirFormasPagamento,
    this.formasPagamento,
    this.limparEscopo = false,
  });
}

class PromocaoSalvou extends PromocaoEvent {}
