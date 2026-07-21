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
  @override
  final String? modalidadeEntrega;
  @override
  final int? enderecoEntregaId;
  @override
  final String? situacaoPagamento;
  @override
  final String? situacaoEntrega;
  @override
  final int? pedidoOrigemId;
  @override
  final double? valorTaxaEntrega;
  @override
  final String? pessoaNome;
  @override
  final String? funcionarioNome;
  @override
  final String? tabelaPrecoNome;
  @override
  final double? valorTotal;
  @override
  final String? origem;
  @override
  final int? romaneioId;
  @override
  final String? empresaNome;
  @override
  final String? empresaCnpj;

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
    this.modalidadeEntrega,
    this.enderecoEntregaId,
    this.situacaoPagamento,
    this.situacaoEntrega,
    this.pedidoOrigemId,
    this.valorTaxaEntrega,
    this.pessoaNome,
    this.funcionarioNome,
    this.tabelaPrecoNome,
    this.valorTotal,
    this.origem,
    this.romaneioId,
    this.empresaNome,
    this.empresaCnpj,
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
      modalidadeEntrega: json['modalidadeEntrega']?.toString(),
      enderecoEntregaId: _toInt(json['enderecoEntregaId']),
      situacaoPagamento: json['situacaoPagamento']?.toString(),
      situacaoEntrega: json['situacaoEntrega']?.toString(),
      pedidoOrigemId: _toInt(json['pedidoOrigemId']),
      valorTaxaEntrega: _toDouble(json['valorTaxaEntrega']),
      pessoaNome: json['pessoaNome']?.toString(),
      funcionarioNome: json['funcionarioNome']?.toString(),
      tabelaPrecoNome: json['tabelaPrecoNome']?.toString(),
      valorTotal: _toDouble(json['valorTotal']),
      origem: json['origem']?.toString(),
      romaneioId: _toInt(json['romaneioId']),
      empresaNome: json['empresaNome']?.toString(),
      empresaCnpj: json['empresaCnpj']?.toString(),
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
      modalidadeEntrega: pedido.modalidadeEntrega,
      enderecoEntregaId: pedido.enderecoEntregaId,
      situacaoPagamento: pedido.situacaoPagamento,
      situacaoEntrega: pedido.situacaoEntrega,
      pedidoOrigemId: pedido.pedidoOrigemId,
      valorTaxaEntrega: pedido.valorTaxaEntrega,
      pessoaNome: pedido.pessoaNome,
      funcionarioNome: pedido.funcionarioNome,
      tabelaPrecoNome: pedido.tabelaPrecoNome,
      valorTotal: pedido.valorTotal,
      origem: pedido.origem,
      romaneioId: pedido.romaneioId,
      empresaNome: pedido.empresaNome,
      empresaCnpj: pedido.empresaCnpj,
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
      'modalidadeEntrega': modalidadeEntrega ?? 'retirada',
      if (enderecoEntregaId != null) 'enderecoEntregaId': enderecoEntregaId,
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
      'modalidadeEntrega': modalidadeEntrega,
      if (enderecoEntregaId != null) 'enderecoEntregaId': enderecoEntregaId,
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
        modalidadeEntrega,
        enderecoEntregaId,
        situacaoPagamento,
        situacaoEntrega,
        pedidoOrigemId,
        valorTaxaEntrega,
        pessoaNome,
        funcionarioNome,
        tabelaPrecoNome,
        valorTotal,
        origem,
        romaneioId,
        empresaNome,
        empresaCnpj,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String? _toDateOnly(DateTime? value) {
  if (value == null) return null;

  final ano = value.year.toString().padLeft(4, '0');
  final mes = value.month.toString().padLeft(2, '0');
  final dia = value.day.toString().padLeft(2, '0');

  return '$ano-$mes-$dia';
}
