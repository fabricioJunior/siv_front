import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:hive_ce/hive.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';

import 'dtos/preco_da_referencia_hive_dto.dart';
import 'dtos/tabela_de_preco_hive_dto.dart';
import 'precos_de_referencias_hive_data_source.dart';
import 'tabelas_de_preco_hive_data_source.dart';

void registerPrecosLocalDataSources() {
  sl.registerFactory<ITabelasDePrecoLocalDataSource>(
    () => TabelasDePrecoHiveDataSource(getBox: _getTabelaDePrecoBox),
  );
  sl.registerFactory<IPrecosDeReferenciasLocalDataSource>(
    () => PrecosDeReferenciasHiveDataSource(getBox: _getPrecoDaReferenciaBox),
  );
}

Future<Box<TabelaDePrecoHiveDto>> _getTabelaDePrecoBox() {
  return sl<IHiveDatabaseInstance>().getBox<TabelaDePrecoHiveDto>(
    boxKey: 'TabelaDePrecoHiveDto',
    adapters: [
      StorageEntityAdapter<TabelaDePrecoHiveDto>(
        TabelaDePrecoHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'precos',
  );
}

Future<Box<PrecoDaReferenciaHiveDto>> _getPrecoDaReferenciaBox() {
  return sl<IHiveDatabaseInstance>().getBox<PrecoDaReferenciaHiveDto>(
    boxKey: 'PrecoDaReferenciaHiveDto',
    adapters: [
      StorageEntityAdapter<PrecoDaReferenciaHiveDto>(
        PrecoDaReferenciaHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'precos',
  );
}
