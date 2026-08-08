import 'package:promocoes/domain/models/cupom.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

class CupomDto implements Cupom {
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

  const CupomDto({
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

  factory CupomDto.fromJson(Map<String, dynamic> json) {
    return CupomDto(
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      codigo: (json['codigo'] as String?) ?? '',
      dataInicio: _parseData(json['dataInicio']),
      dataFim: _parseData(json['dataFim']),
      tipoDesconto: TipoDesconto.fromString(json['tipoDesconto'] as String?),
      valorPercentual: _parseDouble(json['valorPercentual']),
      valorDescontoMaximo: _parseDouble(json['valorDescontoMaximo']),
      valorFixo: _parseDouble(json['valorFixo']),
      valorMinimoCompra: _parseDouble(json['valorMinimoCompra']),
      quantidadeMinima: (json['quantidadeMinima'] as num?)?.toInt(),
      precoFixo: _parseDouble(json['precoFixo']),
      tipoEscopo: TipoEscopo.fromString(json['tipoEscopo'] as String?),
      referenciaIds: (json['referenciaIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      comboKit: (json['comboKit'] as List<dynamic>?)
          ?.map((e) => ItemComboKit.fromJson(e as Map<String, dynamic>))
          .toList(),
      quantidadeLeva: (json['quantidadeLeva'] as num?)?.toInt(),
      quantidadePaga: (json['quantidadePaga'] as num?)?.toInt(),
      limiteUsos: (json['limiteUsos'] as num?)?.toInt(),
      usosRealizados: (json['usosRealizados'] as num?)?.toInt() ?? 0,
      ativa: json['ativa'] as bool? ?? true,
      criadoEm: _parseDateTime(json['criadoEm']),
      atualizadoEm: _parseDateTime(json['atualizadoEm']),
    );
  }

  factory CupomDto.fromModel(Cupom cupom) {
    return CupomDto(
      id: cupom.id,
      empresaId: cupom.empresaId,
      codigo: cupom.codigo,
      dataInicio: cupom.dataInicio,
      dataFim: cupom.dataFim,
      tipoDesconto: cupom.tipoDesconto,
      valorPercentual: cupom.valorPercentual,
      valorDescontoMaximo: cupom.valorDescontoMaximo,
      valorFixo: cupom.valorFixo,
      valorMinimoCompra: cupom.valorMinimoCompra,
      quantidadeMinima: cupom.quantidadeMinima,
      precoFixo: cupom.precoFixo,
      tipoEscopo: cupom.tipoEscopo,
      referenciaIds: cupom.referenciaIds,
      comboKit: cupom.comboKit,
      quantidadeLeva: cupom.quantidadeLeva,
      quantidadePaga: cupom.quantidadePaga,
      limiteUsos: cupom.limiteUsos,
      usosRealizados: cupom.usosRealizados,
      ativa: cupom.ativa,
      criadoEm: cupom.criadoEm,
      atualizadoEm: cupom.atualizadoEm,
    );
  }

  // create/update aceitam o mesmo shape -- UpdateCupomDto no backend e um
  // PartialType do CreateCupomDto.
  Map<String, dynamic> toCreateJson() {
    return {
      'codigo': codigo,
      'dataInicio': _formatData(dataInicio),
      'dataFim': _formatData(dataFim),
      'tipoDesconto': tipoDesconto.value,
      if (valorPercentual != null) 'valorPercentual': valorPercentual,
      if (valorDescontoMaximo != null)
        'valorDescontoMaximo': valorDescontoMaximo,
      if (valorFixo != null) 'valorFixo': valorFixo,
      if (valorMinimoCompra != null) 'valorMinimoCompra': valorMinimoCompra,
      if (quantidadeMinima != null) 'quantidadeMinima': quantidadeMinima,
      if (precoFixo != null) 'precoFixo': precoFixo,
      'tipoEscopo': tipoEscopo.value,
      if (referenciaIds != null) 'referenciaIds': referenciaIds,
      if (comboKit != null)
        'comboKit': comboKit!.map((item) => item.toJson()).toList(),
      if (quantidadeLeva != null) 'quantidadeLeva': quantidadeLeva,
      if (quantidadePaga != null) 'quantidadePaga': quantidadePaga,
      if (limiteUsos != null) 'limiteUsos': limiteUsos,
      'ativa': ativa,
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();

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

DateTime _parseData(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _formatData(DateTime data) {
  final ano = data.year.toString().padLeft(4, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final dia = data.day.toString().padLeft(2, '0');
  return '$ano-$mes-$dia';
}
