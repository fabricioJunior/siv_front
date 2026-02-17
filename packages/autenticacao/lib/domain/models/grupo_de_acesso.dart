import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/models.dart';
import 'package:core/equals.dart';

abstract class GrupoDeAcesso implements Equatable {
  int? get id;
  String get nome;
  List<Permissao> get permissoes;

  @override
  List<Object?> get props => [
        id,
        nome,
        permissoes,
      ];
  @override
  bool? get stringify => true;
}

extension GrupoDeAcessoCopyWith on GrupoDeAcesso {
  GrupoDeAcesso copyWith({
    int? id,
    String? nome,
    List<Permissao>? permissoes,
  }) {
    // Import the DTO to create a new instance
    // This is safe as it's in an extension, not the core model
    return GrupoDeAcessoDto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      permissoes: permissoes?.cast<PermissaoDto>() ??
          (this.permissoes.cast<PermissaoDto>()),
    );
  }
}
