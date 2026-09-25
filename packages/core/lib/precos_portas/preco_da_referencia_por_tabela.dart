import 'package:core/equals.dart';

/// Resumo do preço de uma referência numa tabela específica -- usado pela
/// aba "Tabela de preços" da tela de Referência (produtos) sem expor
/// modelos do pacote precos.
class PrecoDaReferenciaPorTabela extends Equatable {
  final int tabelaDePrecoId;
  final String tabelaNome;
  final bool tabelaInativa;
  final bool tabelaPadrao;
  final double? terminador;
  final double? valor;
  final DateTime? atualizadoEm;
  final int? operadorId;

  const PrecoDaReferenciaPorTabela({
    required this.tabelaDePrecoId,
    required this.tabelaNome,
    required this.tabelaInativa,
    required this.tabelaPadrao,
    this.terminador,
    this.valor,
    this.atualizadoEm,
    this.operadorId,
  });

  bool get temPreco => valor != null;

  @override
  List<Object?> get props => [
    tabelaDePrecoId,
    tabelaNome,
    tabelaInativa,
    tabelaPadrao,
    terminador,
    valor,
    atualizadoEm,
    operadorId,
  ];

  @override
  bool? get stringify => true;
}
