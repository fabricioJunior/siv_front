import 'package:core/isar_anotacoes.dart';

import '../../models/lista_de_produtos_compartilhada.dart';

part 'lista_de_produtos_compartilhada_dto.g.dart';

@Collection(ignore: {'props', 'origem'})
class ListaDeProdutosCompartilhadaDto extends ListaDeProdutosCompartilhada
    with IsarDto<ListaDeProdutosCompartilhada> {
  ListaDeProdutosCompartilhadaDto({
    required super.hash,
    required super.criadaEm,
    required super.atualizadaEm,
    required this.origemIndex,
    super.idLista,
    super.pessoaId,
    super.funcionarioId,
    super.tabelaPrecoId,
    super.processada,
  }) : super(origem: OrigemCompartilhadaTipo.values[origemIndex]);

  final int origemIndex;

  @override
  @ignore
  OrigemCompartilhadaTipo get origem =>
      OrigemCompartilhadaTipo.values[origemIndex];

  @override
  Id get dataBaseId => fastHash(hash);
}
