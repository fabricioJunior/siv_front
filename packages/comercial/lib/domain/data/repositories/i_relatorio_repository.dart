import 'package:comercial/domain/models/relatorios.dart';

abstract class IRelatorioRepository {
  Future<RelatorioFaturamento> faturamento({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  });

  Future<RelatorioFaturamentoComparativo> faturamentoComparativo({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    required String agruparPor,
  });

  Future<RelatorioCurvaAbc> curvaAbc({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String? busca,
    int page = 1,
    int limit = 100,
    String agruparPor = 'produto',
    List<int>? referenciaIds,
    List<int>? categoriaIds,
  });

  Future<RelatorioClientesAtivos> clientesAtivos({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  });

  Future<RelatorioComprasClientes> comprasClientes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String agruparPor = 'produto',
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    int page = 1,
    int limit = 100,
  });

  Future<List<RelatorioVendasPorFuncionarioItem>> vendasPorFuncionario({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  });

  Future<RelatorioPontosFidelidade> pontosFidelidade({
    required List<int> empresaIds,
    String? situacaoCadastro,
    int page = 1,
    int limit = 100,
  });

  Future<RelatorioClientesAniversariantes> clientesAniversariantes({
    required List<int> empresaIds,
    int? mes,
    String? dataUltimaCompraInicial,
    String? dataUltimaCompraFinal,
    int page = 1,
    int limit = 100,
  });

  Future<RelatorioClienteCompras> comprasDoCliente({
    required List<int> empresaIds,
    required int pessoaId,
    int limit = 10,
  });
}
