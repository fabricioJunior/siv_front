import 'package:comercial/models.dart';

class RomaneioDto implements Romaneio {
  @override
  final int? id;
  @override
  final List<int> romaneiosDevolucao;
  @override
  final int? pessoaId;
  @override
  final String? pessoaNome;
  @override
  final int? funcionarioId;
  @override
  final String? funcionarioNome;
  @override
  final int? tabelaPrecoId;
  @override
  final String? modalidade;
  @override
  final TipoOperacao? operacao;
  @override
  final String? situacao;
  @override
  final double? quantidade;
  @override
  final double? valorBruto;
  @override
  final double? desconto;
  @override
  final double? valorLiquido;
  @override
  final String? observacao;
  @override
  final DateTime? data;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;
  @override
  final List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas;

  const RomaneioDto({
    this.id,
    this.romaneiosDevolucao = const [],
    this.pessoaId,
    this.pessoaNome,
    this.funcionarioId,
    this.funcionarioNome,
    this.tabelaPrecoId,
    this.modalidade,
    this.operacao,
    this.situacao,
    this.quantidade,
    this.valorBruto,
    this.desconto,
    this.valorLiquido,
    this.observacao,
    this.data,
    this.criadoEm,
    this.atualizadoEm,
    this.formasDePagamentoRealizadas = const [],
  });

  factory RomaneioDto.fromJson(Map<String, dynamic> json) {
    return RomaneioDto(
      id: _toInt(json['romaneioId'] ?? json['id']),
      romaneiosDevolucao: _toIntList(json['romaneiosDevolucao']),
      pessoaId: _toInt(json['pessoaId']),
      pessoaNome: json['pessoaNome']?.toString(),
      funcionarioId: _toInt(json['funcionarioId']),
      funcionarioNome: json['funcionarioNome']?.toString(),
      tabelaPrecoId: _toInt(json['tabelaPrecoId']),
      modalidade: json['modalidade']?.toString(),
      operacao: TipoOperacao.fromJson(json['operacao']),
      situacao: json['situacao']?.toString(),
      quantidade: _toDouble(json['quantidade']),
      valorBruto: _toDouble(json['valorBruto']),
      desconto: _toDouble(json['desconto']) ?? _toDouble(json['valorDesconto']),
      valorLiquido: _toDouble(json['valorLiquido']),
      observacao: json['observacao']?.toString(),
      data: _toDate(json['data']),
      criadoEm: _toDate(json['criadoEm']),
      atualizadoEm: _toDate(json['atualizadoEm']),
      formasDePagamentoRealizadas: _toFormasDePagamentoRealizadas(
        json['formasDePagamentoRealizadas'] ?? json['pagamentos'],
      ),
    );
  }

  factory RomaneioDto.fromModel(Romaneio romaneio) {
    return RomaneioDto(
      id: romaneio.id,
      romaneiosDevolucao: romaneio.romaneiosDevolucao,
      pessoaId: romaneio.pessoaId,
      pessoaNome: romaneio.pessoaNome,
      funcionarioId: romaneio.funcionarioId,
      funcionarioNome: romaneio.funcionarioNome,
      tabelaPrecoId: romaneio.tabelaPrecoId,
      modalidade: romaneio.modalidade,
      operacao: romaneio.operacao,
      situacao: romaneio.situacao,
      quantidade: romaneio.quantidade,
      valorBruto: romaneio.valorBruto,
      desconto: romaneio.desconto,
      valorLiquido: romaneio.valorLiquido,
      observacao: romaneio.observacao,
      data: romaneio.data,
      criadoEm: romaneio.criadoEm,
      atualizadoEm: romaneio.atualizadoEm,
      formasDePagamentoRealizadas: romaneio.formasDePagamentoRealizadas,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'pessoaId': pessoaId,
      'funcionarioId': funcionarioId,
      'tabelaPrecoId': tabelaPrecoId,
      'operacao': operacao?.toJsonValue(),
      if (romaneiosDevolucao.isNotEmpty)
        'romaneiosDevolucao': romaneiosDevolucao,
      'desconto': desconto,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'pessoaId': pessoaId,
      'funcionarioId': funcionarioId,
      'tabelaPrecoId': tabelaPrecoId,
      'desconto': desconto,
    };
  }

  @override
  List<Object?> get props => [
        id,
        romaneiosDevolucao,
        pessoaId,
        pessoaNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        modalidade,
        operacao,
        situacao,
        quantidade,
        valorBruto,
        desconto,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
        desconto,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value.toString());

double? _toDouble(dynamic value) => (value as num?)?.toDouble();

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<RomaneioPagamentoRealizado> _toFormasDePagamentoRealizadas(dynamic value) {
  final itens = value as List<dynamic>? ?? const [];

  final pagamentos = <RomaneioPagamentoRealizado>[];

  for (var i = 0; i < itens.length; i++) {
    final item = itens[i];
    if (item is! Map) {
      continue;
    }

    final json = Map<String, dynamic>.from(item);
    final valor = _toDouble(json['valor']) ?? 0;
    if (valor == 0) {
      continue;
    }

    final formaDePagamentoId = _toInt(json['formaDePagamentoId']) ?? 0;
    final descricao = (json['descricao'] ??
            json['formaDePagamentoNome'] ??
            json['tipoDocumento'])
        ?.toString();

    if (formaDePagamentoId <= 0 &&
        (descricao == null || descricao.trim().isEmpty)) {
      continue;
    }

    pagamentos.add(
      RomaneioPagamentoRealizado.create(
        controle:
            _toInt(json['controle']) ?? _toInt(json['documento']) ?? i + 1,
        formaDePagamentoId: formaDePagamentoId,
        parcela: _toInt(json['parcela']) ?? _toInt(json['faturaParcela']) ?? 1,
        valor: valor,
        descricao: descricao?.trim().isEmpty == true ? null : descricao?.trim(),
      ),
    );
  }

  return pagamentos;
}

List<int> _toIntList(dynamic value) {
  final itens = value as List<dynamic>? ?? const [];
  return itens
      .map((item) => _toInt(item))
      .whereType<int>()
      .toList(growable: false);
}
