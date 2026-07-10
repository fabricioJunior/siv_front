import 'package:comercial/models.dart';

class ConsignacaoItemDto implements ConsignacaoItem {
  @override
  final int? empresaId;
  @override
  final int? consignacaoId;
  @override
  final int? pessoaId;
  @override
  final int? romaneioId;
  @override
  final int? sequencia;
  @override
  final int? produtoId;
  @override
  final double? solicitado;
  @override
  final double? valorSolicitado;
  @override
  final double? devolvido;
  @override
  final double? valorDevolvido;
  @override
  final double? acertado;
  @override
  final double? valorAcertado;
  @override
  final double? pendente;
  @override
  final double? valorPendente;
  @override
  final int? operadorId;

  const ConsignacaoItemDto({
    this.empresaId,
    this.consignacaoId,
    this.pessoaId,
    this.romaneioId,
    this.sequencia,
    this.produtoId,
    this.solicitado,
    this.valorSolicitado,
    this.devolvido,
    this.valorDevolvido,
    this.acertado,
    this.valorAcertado,
    this.pendente,
    this.valorPendente,
    this.operadorId,
  });

  factory ConsignacaoItemDto.fromJson(Map<String, dynamic> json) {
    return ConsignacaoItemDto(
      empresaId: _toInt(json['empresaId']),
      consignacaoId: _toInt(json['consignacaoId']),
      pessoaId: _toInt(json['pessoaId']),
      romaneioId: _toInt(json['romaneioId']),
      sequencia: _toInt(json['sequencia']),
      produtoId: _toInt(json['produtoId']),
      solicitado: _toDouble(json['solicitado']),
      valorSolicitado: _toDouble(json['valorSolicitado']),
      devolvido: _toDouble(json['devolvido']),
      valorDevolvido: _toDouble(json['valorDevolvido']),
      acertado: _toDouble(json['acertado']),
      valorAcertado: _toDouble(json['valorAcertado']),
      pendente: _toDouble(json['pendente']),
      valorPendente: _toDouble(json['valorPendente']),
      operadorId: _toInt(json['operadorId']),
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        consignacaoId,
        pessoaId,
        romaneioId,
        sequencia,
        produtoId,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) => (value as num?)?.toDouble();
