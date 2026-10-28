import 'package:core/equals.dart';

/// Dados de "referência esperada" enviados junto do cadastro/atualização da referência.
///
/// Fornecedor, previsão e quantidade vão sempre (nulo limpa o valor na API);
/// `aguardandoReposicao` só vai quando informado (a coluna não aceita nulo).
class EsperaReferencia extends Equatable {
  final int? fornecedorId;
  final bool? aguardandoReposicao;
  final DateTime? previsaoChegada;
  final int? quantidadeEsperada;

  const EsperaReferencia({
    this.fornecedorId,
    this.aguardandoReposicao,
    this.previsaoChegada,
    this.quantidadeEsperada,
  });

  Map<String, dynamic> toJson() => {
    'fornecedorId': fornecedorId,
    if (aguardandoReposicao != null) 'aguardandoReposicao': aguardandoReposicao,
    'previsaoChegada': previsaoChegada?.toIso8601String().substring(0, 10),
    'quantidadeEsperada': quantidadeEsperada,
  };

  @override
  List<Object?> get props => [
    fornecedorId,
    aguardandoReposicao,
    previsaoChegada,
    quantidadeEsperada,
  ];
}
