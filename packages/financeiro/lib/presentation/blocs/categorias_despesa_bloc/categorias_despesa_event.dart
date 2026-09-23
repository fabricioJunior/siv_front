part of 'categorias_despesa_bloc.dart';

abstract class CategoriasDespesaEvent {}

class CategoriasDespesaIniciou extends CategoriasDespesaEvent {
  final int empresaId;
  final String? busca;

  CategoriasDespesaIniciou({required this.empresaId, this.busca});
}

/// Cria (id nulo) ou atualiza (id preenchido) uma categoria a partir da
/// edição em linha da lista de cadastros.
class CategoriasDespesaSalvou extends CategoriasDespesaEvent {
  final int? id;
  final int empresaId;
  final String nome;
  final bool inativa;

  CategoriasDespesaSalvou({
    this.id,
    required this.empresaId,
    required this.nome,
    this.inativa = false,
  });
}
