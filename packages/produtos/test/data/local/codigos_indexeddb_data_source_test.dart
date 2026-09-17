import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/indexeddb/indexeddb_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:produtos/data/local/codigos_indexeddb_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';

void main() {
  late IIndexedDbDatabaseInstance dbInstance;
  late CodigosIndexedDbDataSource datasource;

  setUp(() {
    dbInstance = IndexedDbDatabaseInstance(
      factory: newIdbFactoryMemory(),
      stores: const [
        IndexedDbStoreSpec(
          storeName: 'produtos_CodigoHiveDto',
          indexes: ['produtoId'],
        ),
      ],
      version: 2,
    );
    datasource = CodigosIndexedDbDataSource(getDb: () => dbInstance.getDatabase());
  });

  tearDown(() async {
    await dbInstance.closeAllInstances();
  });

  Codigo codigo({required String codigo, required int produtoId}) {
    return _CodigoFake(codigo: codigo, produtoId: produtoId);
  }

  test(
    'recuperarCodigosPorProdutoIds agrupa por produtoId, numa transação só, '
    'pra múltiplos produtos de uma vez',
    () async {
      await datasource.salvarCodigosDeBarras([
        codigo(codigo: 'EAN1A', produtoId: 1),
        codigo(codigo: 'EAN1B', produtoId: 1),
        codigo(codigo: 'EAN2', produtoId: 2),
        codigo(codigo: 'EAN3', produtoId: 3),
      ]);

      final resultado = await datasource.recuperarCodigosPorProdutoIds([1, 2, 4]);

      expect(
        resultado[1]!.map((c) => c.codigo).toSet(),
        {'EAN1A', 'EAN1B'},
      );
      expect(resultado[2]!.map((c) => c.codigo).toSet(), {'EAN2'});
      expect(resultado.containsKey(3), isFalse);
      expect(resultado.containsKey(4), isFalse);
    },
  );
}

class _CodigoFake implements Codigo {
  @override
  final String codigo;
  @override
  final int produtoId;
  @override
  TipoCodigo get tipo => TipoCodigo.ean13;

  _CodigoFake({required this.codigo, required this.produtoId});
}
