import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/domain/models/promocao_forma_pagamento.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

class PromocaoDto implements Promocao {
  @override
  final int? id;
  @override
  final int? empresaId;
  @override
  final String nome;
  @override
  final String? descricao;
  @override
  final String? regras;
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
  final int? limiteUnidadesVendidas;
  @override
  final int unidadesVendidas;
  @override
  final int? limiteUsosPorCliente;
  @override
  final PeriodoLimiteCliente? periodoLimiteCliente;
  @override
  final bool somenteAniversariante;
  @override
  final PromocaoCanal canal;
  @override
  final bool ativa;
  @override
  final bool restringirFormasPagamento;
  @override
  final List<PromocaoFormaPagamento> formasPagamento;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const PromocaoDto({
    this.id,
    this.empresaId,
    required this.nome,
    this.descricao,
    this.regras,
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
    this.limiteUnidadesVendidas,
    this.unidadesVendidas = 0,
    this.limiteUsosPorCliente,
    this.periodoLimiteCliente,
    this.somenteAniversariante = false,
    this.canal = PromocaoCanal.ambos,
    this.ativa = true,
    this.restringirFormasPagamento = false,
    this.formasPagamento = const [],
    this.criadoEm,
    this.atualizadoEm,
  });

  factory PromocaoDto.fromJson(Map<String, dynamic> json) {
    return PromocaoDto(
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      nome: (json['nome'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      regras: json['regras'] as String?,
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
      limiteUnidadesVendidas:
          (json['limiteUnidadesVendidas'] as num?)?.toInt(),
      unidadesVendidas: (json['unidadesVendidas'] as num?)?.toInt() ?? 0,
      limiteUsosPorCliente: (json['limiteUsosPorCliente'] as num?)?.toInt(),
      periodoLimiteCliente:
          PeriodoLimiteCliente.fromString(json['periodoLimiteCliente'] as String?),
      somenteAniversariante: json['somenteAniversariante'] as bool? ?? false,
      canal: PromocaoCanal.fromString(json['canal'] as String?),
      ativa: json['ativa'] as bool? ?? true,
      restringirFormasPagamento:
          json['restringirFormasPagamento'] as bool? ?? false,
      formasPagamento: (json['formasPagamento'] as List<dynamic>?)
              ?.map((e) =>
                  PromocaoFormaPagamento.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      criadoEm: _parseDateTime(json['criadoEm']),
      atualizadoEm: _parseDateTime(json['atualizadoEm']),
    );
  }

  factory PromocaoDto.fromModel(Promocao promocao) {
    return PromocaoDto(
      id: promocao.id,
      empresaId: promocao.empresaId,
      nome: promocao.nome,
      descricao: promocao.descricao,
      regras: promocao.regras,
      dataInicio: promocao.dataInicio,
      dataFim: promocao.dataFim,
      tipoDesconto: promocao.tipoDesconto,
      valorPercentual: promocao.valorPercentual,
      valorDescontoMaximo: promocao.valorDescontoMaximo,
      valorFixo: promocao.valorFixo,
      valorMinimoCompra: promocao.valorMinimoCompra,
      quantidadeMinima: promocao.quantidadeMinima,
      precoFixo: promocao.precoFixo,
      tipoEscopo: promocao.tipoEscopo,
      referenciaIds: promocao.referenciaIds,
      comboKit: promocao.comboKit,
      quantidadeLeva: promocao.quantidadeLeva,
      quantidadePaga: promocao.quantidadePaga,
      limiteUnidadesVendidas: promocao.limiteUnidadesVendidas,
      unidadesVendidas: promocao.unidadesVendidas,
      limiteUsosPorCliente: promocao.limiteUsosPorCliente,
      periodoLimiteCliente: promocao.periodoLimiteCliente,
      somenteAniversariante: promocao.somenteAniversariante,
      canal: promocao.canal,
      ativa: promocao.ativa,
      restringirFormasPagamento: promocao.restringirFormasPagamento,
      formasPagamento: promocao.formasPagamento,
      criadoEm: promocao.criadoEm,
      atualizadoEm: promocao.atualizadoEm,
    );
  }

  // create/update aceitam o mesmo shape -- UpdatePromocaoDto no backend e um
  // PartialType do CreatePromocaoDto.
  Map<String, dynamic> toCreateJson() {
    return {
      'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (regras != null) 'regras': regras,
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
      if (limiteUnidadesVendidas != null)
        'limiteUnidadesVendidas': limiteUnidadesVendidas,
      if (limiteUsosPorCliente != null)
        'limiteUsosPorCliente': limiteUsosPorCliente,
      if (periodoLimiteCliente != null)
        'periodoLimiteCliente': periodoLimiteCliente!.value,
      'somenteAniversariante': somenteAniversariante,
      'canal': canal.value,
      'ativa': ativa,
      'restringirFormasPagamento': restringirFormasPagamento,
      'formasPagamento':
          formasPagamento.map((forma) => forma.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();

  @override
  List<Object?> get props => [
        id,
        empresaId,
        nome,
        descricao,
        regras,
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
        limiteUnidadesVendidas,
        unidadesVendidas,
        limiteUsosPorCliente,
        periodoLimiteCliente,
        somenteAniversariante,
        canal,
        ativa,
        restringirFormasPagamento,
        formasPagamento,
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
