import 'package:json_annotation/json_annotation.dart';
import 'package:precos/models.dart';

part 'tabela_de_preco_dto.g.dart';

@JsonSerializable()
class TabelaDePrecoDto implements TabelaDePreco {
  @override
  final int? id;

  @override
  final String nome;

  @override
  final double? terminador;

  @override
  final bool inativa;

  @override
  final bool padrao;

  TabelaDePrecoDto({
    this.id,
    required this.nome,
    this.terminador,
    required this.inativa,
    this.padrao = false,
  });

  factory TabelaDePrecoDto.fromJson(Map<String, dynamic> json) =>
      _$TabelaDePrecoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TabelaDePrecoDtoToJson(this);

  @override
  List<Object?> get props => [id, nome, terminador, inativa, padrao];

  @override
  bool? get stringify => true;
}
