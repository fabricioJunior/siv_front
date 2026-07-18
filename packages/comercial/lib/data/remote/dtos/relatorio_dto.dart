import 'package:comercial/domain/models/relatorios.dart';

class RelatorioFaturamentoVendedorDto implements RelatorioFaturamentoVendedor {
  @override final int funcionarioId;
  @override final String funcionarioNome;
  @override final double total;
  @override final int quantidadeProdutosVendidos;
  @override final int quantidadeVendas;
  @override final double ticketMedio;

  const RelatorioFaturamentoVendedorDto({
    required this.funcionarioId,
    required this.funcionarioNome,
    required this.total,
    required this.quantidadeProdutosVendidos,
    required this.quantidadeVendas,
    required this.ticketMedio,
  });

  factory RelatorioFaturamentoVendedorDto.fromJson(Map<String, dynamic> j) =>
      RelatorioFaturamentoVendedorDto(
        funcionarioId: (j['funcionarioId'] as num).toInt(),
        funcionarioNome: j['funcionarioNome'] as String? ?? '',
        total: (j['total'] as num).toDouble(),
        quantidadeProdutosVendidos:
            (j['quantidadeProdutosVendidos'] as num).toInt(),
        quantidadeVendas: (j['quantidadeVendas'] as num).toInt(),
        ticketMedio: (j['ticketMedio'] as num).toDouble(),
      );
}

class RelatorioFaturamentoProdutoDto implements RelatorioFaturamentoProduto {
  @override final int produtoId;
  @override final String produtoIdExterno;
  @override final int referenciaId;
  @override final String referenciaIdExterno;
  @override final String referenciaNome;
  @override final int corId;
  @override final String corNome;
  @override final int tamanhoId;
  @override final String tamanhoNome;
  @override final double total;
  @override final int quantidadeProdutosVendidos;

  const RelatorioFaturamentoProdutoDto({
    required this.produtoId,
    required this.produtoIdExterno,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.total,
    required this.quantidadeProdutosVendidos,
  });

  factory RelatorioFaturamentoProdutoDto.fromJson(Map<String, dynamic> j) =>
      RelatorioFaturamentoProdutoDto(
        produtoId: (j['produtoId'] as num).toInt(),
        produtoIdExterno: j['produtoIdExterno'] as String? ?? '',
        referenciaId: (j['referenciaId'] as num).toInt(),
        referenciaIdExterno: j['referenciaIdExterno'] as String? ?? '',
        referenciaNome: j['referenciaNome'] as String? ?? '',
        corId: (j['corId'] as num).toInt(),
        corNome: j['corNome'] as String? ?? '',
        tamanhoId: (j['tamanhoId'] as num).toInt(),
        tamanhoNome: j['tamanhoNome'] as String? ?? '',
        total: (j['total'] as num).toDouble(),
        quantidadeProdutosVendidos:
            (j['quantidadeProdutosVendidos'] as num).toInt(),
      );
}

class RelatorioFaturamentoEmpresaDto implements RelatorioFaturamentoEmpresa {
  @override final int empresaId;
  @override final String empresaNome;
  @override final double total;
  @override final int quantidadeProdutosVendidos;
  @override final int quantidadeVendas;
  @override final double ticketMedio;
  @override final List<RelatorioFaturamentoVendedor> vendedores;
  @override final List<RelatorioFaturamentoProduto> produtos;

  const RelatorioFaturamentoEmpresaDto({
    required this.empresaId,
    required this.empresaNome,
    required this.total,
    required this.quantidadeProdutosVendidos,
    required this.quantidadeVendas,
    required this.ticketMedio,
    required this.vendedores,
    required this.produtos,
  });

