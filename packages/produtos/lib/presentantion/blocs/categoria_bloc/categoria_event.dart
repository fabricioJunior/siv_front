part of 'categoria_bloc.dart';

abstract class CategoriaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriaIniciou extends CategoriaEvent {
  final int? idCategoria;

  CategoriaIniciou({this.idCategoria});

  @override
  List<Object?> get props => [idCategoria];
}

class CategoriaEditou extends CategoriaEvent {
  final String nome;
  final String? ncm;
  final String? descricao;
  final int? pesoGramas;

  CategoriaEditou({
    required this.nome,
    this.ncm,
    this.descricao,
    this.pesoGramas,
  });

  @override
  List<Object?> get props => [nome, ncm, descricao, pesoGramas];
}

class CategoriaSalvou extends CategoriaEvent {
  CategoriaSalvou();

  @override
  List<Object?> get props => [];
}

class CategoriaIconeEnviou extends CategoriaEvent {
  final Uint8List bytes;
  final String fileName;

  CategoriaIconeEnviou({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [bytes, fileName];
}
