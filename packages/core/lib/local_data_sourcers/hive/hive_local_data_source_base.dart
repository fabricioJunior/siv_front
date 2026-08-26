import 'package:core/local_data_sourcers/i_local_data_source.dart';
import 'package:hive_ce/hive.dart';

import 'hive_dto.dart';

abstract class HiveLocalDataSourceBase<Dto extends HiveDto, E>
    implements ILocalDataSource<Dto> {
  final Future<Box<Dto>> Function() getBox;

  HiveLocalDataSourceBase({required this.getBox});

  @override
  Future<Iterable<Dto>> fetchAll() async {
    final box = await getBox();
    return box.values;
  }

  @override
  Future<Dto?> fetchById(int id) async {
    final box = await getBox();
    return box.get(id);
  }

  @override
  Future<Iterable<Dto>> fetchWhere(bool Function(Dto) predicate) async {
    return (await fetchAll()).where(predicate);
  }

  @override
  Future<void> put(dynamic dto) async {
    final box = await getBox();
    final entity = dto is Dto ? dto : toDto(dto);
    await box.put(entity.dataBaseId, entity);
  }

  @override
  Future<void> putAll(Iterable<dynamic> entities) async {
    final box = await getBox();
    final dtos =
        entities is! Iterable<Dto> ? entities.map((e) => toDto(e)) : entities;
    await box.putAll({for (final dto in dtos) dto.dataBaseId: dto});
  }

  Future<void> deleteById(int id) async {
    final box = await getBox();
    await box.delete(id);
  }

  Future<void> deleteWhere(bool Function(Dto) predicate) async {
    final toDelete = await fetchWhere(predicate);
    for (final item in toDelete) {
      await deleteById(item.dataBaseId);
    }
  }

  @override
  Future<void> deleteAll() async {
    final box = await getBox();
    await box.clear();
  }

  Dto toDto(E entity);
}
