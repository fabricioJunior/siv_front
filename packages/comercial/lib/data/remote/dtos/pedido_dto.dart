import 'package:comercial/models.dart';

class PedidoDto implements Pedido {
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final int? funcionarioId;
  @override
  final int? tabelaPrecoId;
  @override
  final DateTime? dataBasePagamento;
  @override
  final int? parcelas;
  @override
  final int? intervalo;
  @override
  final DateTime? previsaoDeFaturamento;
  @override
  final DateTime? previsaoDeEntrega;
  @override
  final String? tipo;
  @override
  final bool? fiscal;
  @override
  final String? observacao;
  @override
  final String? situacao;
  @override
  final String? motivoCancelamento;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const PedidoDto({
    this.id,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.dataBasePagamento,
    this.parcelas,
    this.intervalo,
    this.previsaoDeFaturamento,
    this.previsaoDeEntrega,
    this.tipo,
    this.fiscal,
    this.observacao,
    this.situacao,
    this.motivoCancelamento,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory PedidoDto.fromJson(Map<String, dynamic> json) {
    return PedidoDto(
      id: _toInt(json['id']),
      pessoaId: _toInt(json['pessoaId']),
      funcionarioId: _toInt(json['funcionarioId']),
      tabelaPrecoId: _toInt(json['tabelaPrecoId']),
      dataBasePagamento: _toDate(json['dataBasePagamento']),
      parcelas: _toInt(json['parcelas']),
      intervalo: _toInt(json['intervalo']),
      previsaoDeFaturamento: _toDate(json['previsaoDeFaturamento']),
      previsaoDeEntrega: _toDate(json['previsaoDeEntrega']),
      tipo: json['tipo']?.toString(),
      fiscal: json['fiscal'] as bool?,
      observacao: json['observacao']?.toString(),
      situacao: json['situacao']?.toString(),
      motivoCancelamento: json['motivoCancelamento']?.toString(),
      criadoEm: _toDate(json['criadoEm']),
      atualizadoEm: _toDate(json['atualizadoEm']),
    );
  }

  factory PedidoDto.fromModel(Pedido pedido) {
    return PedidoDto(
      id: pedido.id,
      pessoaId: pedido.pessoaId,
      funcionarioId: pedido.funcionarioId,
      tabelaPrecoId: pedido.tabelaPrecoId,
      dataBasePagamento: pedido.dataBasePagamento,
      parcelas: pedido.parcelas,
      intervalo: pedido.intervalo,
      previsaoDeFaturamento: pedido.previsaoDeFaturamento,
      previsaoDeEntrega: pedido.previsaoDeEntrega,
      tipo: pedido.tipo,
      fiscal: pedido.fiscal,
      observacao: pedido.observacao,
      situacao: pedido.situacao,
      motivoCancelamento: pedido.motivoCancelamento,
      criadoEm: pedido.criadoEm,
      atualizadoEm: pedido.atualizadoEm,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'pessoaId': pessoaId,
      'funcionarioId': funcionarioId,
      'tabelaPrecoId': tabelaPrecoId,
      'dataBasePagamento': _toDateOnly(dataBasePagamento),
      'parcelas': parcelas,
      'intervalo': intervalo,
      'previsaoDeFaturamento': _toDateOnly(previsaoDeFaturamento),
      'previsaoDeEntrega': _toDateOnly(previsaoDeEntrega),
      'tipo': tipo,
      'fiscal': fiscal ?? false,
      'observacao': observacao ?? '',
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'pessoaId': pessoaId,
      'funcionarioId': funcionarioId,
      'tabelaPrecoId': tabelaPrecoId,
      'dataBasePagamento': _toDateOnly(dataBasePagamento),
      'parcelas': parcelas,
      'intervalo': intervalo,
      'previsaoDeFaturamento': _toDateOnly(previsaoDeFaturamento),
      'previsaoDeEntrega': _toDateOnly(previsaoDeEntrega),
      'fiscal': fiscal,
      'observacao': observacao,
    };
  }

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        dataBasePagamento,
        parcelas,
        intervalo,
        previsaoDeFaturamento,
        previsaoDeEntrega,
        tipo,
        fiscal,
        observacao,
        situacao,
        motivoCancelamento,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => (value as num?)?.toInt();

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String? _toDateOnly(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String().split('T').first;
}
