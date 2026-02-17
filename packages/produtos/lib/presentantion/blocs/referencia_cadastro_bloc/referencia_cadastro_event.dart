part of 'referencia_cadastro_bloc.dart';

abstract class ReferenciaCadastroEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciaCadastroIniciou extends ReferenciaCadastroEvent {}

class ReferenciaCadastroCategoriaSelecionada extends ReferenciaCadastroEvent {
  final Categoria categoria;

  ReferenciaCadastroCategoriaSelecionada({required this.categoria});

  @override
  List<Object?> get props => [categoria];
}

class ReferenciaCadastroSubCategoriaSelecionada
    extends ReferenciaCadastroEvent {
  final SubCategoria? subCategoria;

  ReferenciaCadastroSubCategoriaSelecionada({required this.subCategoria});

  @override
  List<Object?> get props => [subCategoria];
}

class ReferenciaCadastroIdAlterado extends ReferenciaCadastroEvent {
  final int? id;

  ReferenciaCadastroIdAlterado({required this.id});

  @override
  List<Object?> get props => [id];
}

class ReferenciaCadastroGerarId extends ReferenciaCadastroEvent {}

class ReferenciaCadastroGerarNome extends ReferenciaCadastroEvent {}

class ReferenciaCadastroNomeAlterado extends ReferenciaCadastroEvent {
  final String nome;

  ReferenciaCadastroNomeAlterado({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class ReferenciaCadastroProximo extends ReferenciaCadastroEvent {}

class ReferenciaCadastroVoltar extends ReferenciaCadastroEvent {}

class ReferenciaCadastroReiniciar extends ReferenciaCadastroEvent {}
