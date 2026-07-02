import 'package:comercial/data.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';

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
    ),
  );

  sl.registerFactory<IIntegracaoFiscalRepository>(
    () => IntegracaoFiscalRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IRelatorioRepository>(
    () => RelatorioRepository(remoteDataSource: sl()),
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

  sl.registerFactory<RecuperarRomaneios>(
    () => RecuperarRomaneios(repository: sl()),
  );
  sl.registerFactory<RecuperarRomaneio>(
      () => RecuperarRomaneio(repository: sl()));
  sl.registerFactory<RecuperarItensRomaneio>(
    () => RecuperarItensRomaneio(repository: sl()),
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
    ),
  );

  sl.registerFactory<VendaBloc>(
    () => VendaBloc(
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<PagamentosRealizadosBloc>(
    () => PagamentosRealizadosBloc(
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
    ),
  );

  sl.registerFactory<ConfiguracaoFiscalBloc>(
    () => ConfiguracaoFiscalBloc(sl(), sl()),
  );

  sl.registerFactory<DocumentosFiscaisBloc>(
    () => DocumentosFiscaisBloc(sl(), sl()),
  );
  sl.registerFactory<DocumentoFiscalDetalheBloc>(
    () => DocumentoFiscalDetalheBloc(sl()),
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
}
