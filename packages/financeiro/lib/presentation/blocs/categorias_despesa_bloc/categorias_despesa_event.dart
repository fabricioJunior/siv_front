part of 'categorias_despesa_bloc.dart';

abstract class CategoriasDespesaEvent {}

class CategoriasDespesaIniciou extends CategoriasDespesaEvent {
  final int empresaId;
  final String? busca;

  CategoriasDespesaIniciou({required this.empresaId, this.busca});
}
