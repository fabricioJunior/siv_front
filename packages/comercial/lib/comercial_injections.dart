import 'package:comercial/data.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';

void resolverComercialInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IReceberRomaneioNoCaixaRemoteDataSource>(
    () => ReceberRomaneioNoCaixaRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ICorrigirFormaDePagamentoRemoteDataSource>(
    () => CorrigirFormaDePagamentoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<ICreditoDevolucaoRemoteDataSource>(
    () => CreditoDevolucaoRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ISaldoTotalCreditoDevolucaoRemoteDataSource>(
    () =>
        SaldoTotalCreditoDevolucaoRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IPedidosRemoteDataSource>(
    () => PedidosRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IRomaneiosRemoteDataSource>(
    () => RomaneiosRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IIntegracaoFiscalRemoteDataSource>(
    () => IntegracaoFiscalRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IRelatorioRemoteDataSource>(
    () => RelatorioRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IConsignacoesRemoteDataSource>(
    () => ConsignacoesRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IFidelidadeRemoteDataSource>(
    () => FidelidadeRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositories() {
  sl.registerFactory<IPedidosRepository>(
    () => PedidosRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<ICreditoDevolucaoRepository>(
    () => CreditoDevolucaoRepository(
      remoteDataSource: sl(),
      saldoTotalRemoteDataSource: sl(),
    ),
  );

  sl.registerFactory<IRomaneiosRepository>(
    () => RomaneiosRepository(
      remoteDataSource: sl(),
      caixasRemoteDataSource: sl(),
      corrigirFormaDePagamentoRemoteDataSource: sl(),
    ),
  );

  sl.registerFactory<IIntegracaoFiscalRepository>(
    () => IntegracaoFiscalRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IRelatorioRepository>(
    () => RelatorioRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IOrcamentoRepository>(
    () => OrcamentoRepository(
      salvarListaDeProdutosCompartilhada: sl(),
      removerProdutosDaListaCompartilhada: sl(),
      recuperarListaDeProdutosCompartilhada: sl(),
      removerListaDeProdutosCompartilhada: sl(),
      leitorDataDatasource: sl<ILeitorDataDatasource>(),
    ),
  );

  sl.registerFactory<IConsignacoesRepository>(
    () => ConsignacoesRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IFidelidadeRepository>(
    () => FidelidadeRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarPedidos>(
      () => RecuperarPedidos(repository: sl()));
  sl.registerFactory<RecuperarPedido>(() => RecuperarPedido(repository: sl()));
  sl.registerFactory<CriarPedido>(() => CriarPedido(repository: sl()));
  sl.registerFactory<AtualizarPedido>(() => AtualizarPedido(repository: sl()));
  sl.registerFactory<ConferirPedido>(() => ConferirPedido(repository: sl()));
  sl.registerFactory<FaturarPedido>(() => FaturarPedido(repository: sl()));
  sl.registerFactory<CancelarPedido>(() => CancelarPedido(repository: sl()));

  sl.registerFactory<CarregarResumoPagamentosRealizados>(
    () => CarregarResumoPagamentosRealizados(recuperarLista: sl()),
  );

  sl.registerFactory<BuscarCreditoDevolucaoMovimentacoes>(
    () => BuscarCreditoDevolucaoMovimentacoes(repository: sl()),
  );

  sl.registerFactory<BuscarSaldoCreditoDevolucao>(
    () => BuscarSaldoCreditoDevolucao(repository: sl()),
  );

  sl.registerFactory<VerificarElegibilidadeFidelidade>(
    () => VerificarElegibilidadeFidelidade(repository: sl()),
  );

  sl.registerFactory<RecuperarRomaneios>(
    () => RecuperarRomaneios(repository: sl()),
  );
  sl.registerFactory<RecuperarRomaneio>(
      () => RecuperarRomaneio(repository: sl()));
  sl.registerFactory<RecuperarItensRomaneio>(
    () => RecuperarItensRomaneio(repository: sl()),
  );
  sl.registerFactory<RecuperarItensDevolvidosRomaneio>(
    () => RecuperarItensDevolvidosRomaneio(repository: sl()),
  );
  sl.registerFactory<CriarRomaneio>(() => CriarRomaneio(repository: sl()));
  sl.registerFactory<AtualizarRomaneio>(
    () => AtualizarRomaneio(repository: sl()),
  );
  sl.registerFactory<AdicionarItemRomaneio>(
    () => AdicionarItemRomaneio(repository: sl()),
  );
  sl.registerFactory<RemoverItemRomaneio>(
    () => RemoverItemRomaneio(repository: sl()),
  );
  sl.registerFactory<AtualizarObservacaoRomaneio>(
    () => AtualizarObservacaoRomaneio(repository: sl()),
  );
  sl.registerFactory<AtualizarVendedorRomaneio>(
    () => AtualizarVendedorRomaneio(repository: sl()),
  );
  sl.registerFactory<CorrigirFormaDePagamentoRomaneio>(
    () => CorrigirFormaDePagamentoRomaneio(repository: sl()),
  );

  sl.registerFactory<ReceberRomaneioNoCaixa>(
    () => ReceberRomaneioNoCaixa(repository: sl()),
  );

  sl.registerFactory<ListarDocumentosFiscais>(
    () => ListarDocumentosFiscais(repository: sl()),
  );
  sl.registerFactory<GetDocumentoFiscalDetalhe>(
    () => GetDocumentoFiscalDetalhe(sl()),
  );
  sl.registerFactory<GetConfiguracaoFiscal>(
    () => GetConfiguracaoFiscal(repository: sl()),
  );
  sl.registerFactory<SalvarConfiguracaoFiscal>(
    () => SalvarConfiguracaoFiscal(repository: sl()),
  );
  sl.registerFactory<ReprocessarDocumentoFiscal>(
    () => ReprocessarDocumentoFiscal(repository: sl()),
  );

  sl.registerFactory<GetRelatorioFaturamento>(
    () => GetRelatorioFaturamento(sl()),
  );
  sl.registerFactory<GetRelatorioCurvaAbc>(
    () => GetRelatorioCurvaAbc(sl()),
  );
  sl.registerFactory<GetRelatorioClientesAtivos>(
    () => GetRelatorioClientesAtivos(sl()),
  );
  sl.registerFactory<GetRelatorioVendasPorFuncionario>(
    () => GetRelatorioVendasPorFuncionario(sl()),
  );

  sl.registerFactory<SalvarOrcamento>(
    () => SalvarOrcamento(repository: sl()),
  );
  sl.registerFactory<ListarOrcamentos>(
    () => ListarOrcamentos(repository: sl()),
  );
  sl.registerFactory<ExcluirOrcamento>(
    () => ExcluirOrcamento(repository: sl()),
  );
  sl.registerFactory<CarregarOrcamento>(
    () => CarregarOrcamento(repository: sl()),
  );

  sl.registerFactory<AbrirConsignacao>(
    () => AbrirConsignacao(repository: sl()),
  );
  sl.registerFactory<RecuperarConsignacoes>(
    () => RecuperarConsignacoes(repository: sl()),
  );
  sl.registerFactory<RecuperarConsignacao>(
    () => RecuperarConsignacao(repository: sl()),
  );
  sl.registerFactory<AtualizarConsignacao>(
    () => AtualizarConsignacao(repository: sl()),
  );
  sl.registerFactory<RecalcularConsignacao>(
    () => RecalcularConsignacao(repository: sl()),
  );
  sl.registerFactory<FecharConsignacao>(
    () => FecharConsignacao(repository: sl()),
  );
  sl.registerFactory<CancelarConsignacao>(
    () => CancelarConsignacao(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<PedidosBloc>(
    () => PedidosBloc(
      sl(),
    ),
  );

  sl.registerFactory<PedidoBloc>(
    () => PedidoBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<RomaneiosBloc>(
    () => RomaneiosBloc(
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<VendasBloc>(
    () => VendasBloc(sl()),
  );

  sl.registerFactory<RomaneiosEntradaManualBloc>(
    () => RomaneiosEntradaManualBloc(sl()),
  );

  sl.registerFactory<RomaneioBloc>(
    () => RomaneioBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<RomaneioCriacaoBloc>(
    () => RomaneioCriacaoBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<VendaBloc>(
    () => VendaBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<OrcamentosBloc>(
    () => OrcamentosBloc(
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<PagamentosRealizadosBloc>(
    () => PagamentosRealizadosBloc(
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<DevolucaoBloc>(
    () => DevolucaoBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<ConfiguracaoFiscalBloc>(
    () => ConfiguracaoFiscalBloc(sl(), sl()),
  );

  sl.registerFactory<DocumentosFiscaisBloc>(
    () => DocumentosFiscaisBloc(sl(), sl()),
  );
  sl.registerFactory<DocumentoFiscalDetalheBloc>(
    () => DocumentoFiscalDetalheBloc(sl(), sl(), sl(), sl()),
  );

  sl.registerFactory<RelatorioFaturamentoBloc>(
    () => RelatorioFaturamentoBloc(sl()),
  );
  sl.registerFactory<RelatorioCurvaAbcBloc>(
    () => RelatorioCurvaAbcBloc(sl()),
  );
  sl.registerFactory<RelatorioClientesBloc>(
    () => RelatorioClientesBloc(sl()),
  );
  sl.registerFactory<RelatorioVendasPorFuncionarioBloc>(
    () => RelatorioVendasPorFuncionarioBloc(sl()),
  );

  sl.registerFactory<ConsignacoesBloc>(
    () => ConsignacoesBloc(sl()),
  );

  sl.registerFactory<AbrirConsignacaoBloc>(
    () => AbrirConsignacaoBloc(sl(), sl(), sl()),
  );

  sl.registerFactory<ConsignacaoDetalheBloc>(
    () => ConsignacaoDetalheBloc(sl(), sl(), sl(), sl()),
  );
}
