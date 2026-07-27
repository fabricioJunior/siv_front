import 'package:core/equals.dart';

import 'imagem_da_referencia.dart';
import 'produto_da_grade.dart';

class GradeDaReferencia extends Equatable {
  final int referenciaId;
  final String? referenciaIdExterno;
  final String nome;
  final String? unidadeMedida;
  final int? tabelaDePrecoId;
  final double? valor;
  final int totalEmEstoque;
  final ImagemDaReferencia? imagem;
  final List<ProdutoDaGrade> produtos;

  const GradeDaReferencia({
    required this.referenciaId,
    this.referenciaIdExterno,
    required this.nome,
    this.unidadeMedida,
    this.tabelaDePrecoId,
    this.valor,
    required this.totalEmEstoque,
    this.imagem,
    required this.produtos,
  });

  @override
  List<Object?> get props => [
    referenciaId,
    referenciaIdExterno,
    nome,
    unidadeMedida,
    tabelaDePrecoId,
    valor,
    totalEmEstoque,
    imagem,
    produtos,
  ];

  @override
  bool? get stringify => true;
}
