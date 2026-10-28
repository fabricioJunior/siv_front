import 'package:core/equals.dart';

/// Status de entrada da referência, calculados pela API (nunca editados no app).
class ReferenciaStatusEntrada extends Equatable {
  /// Sem nenhuma variação (produto) cadastrada.
  final bool nova;

  /// Sem saldo em nenhuma loja e sem entrada faturada com a referência.
  final bool aguardandoPrimeiraEntrada;

  /// Marcação manual: já foi recebida e voltará a chegar.
  final bool aguardandoReposicao;

  const ReferenciaStatusEntrada({
    this.nova = false,
    this.aguardandoPrimeiraEntrada = false,
    this.aguardandoReposicao = false,
  });

  factory ReferenciaStatusEntrada.fromJson(Map<String, dynamic> json) =>
      ReferenciaStatusEntrada(
        nova: json['nova'] == true,
        aguardandoPrimeiraEntrada: json['aguardandoPrimeiraEntrada'] == true,
        aguardandoReposicao: json['aguardandoReposicao'] == true,
      );

  /// Esperada = a referência que ainda vai chegar (1ª entrada ou reposição).
  bool get esperada => aguardandoPrimeiraEntrada || aguardandoReposicao;

  bool get semStatus => !nova && !esperada;

  @override
  List<Object?> get props => [nova, aguardandoPrimeiraEntrada, aguardandoReposicao];
}
