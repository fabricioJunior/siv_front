import 'package:comercial/models.dart';

class RomaneioDto implements Romaneio {
  @override
  final int? id;
  @override
  final List<int> romaneiosDevolucao;
  @override
  final int? consignacaoId;
  @override
  final List<int> romaneiosConsignacao;
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
  final double? valorTaxaEntrega;
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
  @override
  final String? pessoaDocumento;
  @override
  final String? pessoaContato;
  @override
  final String? pessoaCep;
  @override
  final String? pessoaLogradouro;
  @override
  final String? pessoaNumero;
  @override
  final String? pessoaComplemento;
  @override
  final String? pessoaBairro;
  @override
  final String? pessoaMunicipio;
  @override
  final String? pessoaUf;
  @override
  final String? empresaNome;
  @override
  final String? empresaNomeFantasia;
  @override
  final String? empresaCnpj;
  @override
  final String? operadorNome;
  @override
  final String? operadorUsuario;
  @override
  final int? prazoFrete;
  @override
  final String? observacaoFrete;
  @override
  final double? valorFrete;
  @override
  final int? caixaId;
  @override
  final int? caixaTerminalId;
  @override
  final String? caixaTerminalNome;
  @override
  final bool? temEntrega;
  @override
  final String? enderecoCep;
  @override
  final String? enderecoLogradouro;
  @override
  final String? enderecoNumero;
  @override
  final String? enderecoComplemento;
  @override
  final String? enderecoBairro;
  @override
  final String? enderecoMunicipio;
  @override
  final String? enderecoUf;

  const RomaneioDto({
    this.id,
    this.romaneiosDevolucao = const [],
    this.consignacaoId,
    this.romaneiosConsignacao = const [],
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
    this.valorTaxaEntrega,
    this.valorLiquido,
    this.observacao,
    this.data,
    this.criadoEm,
    this.atualizadoEm,
    this.formasDePagamentoRealizadas = const [],
    this.pessoaDocumento,
    this.pessoaContato,
    this.pessoaCep,
    this.pessoaLogradouro,
    this.pessoaNumero,
    this.pessoaComplemento,
    this.pessoaBairro,
    this.pessoaMunicipio,
    this.pessoaUf,
    this.empresaNome,
    this.empresaNomeFantasia,
    this.empresaCnpj,
    this.operadorNome,
    this.operadorUsuario,
    this.prazoFrete,
    this.observacaoFrete,
    this.valorFrete,
    this.caixaId,
    this.caixaTerminalId,
    this.caixaTerminalNome,
    this.temEntrega,
    this.enderecoCep,
    this.enderecoLogradouro,
    this.enderecoNumero,
    this.enderecoComplemento,
    this.enderecoBairro,
    this.enderecoMunicipio,
    this.enderecoUf,
  });

  factory RomaneioDto.fromJson(Map<String, dynamic> json) {
    return RomaneioDto(
      id: _toInt(json['romaneioId'] ?? json['id']),
      romaneiosDevolucao: _toIntList(json['romaneiosDevolucao']),
      consignacaoId: _toInt(json['consignacaoId']),
      romaneiosConsignacao: _toIntList(json['romaneiosConsignacao']),
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
      valorTaxaEntrega: _toDouble(json['valorTaxaEntrega']),
      valorLiquido: _toDouble(json['valorLiquido']),
      observacao: json['observacao']?.toString(),
      data: _toDate(json['data']),
      criadoEm: _toDate(json['criadoEm']),
      atualizadoEm: _toDate(json['atualizadoEm']),
      formasDePagamentoRealizadas: _toFormasDePagamentoRealizadas(
        json['formasDePagamentoRealizadas'] ?? json['pagamentos'],
      ),
      pessoaDocumento: json['pessoaDocumento']?.toString(),
      pessoaContato: json['pessoaContato']?.toString(),
      pessoaCep: json['pessoaCep']?.toString(),
      pessoaLogradouro: json['pessoaLogradouro']?.toString(),
      pessoaNumero: json['pessoaNumero']?.toString(),
      pessoaComplemento: json['pessoaComplemento']?.toString(),
      pessoaBairro: json['pessoaBairro']?.toString(),
      pessoaMunicipio: json['pessoaMunicipio']?.toString(),
      pessoaUf: json['pessoaUf']?.toString(),
      empresaNome: json['empresaNome']?.toString(),
      empresaNomeFantasia: json['empresaNomeFantasia']?.toString(),
      empresaCnpj: json['empresaCnpj']?.toString(),
      operadorNome: json['operadorNome']?.toString(),
      operadorUsuario: json['operadorUsuario']?.toString(),
      prazoFrete: _toInt(json['prazoFrete']),
      observacaoFrete: json['observacaoFrete']?.toString(),
      valorFrete: _toDouble(json['valorFrete']),
      caixaId: _toInt(json['caixaId']),
      caixaTerminalId: _toInt(json['caixaTerminalId']),
      caixaTerminalNome: json['caixaTerminalNome']?.toString(),
      temEntrega: json['temEntrega'] as bool?,
      enderecoCep: json['enderecoCep']?.toString(),
      enderecoLogradouro: json['enderecoLogradouro']?.toString(),
      enderecoNumero: json['enderecoNumero']?.toString(),
      enderecoComplemento: json['enderecoComplemento']?.toString(),
      enderecoBairro: json['enderecoBairro']?.toString(),
      enderecoMunicipio: json['enderecoMunicipio']?.toString(),
      enderecoUf: json['enderecoUf']?.toString(),
    );
  }

