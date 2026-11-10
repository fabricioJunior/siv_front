import 'package:core/equals.dart';

class PromocaoParaEtiqueta extends Equatable {
  final int id;
  final String nome;
  final String? tipoEscopo;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const PromocaoParaEtiqueta({
    required this.id,
    required this.nome,
    this.tipoEscopo,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [id, nome, tipoEscopo, dataInicio, dataFim];
}

class ItemEtiquetaPromocao extends Equatable {
  final int produtoId;
  final int referenciaId;
  final String referenciaNome;
  final String? corNome;
  final String? tamanhoNome;
  final String? codigoBarras;

  /// Quantidade de etiquetas a imprimir (saldo em estoque).
  final int saldo;
  final double precoTabela;
  final double? precoPromocional;

  const ItemEtiquetaPromocao({
    required this.produtoId,
    required this.referenciaId,
    required this.referenciaNome,
    required this.saldo,
    required this.precoTabela,
    this.corNome,
    this.tamanhoNome,
    this.codigoBarras,
    this.precoPromocional,
  });

  double get precoFinal => precoPromocional ?? precoTabela;

  bool get imprimivel => precoFinal > 0 && saldo > 0;

  @override
  List<Object?> get props => [
    produtoId,
    referenciaId,
    referenciaNome,
    corNome,
    tamanhoNome,
    codigoBarras,
    saldo,
    precoTabela,
    precoPromocional,
  ];
}
