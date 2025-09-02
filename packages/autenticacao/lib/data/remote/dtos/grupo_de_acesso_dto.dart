import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grupo_de_acesso_dto.g.dart';

@JsonSerializable()
class GrupoDeAcessoDto with GrupoDeAcesso {
  @override
  final int id;

  @override
  final String nome;

  @override
  @JsonKey(includeToJson: false, includeFromJson: true, name: 'itens')
  final Iterable<PermissaoDto> permissoes;

  // // ignore: library_private_types_in_public_api
  // @JsonKey(includeToJson: false, includeFromJson: true, defaultValue: [])
  // final Iterable<_Item> itens;

  GrupoDeAcessoDto({
    required this.id,
    required this.nome,
    required this.permissoes,
  });

  factory GrupoDeAcessoDto.fromJson(Map<String, dynamic> json) =>
      _$GrupoDeAcessoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GrupoDeAcessoDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class _Item {
  @JsonKey(includeToJson: false, includeFromJson: true, defaultValue: [])
  final List<PermissaoDto> permissoes;

  _Item({required this.permissoes});

  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