  factory RomaneioDto.fromModel(Romaneio romaneio) {
    return RomaneioDto(
      id: romaneio.id,
      romaneiosDevolucao: romaneio.romaneiosDevolucao,
      consignacaoId: romaneio.consignacaoId,
      romaneiosConsignacao: romaneio.romaneiosConsignacao,
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
      valorTaxaEntrega: romaneio.valorTaxaEntrega,
      valorLiquido: romaneio.valorLiquido,
      observacao: romaneio.observacao,
      data: romaneio.data,
      criadoEm: romaneio.criadoEm,
      atualizadoEm: romaneio.atualizadoEm,
      formasDePagamentoRealizadas: romaneio.formasDePagamentoRealizadas,
      pessoaDocumento: romaneio.pessoaDocumento,
      pessoaContato: romaneio.pessoaContato,
      pessoaCep: romaneio.pessoaCep,
      pessoaLogradouro: romaneio.pessoaLogradouro,
      pessoaNumero: romaneio.pessoaNumero,
      pessoaComplemento: romaneio.pessoaComplemento,
      pessoaBairro: romaneio.pessoaBairro,
      pessoaMunicipio: romaneio.pessoaMunicipio,
      pessoaUf: romaneio.pessoaUf,
      empresaNome: romaneio.empresaNome,
      empresaNomeFantasia: romaneio.empresaNomeFantasia,
      empresaCnpj: romaneio.empresaCnpj,
      operadorNome: romaneio.operadorNome,
      operadorUsuario: romaneio.operadorUsuario,
      prazoFrete: romaneio.prazoFrete,
      observacaoFrete: romaneio.observacaoFrete,
      valorFrete: romaneio.valorFrete,
      caixaId: romaneio.caixaId,
      caixaTerminalId: romaneio.caixaTerminalId,
      caixaTerminalNome: romaneio.caixaTerminalNome,
      temEntrega: romaneio.temEntrega,
      enderecoCep: romaneio.enderecoCep,
      enderecoLogradouro: romaneio.enderecoLogradouro,
      enderecoNumero: romaneio.enderecoNumero,
      enderecoComplemento: romaneio.enderecoComplemento,
      enderecoBairro: romaneio.enderecoBairro,
      enderecoMunicipio: romaneio.enderecoMunicipio,
      enderecoUf: romaneio.enderecoUf,
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
      if (consignacaoId != null) 'consignacaoId': consignacaoId,
      if (romaneiosConsignacao.isNotEmpty)
        'romaneiosConsignacao': romaneiosConsignacao,
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
        consignacaoId,
        romaneiosConsignacao,
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
        valorTaxaEntrega,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
        desconto,
        pessoaDocumento,
        pessoaContato,
        pessoaCep,
        pessoaLogradouro,
        pessoaNumero,
        pessoaComplemento,
        pessoaBairro,
        pessoaMunicipio,
        pessoaUf,
        empresaNome,
        empresaNomeFantasia,
        empresaCnpj,
        operadorNome,
        operadorUsuario,
        prazoFrete,
        observacaoFrete,
        valorFrete,
        caixaId,
        caixaTerminalId,
        caixaTerminalNome,
        temEntrega,
        enderecoCep,
        enderecoLogradouro,
        enderecoNumero,
        enderecoComplemento,
        enderecoBairro,
        enderecoMunicipio,
        enderecoUf,
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
        vencimento: json['vencimento']?.toString(),
        tipoHistorico: json['tipoHistorico']?.toString(),
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
