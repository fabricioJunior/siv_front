import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:core/produtos_compartilhados.dart';

class CarregarResumoPagamentosRealizados {
  final RecuperarListaDeProdutosCompartilhada _recuperarLista;

  CarregarResumoPagamentosRealizados({
    required RecuperarListaDeProdutosCompartilhada recuperarLista,
  }) : _recuperarLista = recuperarLista;

  Future<PagamentosRealizadosResumo> call(String hashLista) async {
    final listaCompartilhada = await _recuperarLista.call(hashLista);
    final produtosCompartilhados =
        await _recuperarLista.recuperarProdutos(hashLista);

    final quantidadeTotalProdutos = produtosCompartilhados.fold<int>(
      0,
      (acumulado, produto) => acumulado + produto.quantidade,
    );

    final valorTotalProdutos = produtosCompartilhados.fold<double>(
      0,
      (acumulado, produto) =>
          acumulado + (produto.quantidade * produto.valorUnitario),
    );

    return PagamentosRealizadosResumo(
      listaCompartilhada: listaCompartilhada,
      produtosCompartilhados: produtosCompartilhados,
      quantidadeTotalProdutos: quantidadeTotalProdutos,
      valorTotalProdutos: valorTotalProdutos,
    );
  }
}