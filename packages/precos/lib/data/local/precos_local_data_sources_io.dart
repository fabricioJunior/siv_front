import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';

import 'dtos/preco_da_referencia_dto.dart';
import 'dtos/tabela_de_preco_dto.dart';
import 'precos_de_referencias_local_data_source.dart';
import 'tabelas_de_preco_local_data_source.dart';

void registerPrecosLocalDataSources() {
  sl.registerFactory<ITabelasDePrecoLocalDataSource>(
    () => TabelasDePrecoLocalDataSource(getIsar: _getIsar),
  );
  sl.registerFactory<IPrecosDeReferenciasLocalDataSource>(
    () => PrecosDeReferenciasLocalDataSource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    TabelaDePrecoDtoSchema,
    PrecoDaReferenciaDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
    moduleName: 'precos',
  );
}
