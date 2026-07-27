import 'package:core/equals.dart';

class ProdutoDaGrade extends Equatable {
  final int produtoId;
  final String? produtoIdExterno;
  final int corId;
  final String corNome;
  final int tamanhoId;
  final String tamanhoNome;
  final List<String> codigosBarras;
  final int saldo;

  const ProdutoDaGrade({
    required this.produtoId,
    this.produtoIdExterno,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.codigosBarras,
    required this.saldo,
  });

  @override
  List<Object?> get props => [
    produtoId,
    produtoIdExterno,
    corId,
    corNome,
    tamanhoId,
    tamanhoNome,
    codigosBarras,
    saldo,
  ];

  @override
  bool? get stringify => true;
}
