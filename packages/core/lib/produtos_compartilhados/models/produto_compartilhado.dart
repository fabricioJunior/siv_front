import 'package:core/equals.dart';
import 'package:uuid/uuid.dart';

class ProdutoCompartilhado extends Equatable {
  final String hash;
  final int produtoId;
  final String hashLista;
  final int quantidade;
  final double valorUnitario;
  final String nome;
  final String corNome;
  final String tamanhoNome;

  const ProdutoCompartilhado({
    required this.produtoId,
    required this.hashLista,
    required this.quantidade,
    required this.valorUnitario,
    required this.nome,
    required this.corNome,
    required this.tamanhoNome,
    required this.hash,
  });

  ProdutoCompartilhado copyWith({
    int? produtoId,
    String? hashLista,
    int? quantidade,
    double? valorUnitario,
    String? nome,
    String? corNome,
    String? tamanhoNome,
  }) {
    return ProdutoCompartilhado(
      hash: hash,
      produtoId: produtoId ?? this.produtoId,
      hashLista: hashLista ?? this.hashLista,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      nome: nome ?? this.nome,
      corNome: corNome ?? this.corNome,
      tamanhoNome: tamanhoNome ?? this.tamanhoNome,
    );
  }

  factory ProdutoCompartilhado.create({
    required int produtoId,
    required int quantidade,
    required double valorUnitario,
    required String nome,
    required String corNome,
    required String tamanhoNome,
    String? hashLista,
  }) {
    return ProdutoCompartilhado(
      hash: const Uuid().v4(),
      produtoId: produtoId,
      hashLista: hashLista ?? '',
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      nome: nome,
      corNome: corNome,
      tamanhoNome: tamanhoNome,
    );
  }

  @override
  List<Object?> get props => [
        produtoId,
        hashLista,
        quantidade,
        valorUnitario,
        nome,
        corNome,
        tamanhoNome,
      ];
}
