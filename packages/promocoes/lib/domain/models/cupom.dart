import 'package:core/equals.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

abstract class Cupom implements Equatable {
  int? get id;
  int? get empresaId;
  String get codigo;
  DateTime get dataInicio;
  DateTime get dataFim;
  TipoDesconto get tipoDesconto;
  double? get valorPercentual;
  double? get valorDescontoMaximo;
  double? get valorFixo;
  double? get valorMinimoCompra;
  int? get quantidadeMinima;
  double? get precoFixo;
  TipoEscopo get tipoEscopo;
  List<int>? get referenciaIds;
  List<ItemComboKit>? get comboKit;
  int? get quantidadeLeva;
  int? get quantidadePaga;
  int? get limiteUsos;
  int get usosRealizados;
  bool get ativa;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;

  factory Cupom.create({
    int? id,
    int? empresaId,
    required String codigo,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoDesconto tipoDesconto,
    double? valorPercentual,
    double? valorDescontoMaximo,
    double? valorFixo,
    double? valorMinimoCompra,
    int? quantidadeMinima,
    double? precoFixo,
    required TipoEscopo tipoEscopo,
    List<int>? referenciaIds,
    List<ItemComboKit>? comboKit,
    int? quantidadeLeva,
    int? quantidadePaga,
    int? limiteUsos,
    int usosRealizados,
    bool ativa,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) = _CupomImpl;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        codigo,
        dataInicio,
        dataFim,
        tipoDesconto,
        valorPercentual,
        valorDescontoMaximo,
        valorFixo,
        valorMinimoCompra,
        quantidadeMinima,
        precoFixo,
        tipoEscopo,
        referenciaIds,
        comboKit,
        quantidadeLeva,
        quantidadePaga,
        limiteUsos,
        usosRealizados,
        ativa,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}

class _CupomImpl implements Cupom {
  @override
  final int? id;
  @override
  final int? empresaId;
  @override
  final String codigo;
  @override
  final DateTime dataInicio;
  @override
  final DateTime dataFim;
  @override
  final TipoDesconto tipoDesconto;
  @override
  final double? valorPercentual;
  @override
  final double? valorDescontoMaximo;
  @override
  final double? valorFixo;
  @override
  final double? valorMinimoCompra;
  @override
  final int? quantidadeMinima;
  @override
  final double? precoFixo;
  @override
  final TipoEscopo tipoEscopo;
  @override
  final List<int>? referenciaIds;
  @override
  final List<ItemComboKit>? comboKit;
  @override
  final int? quantidadeLeva;
  @override
  final int? quantidadePaga;
  @override
  final int? limiteUsos;
  @override
  final int usosRealizados;
  @override
  final bool ativa;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const _CupomImpl({
    this.id,
    this.empresaId,
    required this.codigo,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoDesconto,
    this.valorPercentual,
    this.valorDescontoMaximo,
    this.valorFixo,
    this.valorMinimoCompra,
    this.quantidadeMinima,
    this.precoFixo,
    required this.tipoEscopo,
    this.referenciaIds,
    this.comboKit,
    this.quantidadeLeva,
    this.quantidadePaga,
    this.limiteUsos,
    this.usosRealizados = 0,
    this.ativa = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  @override
  List<Object?> get props => [
        id,
        empresaId,
        codigo,
        dataInicio,
        dataFim,
        tipoDesconto,
        valorPercentual,
        valorDescontoMaximo,
        valorFixo,
        valorMinimoCompra,
        quantidadeMinima,
        precoFixo,
        tipoEscopo,
        referenciaIds,
        comboKit,
        quantidadeLeva,
        quantidadePaga,
        limiteUsos,
        usosRealizados,
        ativa,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}
