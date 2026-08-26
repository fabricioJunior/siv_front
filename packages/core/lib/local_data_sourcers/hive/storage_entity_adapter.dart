import 'package:hive_ce/hive.dart';

import 'entities_controller.dart' as entity_controllers;
import 'storage_entity.dart';

/// Adapter genérico -- serializa qualquer `StorageEntity` via
/// `storageProperties` (nome do campo -> valor), sem precisar de codegen
/// (`@HiveType`/`@HiveField`/build_runner) por DTO.
class StorageEntityAdapter<E extends StorageEntity> extends TypeAdapter<E> {
  StorageEntityAdapter(this.buildEntity, {this.typeCode});

  final E Function(Map<String, dynamic> props) buildEntity;
  final int? typeCode;

  void registerHiveAdapterWithType() {
    if (Hive.isAdapterRegistered(typeId)) {
      return;
    }
    Hive.registerAdapter<E>(this, override: true);
  }

  @override
  void write(BinaryWriter writer, E obj) {
    final props = obj.storageProperties;

    writer.writeInt(props.length);

    for (final prop in props.keys) {
      writer
        ..writeString(prop)
        ..write(props[prop]);
    }
  }

  @override
  E read(BinaryReader reader) {
    final numOfProperties = reader.readInt();
    final props = <String, dynamic>{
      for (int i = 0; i < numOfProperties; i++)
        reader.readString(): reader.read(),
    };
    return buildEntity(props);
  }

  @override
  int get typeId => typeCode ?? entity_controllers.typeId(E);
}
