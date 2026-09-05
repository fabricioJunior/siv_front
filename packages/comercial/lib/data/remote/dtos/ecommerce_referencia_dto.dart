import 'package:comercial/models.dart';

class EcommerceReferenciaDto implements EcommerceReferencia {
  @override
  final int? id;
  @override
  final int ecommerceId;
  @override
  final int referenciaId;
  @override
  final int? tabelaDePrecoId;
  @override
  final bool rascunho;
  @override
  final String? referenciaNome;
  @override
  final double? valor;
  @override
  final String? descricao;
  @override
  final String? unidadeMedida;
  @override
  final String? imagemUrl;
  @override
  final num? saldo;
  @override
  final String? categoriaNome;
  @override
  final int? produtosTotal;
  @override
  final int? produtosDisponiveis;
  @override
  final bool? publicavel;
  @override
  final List<String>? motivosBloqueio;
  @override
  final String? tabelaDePrecoNome;

  const EcommerceReferenciaDto({
    this.id,
    required this.ecommerceId,
    required this.referenciaId,
    this.tabelaDePrecoId,
    this.rascunho = true,
    this.referenciaNome,
    this.valor,
    this.descricao,
    this.unidadeMedida,
    this.imagemUrl,
    this.saldo,
    this.categoriaNome,
    this.produtosTotal,
    this.produtosDisponiveis,
    this.publicavel,
    this.motivosBloqueio,
    this.tabelaDePrecoNome,
  });

  factory EcommerceReferenciaDto.fromJson(Map<String, dynamic> json) {
    return EcommerceReferenciaDto(
      id: _toInt(json['id']),
      ecommerceId: _toInt(json['ecommerceId']) ?? 0,
      referenciaId: _toInt(json['referenciaId']) ?? 0,
      tabelaDePrecoId: _toInt(json['tabelaDePrecoId']),
      rascunho: json['rascunho'] as bool? ?? true,
      referenciaNome: (json['referenciaNome'] ??
              json['nome'] ??
              json['referencia']?['nome'])
          ?.toString(),
      valor: double.tryParse(json['valor']?.toString() ?? ''),
      descricao: json['descricao']?.toString(),
      unidadeMedida: json['unidadeMedida']?.toString(),
      imagemUrl: json['media_url']?.toString(),
      saldo: num.tryParse(json['saldo']?.toString() ?? ''),
      categoriaNome: json['categoriaNome']?.toString(),
      produtosTotal: _toInt(json['produtosTotal']),
      produtosDisponiveis: _toInt(json['produtosDisponiveis']),
      publicavel: json['publicavel'] as bool?,
      motivosBloqueio: (json['motivosBloqueio'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tabelaDePrecoNome: json['tabelaDePrecoNome']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referenciaId': referenciaId,
      if (tabelaDePrecoId != null) 'tabelaDePrecoId': tabelaDePrecoId,
      'rascunho': rascunho,
    };
  }

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
        valor,
        descricao,
        unidadeMedida,
        imagemUrl,
        saldo,
        categoriaNome,
        produtosTotal,
        produtosDisponiveis,
        publicavel,
        motivosBloqueio,
        tabelaDePrecoNome,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');
