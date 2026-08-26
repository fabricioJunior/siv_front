import 'package:core/hive_anotacoes.dart';
import 'package:produtos/domain/models/codigo.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class CodigoHiveDto extends Codigo with HiveDto<Codigo>, StorageEntity {
  @override
  final String codigo;

  @override
  final int produtoId;

  final int tipoIndex;

  CodigoHiveDto({
    required this.codigo,
    required this.produtoId,
    required this.tipoIndex,
  });

  @override
  TipoCodigo get tipo => TipoCodigo.values[tipoIndex];

  @override
  int get dataBaseId => hiveHash(codigo);

  @override
  Map<String, dynamic> get storageProperties => {
    'codigo': codigo,
    'produtoId': produtoId,
    'tipoIndex': tipoIndex,
  };

  static CodigoHiveDto fromStorage(Map<String, dynamic> props) {
    return CodigoHiveDto(
      codigo: props['codigo'] as String,
      produtoId: props['produtoId'] as int,
      tipoIndex: props['tipoIndex'] as int,
    );
  }
}
