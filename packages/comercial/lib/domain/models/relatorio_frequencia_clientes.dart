class FrequenciaVendasSemCliente {
  final double valor;
  final double percentualFaturamento;
  const FrequenciaVendasSemCliente({this.valor = 0, this.percentualFaturamento = 0});
}

class FrequenciaClasseResumo {
  final String classe;
  final int clientes;
  final double percentualClientes;
  final double valor;
  final double percentualFaturamento;
  const FrequenciaClasseResumo({
    required this.classe,
    this.clientes = 0,
    this.percentualClientes = 0,
    this.valor = 0,
    this.percentualFaturamento = 0,
  });
}

class FrequenciaCurvaPonto {
  final double percentualClientes;
  final double percentualFaturamento;
  const FrequenciaCurvaPonto({this.percentualClientes = 0, this.percentualFaturamento = 0});
}

class FrequenciaFaixaVisitas {
  /// "1", "2-3", "4-6", "7-12", "13+".
  final String faixa;
  final int a;
  final int b;
  final int c;
  const FrequenciaFaixaVisitas({required this.faixa, this.a = 0, this.b = 0, this.c = 0});
}

class FrequenciaParametros {
  final double corteA;
  final double corteB;
  final double fatorAtraso;
  final int minimoVisitasAtraso;
  const FrequenciaParametros({
    this.corteA = 80,
    this.corteB = 95,
    this.fatorAtraso = 2,
    this.minimoVisitasAtraso = 3,
  });
}

class FrequenciaClientesResumo {
  final int clientes;
  final double valorTotal;
  final double visitasPorCliente;
  final double intervaloMedioDias;
  final double ticketMedio;
  final int atrasados;
  final double percentualUmaVisita;
  final FrequenciaVendasSemCliente vendasSemCliente;
  final List<FrequenciaClasseResumo> classes;
  final List<FrequenciaCurvaPonto> curva;
  final List<FrequenciaFaixaVisitas> distribuicaoVisitas;
  final FrequenciaParametros parametros;

  const FrequenciaClientesResumo({
    this.clientes = 0,
    this.valorTotal = 0,
    this.visitasPorCliente = 0,
    this.intervaloMedioDias = 0,
    this.ticketMedio = 0,
    this.atrasados = 0,
    this.percentualUmaVisita = 0,
    this.vendasSemCliente = const FrequenciaVendasSemCliente(),
    this.classes = const [],
    this.curva = const [],
    this.distribuicaoVisitas = const [],
    this.parametros = const FrequenciaParametros(),
  });
}

class FrequenciaClienteItem {
  final int rank;
  final int clienteId;
  final String nome;

  /// Já mascarado/formatado pelo backend; não reformatar.
  final String? telefone;
  final String? documento;
  final String classe;
  final int visitas;
  final String? primeiraCompra;
  final String? ultimaCompra;
  final int diasDesdeUltima;

  /// Null com 1 visita (junto de [proximaCompraEsperada]).
  final double? intervaloMedioDias;
  final double valor;
  final double ticketMedio;
  final double percentualAcumulado;
  final bool atrasado;
  final String? proximaCompraEsperada;
  final String? categoriaPreferida;
  final String? pagamentoPreferido;

  const FrequenciaClienteItem({
    required this.rank,
    required this.clienteId,
    required this.nome,
    this.telefone,
    this.documento,
    required this.classe,
    this.visitas = 0,
    this.primeiraCompra,
    this.ultimaCompra,
    this.diasDesdeUltima = 0,
    this.intervaloMedioDias,
    this.valor = 0,
    this.ticketMedio = 0,
    this.percentualAcumulado = 0,
    this.atrasado = false,
    this.proximaCompraEsperada,
    this.categoriaPreferida,
    this.pagamentoPreferido,
  });
}

class FrequenciaClientesMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;
  const FrequenciaClientesMeta({
    this.totalItems = 0,
    this.itemCount = 0,
    this.itemsPerPage = 20,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

class RelatorioFrequenciaClientes {
  final FrequenciaClientesResumo resumo;
  final List<FrequenciaClienteItem> items;
  final FrequenciaClientesMeta meta;
  const RelatorioFrequenciaClientes({
    this.resumo = const FrequenciaClientesResumo(),
    this.items = const [],
    this.meta = const FrequenciaClientesMeta(),
  });
}
