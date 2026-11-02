import 'package:comercial/data.dart';
import 'package:comercial/models.dart';
import 'package:core/injecoes.dart';
import 'package:produtos/use_cases.dart'
    show
        CriarCor,
        CriarEstampa,
        RecuperarCores,
        RecuperarEstampas,
        RecuperarTamanhos;

/// Ponte comercial -> produtos: o comercial declara a porta, o app (único que
/// enxerga os dois packages) implementa chamando os use cases de produtos.
class VariacoesProdutoGateway implements IVariacoesProdutoGateway {
  @override
  Future<List<VariacaoOpcao>> cores() async =>
      (await sl<RecuperarCores>().call(inativo: false))
          .where((c) => c.id != null)
          .map((c) => VariacaoOpcao(id: c.id!, nome: c.nome))
          .toList();

  @override
  Future<List<VariacaoOpcao>> estampas() async =>
      (await sl<RecuperarEstampas>().call(inativo: false))
          .where((e) => e.id != null)
          .map((e) => VariacaoOpcao(id: e.id!, nome: e.nome))
          .toList();

  @override
  Future<List<TamanhoOpcao>> tamanhos() async =>
      (await sl<RecuperarTamanhos>().call(inativo: false))
          .where((t) => t.id != null)
          .map((t) => TamanhoOpcao(id: t.id!, nome: t.nome))
          .toList();

  @override
  Future<VariacaoOpcao> criarCor(String nome) async {
    final c = await sl<CriarCor>().call(nome);
    return VariacaoOpcao(id: c.id!, nome: c.nome);
  }

  @override
  Future<VariacaoOpcao> criarEstampa(String nome) async {
    final e = await sl<CriarEstampa>().call(nome);
    return VariacaoOpcao(id: e.id!, nome: e.nome);
  }
}
