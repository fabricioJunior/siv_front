import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';

class PagamentosRealizadosResumo extends Equatable {
  final ListaDeProdutosCompartilhada? listaCompartilhada;
  final List<ProdutoCompartilhado> produtosCompartilhados;
  final int quantidadeTotalProdutos;
  final double valorTotalProdutos;

  const PagamentosRealizadosResumo({
    required this.listaCompartilhada,
    required this.produtosCompartilhados,
    required this.quantidadeTotalProdutos,
    required this.valorTotalProdutos,
  });

  @override
  List<Object?> get props => [
        listaCompartilhada,
        produtosCompartilhados,
        quantidadeTotalProdutos,
        valorTotalProdutos,
      ];
}