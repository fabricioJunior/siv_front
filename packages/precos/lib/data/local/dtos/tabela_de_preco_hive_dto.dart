import 'package:core/hive_anotacoes.dart';
import 'package:precos/models.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class TabelaDePrecoHiveDto implements TabelaDePreco, HiveDto, StorageEntity {
  @override
  final int? id;

  @override
  final bool inativa;

  @override
  final String nome;

  @override
  final bool padrao;

  @override
  final double? terminador;

  TabelaDePrecoHiveDto({
    required this.id,
    required this.inativa,
    required this.nome,
    required this.terminador,
    this.padrao = false,
  });

  @override
  int get dataBaseId => id!;

  @override
  Map<String, dynamic> get storageProperties => {
    'id': id,
    'inativa': inativa,
    'nome': nome,
    'padrao': padrao,
    'terminador': terminador,
  };

  static TabelaDePrecoHiveDto fromStorage(Map<String, dynamic> props) {
    return TabelaDePrecoHiveDto(
      id: props['id'] as int?,
      inativa: props['inativa'] as bool,
      nome: props['nome'] as String,
      terminador: props['terminador'] as double?,
      padrao: props['padrao'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, inativa, nome, padrao];

  @override
  bool? get stringify => true;
}
