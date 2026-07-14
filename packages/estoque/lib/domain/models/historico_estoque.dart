import 'package:core/equals.dart';

/// Movimentação histórica de estoque (kardex), com saldo do produto no
/// momento exato da movimentação (`saldoApos`).
///
/// `operacao` mantido como `String` (não um enum tipado) para não criar
/// dependência de `estoque` para `comercial` (onde vive `TipoOperacao`) --
/// `comercial` já depende de `estoque`, então o inverso criaria ciclo.
abstract class HistoricoEstoque implements Equatable {
  int get romaneioId;
  DateTime get dataHora;
  String get operacao;
  String get modalidade;
  int get referenciaId;
  String get referenciaNome;
  int get produtoId;
  String? get produtoIdExterno;
  String? get corNome;
  String? get tamanhoNome;
  double get quantidade;
  double get saldoApos;
  int? get funcionarioId;
  String? get funcionarioNome;
  int? get operadorId;
  String? get operadorNome;
  int? get pessoaId;
  String? get pessoaNome;
  int? get caixaId;
  String? get caixaTerminalNome;

  factory HistoricoEstoque.create({
    required int romaneioId,
    required DateTime dataHora,
    required String operacao,
    required String modalidade,
    required int referenciaId,
    required String referenciaNome,
    required int produtoId,
    String? produtoIdExterno,
    String? corNome,
    String? tamanhoNome,
    required double quantidade,
    required double saldoApos,
    int? funcionarioId,
    String? funcionarioNome,
    int? operadorId,
    String? operadorNome,
    int? pessoaId,
    String? pessoaNome,
    int? caixaId,
    String? caixaTerminalNome,
  }) = _HistoricoEstoqueImpl;

  bool get ehEntrada => modalidade == 'entrada';

  @override
  List<Object?> get props => [
    romaneioId,
    dataHora,
    operacao,
    modalidade,
    referenciaId,
    referenciaNome,
    produtoId,
    produtoIdExterno,
    corNome,
    tamanhoNome,
    quantidade,
    saldoApos,
    funcionarioId,
    funcionarioNome,
    operadorId,
    operadorNome,
    pessoaId,
    pessoaNome,
    caixaId,
    caixaTerminalNome,
  ];

  @override
  bool? get stringify => true;
}

class _HistoricoEstoqueImpl implements HistoricoEstoque {
  @override
  final int romaneioId;
  @override
  final DateTime dataHora;
  @override
  final String operacao;
  @override
  final String modalidade;
  @override
  final int referenciaId;
  @override
  final String referenciaNome;
  @override
  final int produtoId;
  @override
  final String? produtoIdExterno;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;
  @override
  final double quantidade;
  @override
  final double saldoApos;
  @override
  final int? funcionarioId;
  @override
  final String? funcionarioNome;
  @override
  final int? operadorId;
  @override
  final String? operadorNome;
  @override
  final int? pessoaId;
  @override
  final String? pessoaNome;
  @override
  final int? caixaId;
  @override
  final String? caixaTerminalNome;

  _HistoricoEstoqueImpl({
    required this.romaneioId,
    required this.dataHora,
    required this.operacao,
    required this.modalidade,
    required this.referenciaId,
    required this.referenciaNome,
    required this.produtoId,
    this.produtoIdExterno,
    this.corNome,
    this.tamanhoNome,
    required this.quantidade,
    required this.saldoApos,
    this.funcionarioId,
    this.funcionarioNome,
    this.operadorId,
    this.operadorNome,
    this.pessoaId,
    this.pessoaNome,
    this.caixaId,
    this.caixaTerminalNome,
  });

  @override
  bool get ehEntrada => modalidade == 'entrada';

  @override
  List<Object?> get props => [
    romaneioId,
    dataHora,
    operacao,
    modalidade,
    referenciaId,
    referenciaNome,
    produtoId,
    produtoIdExterno,
    corNome,
    tamanhoNome,
    quantidade,
    saldoApos,
    funcionarioId,
    funcionarioNome,
    operadorId,
    operadorNome,
    pessoaId,
    pessoaNome,
    caixaId,
    caixaTerminalNome,
  ];

  @override
  bool? get stringify => true;
}
