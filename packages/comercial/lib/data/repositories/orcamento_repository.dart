import 'package:comercial/domain/data/repositories/i_orcamento_repository.dart';
import 'package:comercial/domain/models/orcamento_local.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/produtos_compartilhados.dart';

class OrcamentoRepository implements IOrcamentoRepository {
  final SalvarListaDeProdutosCompartilhada salvarListaDeProdutosCompartilhada;
  final RemoverProdutosDaListaCompartilhada
      removerProdutosDaListaCompartilhada;
  final RecuperarListaDeProdutosCompartilhada
      recuperarListaDeProdutosCompartilhada;
  final RemoverListaDeProdutosCompartilhada
      removerListaDeProdutosCompartilhada;
  final ILeitorDataDatasource leitorDataDatasource;

  OrcamentoRepository({
    required this.salvarListaDeProdutosCompartilhada,
    required this.removerProdutosDaListaCompartilhada,
    required this.recuperarListaDeProdutosCompartilhada,
    required this.removerListaDeProdutosCompartilhada,
    required this.leitorDataDatasource,
  });

  @override
  Future<OrcamentoLocal> salvar(OrcamentoLocal orcamento) async {
    await removerProdutosDaListaCompartilhada(orcamento.hash);

    final lista = ListaDeProdutosCompartilhada(
      hash: orcamento.hash,
      origem: OrigemCompartilhadaTipo.orcamento,
      criadaEm: orcamento.criadoEm,
      atualizadaEm: DateTime.now(),
      pessoaId: orcamento.clienteId,
      funcionarioId: orcamento.funcionarioId,
      tabelaPrecoId: orcamento.tabelaPrecoId,
      clienteNome: orcamento.clienteNome,
      funcionarioNome: orcamento.funcionarioNome,
      tabelaPrecoNome: orcamento.tabelaPrecoNome,
    );

    await salvarListaDeProdutosCompartilhada(
      listaCompartilhada: lista,
      produtos: orcamento.itens,
    );

    return orcamento;
  }

  @override
  Future<List<OrcamentoLocal>> listar() async {
    final listas =
        await recuperarListaDeProdutosCompartilhada.recuperarListas(
      origem: OrigemCompartilhadaTipo.orcamento,
    );

    final orcamentos = <OrcamentoLocal>[];
    for (final lista in listas) {
      final itens = await recuperarListaDeProdutosCompartilhada
          .recuperarProdutos(lista.hash);
      orcamentos.add(_paraOrcamento(lista, itens));
    }

    orcamentos.sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
    return orcamentos;
  }

  @override
  Future<OrcamentoLocal?> recuperar(String hash) async {
    final lista = await recuperarListaDeProdutosCompartilhada(hash);
    if (lista == null) return null;

    final itens =
        await recuperarListaDeProdutosCompartilhada.recuperarProdutos(hash);
    return _paraOrcamento(lista, itens);
  }

  @override
  Future<void> excluir(String hash) {
    return removerListaDeProdutosCompartilhada(hash);
  }

  @override
  Future<int?> obterEstoqueDisponivel({
    required int produtoId,
    int? tabelaPrecoId,
  }) async {
    final dado = await leitorDataDatasource.getDataPorProdutoId(
      produtoId,
      tabelaDePrecoId: tabelaPrecoId,
    );
    return dado?.quantidade;
  }

  OrcamentoLocal _paraOrcamento(
    ListaDeProdutosCompartilhada lista,
    List<ProdutoCompartilhado> itens,
  ) {
    return OrcamentoLocal(
      hash: lista.hash,
      criadoEm: lista.criadaEm,
      atualizadoEm: lista.atualizadaEm,
      clienteId: lista.pessoaId,
      clienteNome: lista.clienteNome,
      funcionarioId: lista.funcionarioId,
      funcionarioNome: lista.funcionarioNome,
      tabelaPrecoId: lista.tabelaPrecoId,
      tabelaPrecoNome: lista.tabelaPrecoNome,
      itens: itens,
    );
  }
}
