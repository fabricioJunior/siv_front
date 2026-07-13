// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:core/equals.dart';

abstract class Permissao implements Equatable {
  String get id;
  String? get nome;
  bool get descontinuado;

  /// Label pro usuário final (admin de loja), sem jargão de backend --
  /// ex: "Excluir pagamento avulso" em vez de "Exclusão lógica de
  /// pagamento avulso" (que é `nome`, a descrição técnica). Null pra
  /// componente ainda não revisado no backend.
  String? get nomeAmigavel;

  @override
  List<Object?> get props => [
        id,
        nome,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}

extension PermissaoExibicao on Permissao {
  /// Texto pra mostrar na UI: nomeAmigavel > nome técnico (fallback pra
  /// componente ainda não revisado) > o próprio código como último
  /// recurso. `id` é a chave estável usada aqui -- é o mesmo ponto onde
  /// uma futura camada de tradução (i18n) deve resolver o texto no idioma
  /// ativo antes de cair nesse fallback em pt-BR.
  String get nomeExibicao => nomeAmigavel ?? nome ?? id;
}
