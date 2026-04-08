import 'package:core/isar_anotacoes.dart';
import 'package:precos/models.dart';

part 'preco_da_referencia_dto.g.dart';

@Collection(ignore: {'props', 'stringify'})
class PrecoDaReferenciaDto implements PrecoDaReferencia, IsarDto {
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

  const PrecoDaReferenciaDto({
    required this.atualizadoEm,
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.valor,
    required this.operadorId,
  });

  @override
  Id get dataBaseId => databaseIdFor(
    tabelaDePrecoId: tabelaDePrecoId,
    referenciaId: referenciaId,
  );

  static Id databaseIdFor({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return fastHash('$tabelaDePrecoId:$referenciaId');
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
