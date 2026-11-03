import 'package:comercial/domain/models/variacao_opcao.dart';

/// Porta para cores, estampas e tamanhos de produtos. A implementação fica em
/// `lib/` (composition root), que enxerga o package produtos.
abstract class IVariacoesProdutoGateway {
  Future<List<VariacaoOpcao>> cores();
  Future<List<VariacaoOpcao>> estampas();
  Future<List<TamanhoOpcao>> tamanhos();
  Future<VariacaoOpcao> criarCor(String nome);
  Future<VariacaoOpcao> criarEstampa(String nome);
}
