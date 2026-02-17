import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grupo_de_acesso_dto.g.dart';

@JsonSerializable()
class GrupoDeAcessoDto implements GrupoDeAcesso {
  @override
  final int? id;

  @override
  final String nome;

  @override
  @JsonKey(includeToJson: false, includeFromJson: true, name: 'itens')
  final List<PermissaoDto> permissoes;

  GrupoDeAcessoDto(
      {required this.id, required this.nome, required this.permissoes});

  factory GrupoDeAcessoDto.fromJson(Map<String, dynamic> json) =>
      _$GrupoDeAcessoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GrupoDeAcessoDtoToJson(this);

  GrupoDeAcessoDto copyWith({
    int? id,
    String? nome,
    List<PermissaoDto>? permissoes,
  }) {
    return GrupoDeAcessoDto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      permissoes: permissoes ?? this.permissoes,
    );
  }

  @override
  List<Object?> get props => [id, nome, permissoes];

  @override
  bool? get stringify => true;
}

@JsonSerializable(createToJson: false)
class _Item {
  @JsonKey(includeToJson: false, includeFromJson: true, defaultValue: [])
  final List<PermissaoDto> permissoes;

  _Item({required this.permissoes});
}
