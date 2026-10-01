import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/sync.dart';
import 'package:importacao/data/remote/importacao_remote_data_source.dart';
import 'package:importacao/domain/data/remote/i_importacao_remote_data_source.dart';
import 'package:importacao/presentation.dart';

void resolverImportacaoInjection() {
  sl.registerFactory<IImportacaoRemoteDataSource>(
    () => ImportacaoRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory<ImportacaoGuiadaBloc>(
    () => ImportacaoGuiadaBloc(
      sl(),
      sl<ArquivoService>(),
      sl<SyncWebSocketService>().importacoes,
    ),
  );
}
