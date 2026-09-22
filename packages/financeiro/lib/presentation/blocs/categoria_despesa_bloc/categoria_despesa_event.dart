part of 'categoria_despesa_bloc.dart';

abstract class CategoriaDespesaEvent {}

class CategoriaDespesaIniciou extends CategoriaDespesaEvent {
  final int empresaId;
  final int? id;

  CategoriaDespesaIniciou({required this.empresaId, this.id});
}

class CategoriaDespesaCampoAlterado extends CategoriaDespesaEvent {
  final String? nome;
  final bool? inativa;

  CategoriaDespesaCampoAlterado({this.nome, this.inativa});
}

class CategoriaDespesaSalvou extends CategoriaDespesaEvent {}
