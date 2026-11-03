import 'package:comercial/domain/data/gateways/i_variacoes_produto_gateway.dart';
import 'package:comercial/domain/models/variacao_opcao.dart';
import 'package:core/seletores.dart' show normalizarBusca;

/// Leitura memorizada: erro não fica em cache.
class _Memo<T> {
  Future<T>? _f;

  Future<T> ler(Future<T> Function() carregar) {
    final f = _f ??= Future.sync(carregar);
    f.then<void>((_) {}, onError: (_) {
      if (identical(_f, f)) _f = null;
    });
    return f;
  }

  void definir(T valor) => _f = Future.value(valor);
}

List<VariacaoOpcao> _az(List<VariacaoOpcao> l) => [...l]..sort(
    (a, b) => normalizarBusca(a.nome).compareTo(normalizarBusca(b.nome)));

class RecuperarCoresDeProdutos {
  final IVariacoesProdutoGateway _gateway;
  final _memo = _Memo<List<VariacaoOpcao>>();
  RecuperarCoresDeProdutos(this._gateway);

  Future<List<VariacaoOpcao>> call() =>
      _memo.ler(() async => _az(await _gateway.cores()));

  Future<void> adicionar(VariacaoOpcao nova) async =>
      _memo.definir(_az([...await call(), nova]));
}

class RecuperarEstampasDeProdutos {
  final IVariacoesProdutoGateway _gateway;
  final _memo = _Memo<List<VariacaoOpcao>>();
  RecuperarEstampasDeProdutos(this._gateway);

  Future<List<VariacaoOpcao>> call() =>
      _memo.ler(() async => _az(await _gateway.estampas()));

  Future<void> adicionar(VariacaoOpcao nova) async =>
      _memo.definir(_az([...await call(), nova]));
}

class RecuperarTamanhosDeProdutos {
  final IVariacoesProdutoGateway _gateway;
  final _memo = _Memo<List<TamanhoOpcao>>();
  RecuperarTamanhosDeProdutos(this._gateway);

  Future<List<TamanhoOpcao>> call() => _memo.ler(_gateway.tamanhos);
}

class CriarCorDeProdutos {
  final IVariacoesProdutoGateway _gateway;
  final RecuperarCoresDeProdutos _lista;
  CriarCorDeProdutos(this._gateway, this._lista);

  Future<VariacaoOpcao> call(String nome) async {
    final nova = await _gateway.criarCor(nome);
    await _lista.adicionar(nova);
    return nova;
  }
}

class CriarEstampaDeProdutos {
  final IVariacoesProdutoGateway _gateway;
  final RecuperarEstampasDeProdutos _lista;
  CriarEstampaDeProdutos(this._gateway, this._lista);

  Future<VariacaoOpcao> call(String nome) async {
    final nova = await _gateway.criarEstampa(nome);
    await _lista.adicionar(nova);
    return nova;
  }
}