  factory RelatorioFaturamentoEmpresaDto.fromJson(Map<String, dynamic> j) =>
      RelatorioFaturamentoEmpresaDto(
        empresaId: (j['empresaId'] as num).toInt(),
        empresaNome: j['empresaNome'] as String? ?? '',
        total: (j['total'] as num).toDouble(),
        quantidadeProdutosVendidos:
            (j['quantidadeProdutosVendidos'] as num).toInt(),
        quantidadeVendas: (j['quantidadeVendas'] as num).toInt(),
        ticketMedio: (j['ticketMedio'] as num).toDouble(),
        vendedores: (j['vendedores'] as List<dynamic>? ?? [])
            .map((e) => RelatorioFaturamentoVendedorDto.fromJson(
                e as Map<String, dynamic>))
            .toList(),
        produtos: (j['produtos'] as List<dynamic>? ?? [])
            .map((e) => RelatorioFaturamentoProdutoDto.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

class RelatorioFaturamentoDto implements RelatorioFaturamento {
  @override final double total;
  @override final int quantidadeProdutosVendidos;
  @override final int quantidadeVendas;
  @override final double ticketMedio;
  @override final List<RelatorioFaturamentoEmpresa> empresas;

  const RelatorioFaturamentoDto({
    required this.total,
    required this.quantidadeProdutosVendidos,
    required this.quantidadeVendas,
    required this.ticketMedio,
    required this.empresas,
  });

  factory RelatorioFaturamentoDto.fromJson(Map<String, dynamic> j) =>
      RelatorioFaturamentoDto(
        total: (j['total'] as num).toDouble(),
        quantidadeProdutosVendidos:
            (j['quantidadeProdutosVendidos'] as num).toInt(),
        quantidadeVendas: (j['quantidadeVendas'] as num).toInt(),
        ticketMedio: (j['ticketMedio'] as num).toDouble(),
        empresas: (j['empresas'] as List<dynamic>? ?? [])
            .map((e) => RelatorioFaturamentoEmpresaDto.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

class RelatorioFaturamentoComparativoPontoDto
    implements RelatorioFaturamentoComparativoPonto {
  @override final String periodo;
  @override final double faturamento;
  @override final int quantidadeVendas;

  const RelatorioFaturamentoComparativoPontoDto({
    required this.periodo,
    required this.faturamento,
    required this.quantidadeVendas,
  });

  factory RelatorioFaturamentoComparativoPontoDto.fromJson(
          Map<String, dynamic> j) =>
      RelatorioFaturamentoComparativoPontoDto(
        periodo: j['periodo'] as String? ?? '',
        faturamento: (j['faturamento'] as num).toDouble(),
        quantidadeVendas: (j['quantidadeVendas'] as num).toInt(),
      );
}

class RelatorioFaturamentoComparativoDto
    implements RelatorioFaturamentoComparativo {
  @override final List<RelatorioFaturamentoComparativoPonto> pontos;

  const RelatorioFaturamentoComparativoDto({required this.pontos});

  factory RelatorioFaturamentoComparativoDto.fromJson(
          Map<String, dynamic> j) =>
      RelatorioFaturamentoComparativoDto(
        pontos: (j['pontos'] as List<dynamic>? ?? [])
            .map((e) => RelatorioFaturamentoComparativoPontoDto.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

class RelatorioVendasPorFuncionarioItemDto
    implements RelatorioVendasPorFuncionarioItem {
  @override final int funcionarioId;
  @override final String funcionarioNome;
  @override final double total;
  @override final int quantidadeProdutosVendidos;
  @override final int quantidadeVendas;
  @override final double ticketMedio;

  const RelatorioVendasPorFuncionarioItemDto({
    required this.funcionarioId,
    required this.funcionarioNome,
    required this.total,
    required this.quantidadeProdutosVendidos,
    required this.quantidadeVendas,
    required this.ticketMedio,
  });

  factory RelatorioVendasPorFuncionarioItemDto.fromJson(
          Map<String, dynamic> j) =>
      RelatorioVendasPorFuncionarioItemDto(
        funcionarioId: (j['funcionarioId'] as num).toInt(),
        funcionarioNome: j['funcionarioNome'] as String? ?? '',
        total: (j['total'] as num).toDouble(),
        quantidadeProdutosVendidos:
            (j['quantidadeProdutosVendidos'] as num).toInt(),
        quantidadeVendas: (j['quantidadeVendas'] as num).toInt(),
        ticketMedio: (j['ticketMedio'] as num).toDouble(),
      );

  static List<RelatorioVendasPorFuncionarioItem> listFromJson(
          Map<String, dynamic> j) =>
      (j['funcionarios'] as List<dynamic>? ?? [])
          .map((e) => RelatorioVendasPorFuncionarioItemDto.fromJson(
              e as Map<String, dynamic>))
          .toList();
}

class RelatorioCurvaAbcItemDto implements RelatorioCurvaAbcItem {
  @override final int? produtoId;
  @override final String? produtoIdExterno;
  @override final int? referenciaId;
  @override final String? referenciaIdExterno;
  @override final String? referenciaNome;
  @override final int? corId;
  @override final String? corNome;
  @override final int? tamanhoId;
  @override final String? tamanhoNome;
  @override final int? categoriaId;
  @override final String? categoriaNome;
  @override final int quantidadeVendida;
  @override final double valorTotalVendido;
  @override final double percentualParticipacao;
  @override final double percentualAcumulado;
  @override final String classeAbc;

  const RelatorioCurvaAbcItemDto({
    this.produtoId,
    this.produtoIdExterno,
    this.referenciaId,
    this.referenciaIdExterno,
    this.referenciaNome,
    this.corId,
    this.corNome,
    this.tamanhoId,
    this.tamanhoNome,
    this.categoriaId,
    this.categoriaNome,
    required this.quantidadeVendida,
    required this.valorTotalVendido,
    required this.percentualParticipacao,
    required this.percentualAcumulado,
    required this.classeAbc,
  });

  factory RelatorioCurvaAbcItemDto.fromJson(Map<String, dynamic> j) =>
      RelatorioCurvaAbcItemDto(
        produtoId: (j['produtoId'] as num?)?.toInt(),
        produtoIdExterno: j['produtoIdExterno'] as String?,
        referenciaId: (j['referenciaId'] as num?)?.toInt(),
        referenciaIdExterno: j['referenciaIdExterno'] as String?,
        referenciaNome: j['referenciaNome'] as String?,
        corId: (j['corId'] as num?)?.toInt(),
        corNome: j['corNome'] as String?,
        tamanhoId: (j['tamanhoId'] as num?)?.toInt(),
        tamanhoNome: j['tamanhoNome'] as String?,
        categoriaId: (j['categoriaId'] as num?)?.toInt(),
        categoriaNome: j['categoriaNome'] as String?,
        quantidadeVendida: (j['quantidadeVendida'] as num).toInt(),
        valorTotalVendido: (j['valorTotalVendido'] as num).toDouble(),
        percentualParticipacao:
            (j['percentualParticipacao'] as num).toDouble(),
        percentualAcumulado: (j['percentualAcumulado'] as num).toDouble(),
        classeAbc: j['classeAbc'] as String? ?? 'C',
      );
}

class RelatorioCurvaAbcMetaDto implements RelatorioCurvaAbcMeta {
  @override final int totalItems;
  @override final int itemCount;
  @override final int itemsPerPage;
  @override final int totalPages;
  @override final int currentPage;

  const RelatorioCurvaAbcMetaDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory RelatorioCurvaAbcMetaDto.fromJson(Map<String, dynamic> j) =>
      RelatorioCurvaAbcMetaDto(
        totalItems: (j['totalItems'] as num).toInt(),
        itemCount: (j['itemCount'] as num).toInt(),
        itemsPerPage: (j['itemsPerPage'] as num).toInt(),
        totalPages: (j['totalPages'] as num).toInt(),
        currentPage: (j['currentPage'] as num).toInt(),
      );
}

class RelatorioCurvaAbcDto implements RelatorioCurvaAbc {
  @override final List<RelatorioCurvaAbcItem> items;
  @override final RelatorioCurvaAbcMeta meta;

  const RelatorioCurvaAbcDto({required this.items, required this.meta});

  factory RelatorioCurvaAbcDto.fromJson(Map<String, dynamic> j) =>
      RelatorioCurvaAbcDto(
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) =>
                RelatorioCurvaAbcItemDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: RelatorioCurvaAbcMetaDto.fromJson(
            j['meta'] as Map<String, dynamic>),
      );
}

class RelatorioClienteAtivoItemDto implements RelatorioClienteAtivoItem {
  @override final int empresaId;
  @override final String empresaNome;
  @override final int clienteId;
  @override final String clienteNome;
  @override final String clienteDocumento;
  @override final String dataUltimaCompra;
  @override final int quantidadeCompras;
  @override final double valorTotalComprado;

  const RelatorioClienteAtivoItemDto({
    required this.empresaId,
    required this.empresaNome,
    required this.clienteId,
    required this.clienteNome,
    required this.clienteDocumento,
    required this.dataUltimaCompra,
    required this.quantidadeCompras,
    required this.valorTotalComprado,
  });

  factory RelatorioClienteAtivoItemDto.fromJson(Map<String, dynamic> j) =>
      RelatorioClienteAtivoItemDto(
        empresaId: (j['empresaId'] as num).toInt(),
        empresaNome: j['empresaNome'] as String? ?? '',
        clienteId: (j['clienteId'] as num).toInt(),
        clienteNome: j['clienteNome'] as String? ?? '',
        clienteDocumento: j['clienteDocumento'] as String? ?? '',
        dataUltimaCompra: j['dataUltimaCompra'] as String? ?? '',
        quantidadeCompras: (j['quantidadeCompras'] as num).toInt(),
        valorTotalComprado: (j['valorTotalComprado'] as num).toDouble(),
      );
}

class RelatorioClienteAtivoMetaDto implements RelatorioClienteAtivoMeta {
  @override final int totalItems;
  @override final int itemCount;
  @override final int itemsPerPage;
  @override final int totalPages;
  @override final int currentPage;

  const RelatorioClienteAtivoMetaDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory RelatorioClienteAtivoMetaDto.fromJson(Map<String, dynamic> j) =>
      RelatorioClienteAtivoMetaDto(
        totalItems: (j['totalItems'] as num).toInt(),
        itemCount: (j['itemCount'] as num).toInt(),
        itemsPerPage: (j['itemsPerPage'] as num).toInt(),
        totalPages: (j['totalPages'] as num).toInt(),
        currentPage: (j['currentPage'] as num).toInt(),
      );
}

class RelatorioClientesAtivosDto implements RelatorioClientesAtivos {
  @override final List<RelatorioClienteAtivoItem> items;
  @override final RelatorioClienteAtivoMeta meta;

  const RelatorioClientesAtivosDto({required this.items, required this.meta});

  factory RelatorioClientesAtivosDto.fromJson(Map<String, dynamic> j) =>
      RelatorioClientesAtivosDto(
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => RelatorioClienteAtivoItemDto.fromJson(
                e as Map<String, dynamic>))
            .toList(),
        meta: RelatorioClienteAtivoMetaDto.fromJson(
            j['meta'] as Map<String, dynamic>),
      );
}
