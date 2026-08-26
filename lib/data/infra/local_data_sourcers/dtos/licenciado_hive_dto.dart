import 'package:autenticacao/models.dart';
import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart.
class LicenciadoHiveDto implements Licenciado, HiveDto, StorageEntity {
  @override
  final String id;

  @override
  final String nome;

  @override
  final String urlApi;

  const LicenciadoHiveDto({
    required this.id,
    required this.nome,
    required this.urlApi,
  });

  @override
  int get dataBaseId => hiveHash(id);

  @override
  Map<String, dynamic> get storageProperties => {
    'id': id,
    'nome': nome,
    'urlApi': urlApi,
  };

  static LicenciadoHiveDto fromStorage(Map<String, dynamic> props) {
    return LicenciadoHiveDto(
      id: props['id'] as String,
      nome: props['nome'] as String,
      urlApi: props['urlApi'] as String,
    );
  }

  @override
  List<Object?> get props => [id, nome, urlApi];

  @override
  bool? get stringify => true;
}
