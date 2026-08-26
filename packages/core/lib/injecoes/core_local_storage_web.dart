import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_local_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:core/produtos_compartilhados/local/dtos/lista_de_produtos_compartilhada_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/produto_compartilhado_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/lista_de_produtos_compartilhada_hive_data_source.dart';
import 'package:core/produtos_compartilhados/local/produtos_compartilhados_hive_data_source.dart';
import 'package:hive_ce/hive.dart';

void registerCoreLocalStorage() {
  sl.registerLazySingleton<IHiveDatabaseInstance>(() => HiveDatabaseInstance());
  sl.registerLazySingleton<ILocalDatabaseInstance>(
    () => sl<IHiveDatabaseInstance>(),
  );

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaLocalDataSource>(
    () => ListaDeProdutosCompartilhadaHiveDataSource(
      getBox: _getListaDeProdutosCompartilhadaBox,
    ),
  );

  sl.registerLazySingleton<IProdutosCompartilhadosLocalDataSource>(
    () => ProdutosCompartilhadosHiveDataSource(
      getBox: _getProdutosCompartilhadosBox,
    ),
  );

  // ponytail: sem persistência de progresso de sync incremental no web ainda
  // (perde o cursor ao recarregar a página, refaz do zero) -- upgrade pra
  // Hive quando sync incremental precisar sobreviver a reload no navegador.
  sl.registerLazySingleton<IPaginacaoDataSource>(() => _InMemoryPaginacaoDataSource());
}

Future<Box<ProdutoCompartilhadoHiveDto>> _getProdutosCompartilhadosBox() {
  return sl<IHiveDatabaseInstance>().getBox<ProdutoCompartilhadoHiveDto>(
    boxKey: 'ProdutoCompartilhadoHiveDto',
    adapters: [
      StorageEntityAdapter<ProdutoCompartilhadoHiveDto>(
        ProdutoCompartilhadoHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'core',
  );
}

Future<Box<ListaDeProdutosCompartilhadaHiveDto>>
    _getListaDeProdutosCompartilhadaBox() {
  return sl<IHiveDatabaseInstance>()
      .getBox<ListaDeProdutosCompartilhadaHiveDto>(
    boxKey: 'ListaDeProdutosCompartilhadaHiveDto',
    adapters: [
      StorageEntityAdapter<ListaDeProdutosCompartilhadaHiveDto>(
        ListaDeProdutosCompartilhadaHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'core',
  );
}

class _InMemoryPaginacaoDataSource implements IPaginacaoDataSource {
  final Map<String, Paginacao> _paginacoes = {};

  @override
  Future<Paginacao?> buscarPaginacao(String key) async => _paginacoes[key];

  @override
  Future<void> salvarPaginacao(Paginacao paginacao) async {
    _paginacoes[paginacao.key] = paginacao;
  }

  @override
  Future<void> limparTudo() async => _paginacoes.clear();
}
