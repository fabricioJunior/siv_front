import 'package:core/hive_anotacoes.dart';
import 'package:precos/models.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class PrecoDaReferenciaHiveDto
    implements PrecoDaReferencia, HiveDto, StorageEntity {
  @override
  final DateTime? atualizadoEm;

  @override
  final int tabelaDePrecoId;

  @override
  final int referenciaId;

  @override
  final String referenciaIdExterno;

  @override
  final String referenciaNome;

  @override
  final double valor;

  @override
  final int operadorId;

  const PrecoDaReferenciaHiveDto({
    required this.atualizadoEm,
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.valor,
    required this.operadorId,
  });

  @override
  int get dataBaseId => databaseIdFor(
    tabelaDePrecoId: tabelaDePrecoId,
    referenciaId: referenciaId,
  );

  static int databaseIdFor({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return hiveHash('$tabelaDePrecoId:$referenciaId');
  }

  @override
  Map<String, dynamic> get storageProperties => {
    'atualizadoEm': atualizadoEm,
    'tabelaDePrecoId': tabelaDePrecoId,
    'referenciaId': referenciaId,
    'referenciaIdExterno': referenciaIdExterno,
    'referenciaNome': referenciaNome,
    'valor': valor,
    'operadorId': operadorId,
  };

  static PrecoDaReferenciaHiveDto fromStorage(Map<String, dynamic> props) {
    return PrecoDaReferenciaHiveDto(
      atualizadoEm: props['atualizadoEm'] as DateTime?,
      tabelaDePrecoId: props['tabelaDePrecoId'] as int,
      referenciaId: props['referenciaId'] as int,
      referenciaIdExterno: props['referenciaIdExterno'] as String,
      referenciaNome: props['referenciaNome'] as String,
      valor: props['valor'] as double,
      operadorId: props['operadorId'] as int,
    );
  }

  @override
  List<Object?> get props => [
    atualizadoEm,
    tabelaDePrecoId,
    referenciaId,
    referenciaIdExterno,
    referenciaNome,
    valor,
    operadorId,
  ];

  @override
  bool? get stringify => true;
}
