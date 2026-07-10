import 'package:comercial/data/remote/dtos/consignacao_item_dto.dart';
import 'package:comercial/models.dart';

class ConsignacaoDto implements Consignacao {
  @override
  final int? empresaId;
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final String? nomePessoa;
  @override
  final int? tabelaPrecoId;
  @override
  final int? caixaAbertura;
  @override
  final DateTime? dataAbertura;
  @override
  final DateTime? previsaoFechamento;
  @override
  final int? caixaFechamento;
  @override
  final DateTime? dataFechamento;
  @override
  final int? funcionarioId;
  @override
  final String? nomeFuncionario;
  @override
  final String? observacao;
  @override
  final SituacaoConsignacao? situacao;
  @override
  final String? motivoCancelamento;
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
  @override
  final List<ConsignacaoItem> itens;

  const ConsignacaoDto({
    this.empresaId,
    this.id,
    this.pessoaId,
    this.nomePessoa,
    this.tabelaPrecoId,
    this.caixaAbertura,
    this.dataAbertura,
    this.previsaoFechamento,
    this.caixaFechamento,
    this.dataFechamento,
    this.funcionarioId,
    this.nomeFuncionario,
    this.observacao,
    this.situacao,
    this.motivoCancelamento,
    this.solicitado,
    this.valorSolicitado,
    this.devolvido,
    this.valorDevolvido,
    this.acertado,
    this.valorAcertado,
    this.pendente,
    this.valorPendente,
    this.operadorId,
    this.itens = const [],
  });

  factory ConsignacaoDto.fromJson(Map<String, dynamic> json) {
    return ConsignacaoDto(
      empresaId: _toInt(json['empresaId']),
      id: _toInt(json['id']),
      pessoaId: _toInt(json['pessoaId']),
      nomePessoa: json['nomePessoa']?.toString(),
      tabelaPrecoId: _toInt(json['tabelaPrecoId']),
      caixaAbertura: _toInt(json['caixaAbertura']),
      dataAbertura: _toDate(json['dataAbertura']),
      previsaoFechamento: _toDate(json['previsaoFechamento']),
      caixaFechamento: _toInt(json['caixaFechamento']),
      dataFechamento: _toDate(json['dataFechamento']),
      funcionarioId: _toInt(json['funcionarioId']),
      nomeFuncionario: json['nomeFuncionario']?.toString(),
      observacao: json['observacao']?.toString(),
      situacao: SituacaoConsignacao.fromJson(json['situacao']),
      motivoCancelamento: json['motivoCancelamento']?.toString(),
      solicitado: _toDouble(json['solicitado']),
      valorSolicitado: _toDouble(json['valorSolicitado']),
      devolvido: _toDouble(json['devolvido']),
      valorDevolvido: _toDouble(json['valorDevolvido']),
      acertado: _toDouble(json['acertado']),
      valorAcertado: _toDouble(json['valorAcertado']),
      pendente: _toDouble(json['pendente']),
      valorPendente: _toDouble(json['valorPendente']),
      operadorId: _toInt(json['operadorId']),
      itens: _toItens(json['itens']),
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        id,
        pessoaId,
        nomePessoa,
        tabelaPrecoId,
        caixaAbertura,
        dataAbertura,
        previsaoFechamento,
        caixaFechamento,
        dataFechamento,
        funcionarioId,
        nomeFuncionario,
        observacao,
        situacao,
        motivoCancelamento,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
        itens,
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

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<ConsignacaoItem> _toItens(dynamic value) {
  final itens = value as List<dynamic>? ?? const [];
  return itens
      .whereType<Map>()
      .map((item) => ConsignacaoItemDto.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}
