import 'package:core/equals.dart';

abstract class Pagamento implements Equatable {
  int get controle;
  int get formaDePagamentoId;
  int get parcela;
  double get valor;

  DateTime? get vencimento;
  String? get banco;
  String? get agencia;
  String? get conta;
  String? get documento;
  String? get nsu;
  String? get autorizacao;
  int? get cheque;
  String? get banda;
  bool? get chequerTerceiro;
  String? get cpfCnpjTerceiro;
  String? get nomeTerceiro;
  String? get telefoneTerceiro;

  factory Pagamento.create({
    required int controle,
    required int formaDePagamentoId,
    required int parcela,
    required double valor,
    DateTime? vencimento,
    String? banco,
    String? agencia,
    String? conta,
    String? documento,
    String? nsu,
    String? autorizacao,
    int? cheque,
    String? banda,
    bool? chequerTerceiro,
    String? cpfCnpjTerceiro,
    String? nomeTerceiro,
    String? telefoneTerceiro,
  }) = _PagamentoImpl;

  @override
  List<Object?> get props => [
        controle,
        formaDePagamentoId,
        parcela,
        valor,
        vencimento,
        banco,
        agencia,
        conta,
        documento,
        nsu,
        autorizacao,
        cheque,
        banda,
        chequerTerceiro,
        cpfCnpjTerceiro,
        nomeTerceiro,
        telefoneTerceiro,
      ];

  @override
  bool? get stringify => true;
}

class _PagamentoImpl implements Pagamento {
  @override
  final int controle;

  @override
  final int formaDePagamentoId;

  @override
  final int parcela;

  @override
  final double valor;

  @override
  final DateTime? vencimento;

  @override
  final String? banco;

  @override
  final String? agencia;

  @override
  final String? conta;

  @override
  final String? documento;

  @override
  final String? nsu;

  @override
  final String? autorizacao;

  @override
  final int? cheque;

  @override
  final String? banda;

  @override
  final bool? chequerTerceiro;

  @override
  final String? cpfCnpjTerceiro;

  @override
  final String? nomeTerceiro;

  @override
  final String? telefoneTerceiro;

  const _PagamentoImpl({
    required this.controle,
    required this.formaDePagamentoId,
    required this.parcela,
    required this.valor,
    this.vencimento,
    this.banco,
    this.agencia,
    this.conta,
    this.documento,
    this.nsu,
    this.autorizacao,
    this.cheque,
    this.banda,
    this.chequerTerceiro,
    this.cpfCnpjTerceiro,
    this.nomeTerceiro,
    this.telefoneTerceiro,
  });

  @override
  List<Object?> get props => [
        controle,
        formaDePagamentoId,
        parcela,
        valor,
        vencimento,
        banco,
        agencia,
        conta,
        documento,
        nsu,
        autorizacao,
        cheque,
        banda,
        chequerTerceiro,
        cpfCnpjTerceiro,
        nomeTerceiro,
        telefoneTerceiro,
      ];

  @override
  bool? get stringify => true;
}
