import 'package:autenticacao/models.dart';
import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart.
class EmpresaHiveDto implements Empresa, HiveDto, StorageEntity {
  @override
  final int id;

  @override
  final String nome;

  EmpresaHiveDto({required this.id, required this.nome});

  @override
  int get dataBaseId => id;

  @override
  Map<String, dynamic> get storageProperties => {'id': id, 'nome': nome};

  static EmpresaHiveDto fromStorage(Map<String, dynamic> props) {
    return EmpresaHiveDto(
      id: props['id'] as int,
      nome: props['nome'] as String,
    );
  }
}
