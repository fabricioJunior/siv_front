import 'package:core/isar_anotacoes.dart';
import 'package:precos/models.dart';

part 'tabela_de_preco_dto.g.dart';

@Collection(ignore: {'props', 'stringify'})
class TabelaDePrecoDto implements TabelaDePreco, IsarDto {
  @override
  final int? id;

  @override
  final bool inativa;

  @override
  final String nome;

  @override
  List<Object?> get props => [id, inativa, nome];

  @override
  bool? get stringify => true;

  @override
  final double? terminador;

  TabelaDePrecoDto({
    required this.id,
    required this.inativa,
    required this.nome,
    required this.terminador,
  });

  @override
  Id get dataBaseId => id!;
}
