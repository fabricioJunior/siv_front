part of 'cupom_bloc.dart';

abstract class CupomEvent {}

class CupomIniciou extends CupomEvent {
  final int? idCupom;

  CupomIniciou({this.idCupom});
}

class CupomCampoAlterado extends CupomEvent {
  final String? codigo;
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
  final int? limiteUsos;
  final bool? ativa;
  // true quando o tipoEscopo mudou -- limpa os campos do escopo anterior.
  final bool limparEscopo;

  CupomCampoAlterado({
    this.codigo,
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
    this.limiteUsos,
    this.ativa,
    this.limparEscopo = false,
  });
}

class CupomSalvou extends CupomEvent {}
