import 'dart:developer';

import 'package:core/local_data_sourcers/i_local_data_source.dart';

import 'package:isar_community/isar.dart';

import 'isar_dto.dart';

abstract class IsarLocalDataSourceBase<Dto extends IsarDto, E>
    implements ILocalDataSource<Dto> {
  final Future<Isar> Function({
    bool? isSyncData,
  }) getIsar;

  IsarLocalDataSourceBase({required this.getIsar});

  @override
  Future<Iterable<Dto>> fetchAll() async {
    var isarInstace = await getIsar();

    return isarInstace.txn(() {
      return isarInstace.collection<Dto>().where().findAll();
    });
  }

  @override
  Future<Dto?> fetchById(int id) async {
    var isarInstace = await getIsar();

    return isarInstace.txn(() {
      return isarInstace.collection<Dto>().get(id);
    });
  }

  @override
  Future<Iterable<Dto>> fetchWhere(
    Test<Iterable<Dto>, IsarCollection<Dto>> test,
  ) async {
    var isarInstace = await getIsar();
    return await isarInstace.txn(() async {
      return test(isarInstace.collection<Dto>());
    });
  }

  @override
  Future<void> put(dynamic dto) async {
    var isarInstace = await getIsar();

    await isarInstace.writeTxn(() async {
      await isarInstace.collection<Dto>().put(dto is Dto ? dto : toDto(dto));
    });
  }

  @override
  Future<void> putAll(Iterable<dynamic> entities) async {
    var isarInstace = await getIsar();
    var dtos =
        entities is! Iterable<Dto> ? entities.map((e) => toDto(e)) : entities;
    await isarInstace.writeTxn(() {
      return isarInstace.collection<Dto>().putAll(dtos.toList());
    });
  }

  Future<void> deleteById(int id) async {
    var isarInstace = await getIsar();
    await isarInstace.writeTxn(() {
      return isarInstace.collection<Dto>().delete(id);
    });
  }

  Future<void> deleteWhere(
    Test<Iterable<Dto>, IsarCollection<Dto>> test,
  ) async {
    var toDelete = await fetchWhere(test);
    for (var item in toDelete) {
      await deleteById(item.dataBaseId);
    }
  }

  @override
  Future<void> deleteAll() async {
    log('iniciou');
    var isarInstace = await getIsar();
    isarInstace.writeTxn(() async {
      return isarInstace.collection<Dto>().clear();
    });
    log('finalizou');
  }

  Dto toDto(E entity);
}

abstract class IsarFind<Dto>
    implements Test<Iterable<Dto>, IsarCollection<Dto>> {}
