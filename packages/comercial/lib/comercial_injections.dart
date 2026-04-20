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

  sl.registerFactory<IPedidosRemoteDataSource>(
    () => PedidosRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IRomaneiosRemoteDataSource>(
    () => RomaneiosRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositories() {
  sl.registerFactory<IPedidosRepository>(
    () => PedidosRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IRomaneiosRepository>(
    () => RomaneiosRepository(
      remoteDataSource: sl(),
      caixasRemoteDataSource: sl(),
    ),
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
}
