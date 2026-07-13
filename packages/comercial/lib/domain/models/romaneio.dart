// ignore_for_file: constant_identifier_names

import 'package:core/equals.dart';

enum TipoOperacao {
  compra,
  compra_devolucao,
  venda,
  venda_devolucao,
  consignacao_saida,
  consignacao_devolucao,
  consignacao_acerto,
  transferencia_saida,
  transferencia_entrada,
  transferencia_devolucao,
  manual_entrada,
  manual_saida,
  outros;

  String toJsonValue() => name;

  String get descricao => toJsonValue();

  static TipoOperacao? fromJson(dynamic value) {
    if (value == null) return null;

    final normalized =
        value.toString().trim().replaceFirst('TipoOperacao.', '');

    for (final operacao in TipoOperacao.values) {
      if (operacao.name == normalized) {
        return operacao;
      }
    }

    return null;
  }
}

abstract class Romaneio implements Equatable {
  int? get id;
  List<int> get romaneiosDevolucao;
  int? get consignacaoId;
  List<int> get romaneiosConsignacao;
  int? get pessoaId;
  String? get pessoaNome;
  int? get funcionarioId;
  String? get funcionarioNome;
  int? get tabelaPrecoId;
  String? get modalidade;
  TipoOperacao? get operacao;
  String? get situacao;
  double? get quantidade;
  double? get valorBruto;
  double? get desconto;
  double? get valorLiquido;
  String? get observacao;
  DateTime? get data;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  List<RomaneioPagamentoRealizado> get formasDePagamentoRealizadas;
  String? get pessoaDocumento;
  String? get pessoaContato;
  String? get pessoaCep;
  String? get pessoaLogradouro;
  String? get pessoaNumero;
  String? get pessoaComplemento;
  String? get pessoaBairro;
  String? get pessoaMunicipio;
  String? get pessoaUf;
  String? get empresaNome;
  String? get empresaNomeFantasia;
  String? get empresaCnpj;
  String? get operadorNome;
  String? get operadorUsuario;
  int? get prazoFrete;
  String? get observacaoFrete;
  double? get valorFrete;
  int? get caixaId;
  int? get caixaTerminalId;
  String? get caixaTerminalNome;
  bool? get temEntrega;
  String? get enderecoCep;
  String? get enderecoLogradouro;
  String? get enderecoNumero;
  String? get enderecoComplemento;
  String? get enderecoBairro;
  String? get enderecoMunicipio;
  String? get enderecoUf;

  factory Romaneio.create({
    int? id,
    List<int>? romaneiosDevolucao,
    int? consignacaoId,
    List<int>? romaneiosConsignacao,
    int? pessoaId,
    String? pessoaNome,
    int? funcionarioId,
    String? funcionarioNome,
    int? tabelaPrecoId,
    String? modalidade,
    TipoOperacao? operacao,
    String? situacao,
    double? quantidade,
    double? valorBruto,
    double? desconto,
    double? valorLiquido,
    String? observacao,
    DateTime? data,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    List<RomaneioPagamentoRealizado>? formasDePagamentoRealizadas,
    String? pessoaDocumento,
    String? pessoaContato,
    String? pessoaCep,
    String? pessoaLogradouro,
    String? pessoaNumero,
    String? pessoaComplemento,
    String? pessoaBairro,
    String? pessoaMunicipio,
    String? pessoaUf,
    String? empresaNome,
    String? empresaNomeFantasia,
    String? empresaCnpj,
    String? operadorNome,
    String? operadorUsuario,
    int? prazoFrete,
    String? observacaoFrete,
    double? valorFrete,
    int? caixaId,
    int? caixaTerminalId,
    String? caixaTerminalNome,
    bool? temEntrega,
    String? enderecoCep,
    String? enderecoLogradouro,
    String? enderecoNumero,
    String? enderecoComplemento,
    String? enderecoBairro,
    String? enderecoMunicipio,
    String? enderecoUf,
  }) = _RomaneioImpl;

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
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
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

class _RomaneioImpl implements Romaneio {
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

  const _RomaneioImpl({
    this.id,
    List<int>? romaneiosDevolucao,
    this.consignacaoId,
    List<int>? romaneiosConsignacao,
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
    List<RomaneioPagamentoRealizado>? formasDePagamentoRealizadas,
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
  })  : romaneiosDevolucao = romaneiosDevolucao ?? const [],
        romaneiosConsignacao = romaneiosConsignacao ?? const [],
        formasDePagamentoRealizadas = formasDePagamentoRealizadas ?? const [];

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
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
        formasDePagamentoRealizadas,
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

abstract class RomaneioPagamentoRealizado implements Equatable {
  int get controle;
  int get formaDePagamentoId;
  int get parcela;
  double get valor;
  String? get descricao;
  String? get vencimento;
  String? get tipoHistorico;

  factory RomaneioPagamentoRealizado.create({
    required int controle,
    required int formaDePagamentoId,
    required int parcela,
    required double valor,
    String? descricao,
    String? vencimento,
    String? tipoHistorico,
  }) = _RomaneioPagamentoRealizadoImpl;

  @override
  List<Object?> get props => [
        controle,
        formaDePagamentoId,
        parcela,
        valor,
        descricao,
        vencimento,
        tipoHistorico,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioPagamentoRealizadoImpl implements RomaneioPagamentoRealizado {
  @override
  final int controle;
  @override
  final int formaDePagamentoId;
  @override
  final int parcela;
  @override
  final double valor;
  @override
  final String? descricao;
  @override
  final String? vencimento;
  @override
  final String? tipoHistorico;

  const _RomaneioPagamentoRealizadoImpl({
    required this.controle,
    required this.formaDePagamentoId,
    required this.parcela,
    required this.valor,
    this.descricao,
    this.vencimento,
    this.tipoHistorico,
  });

  @override
  List<Object?> get props => [
        controle,
        formaDePagamentoId,
        parcela,
        valor,
        descricao,
        vencimento,
        tipoHistorico,
      ];

  @override
  bool? get stringify => true;
}
