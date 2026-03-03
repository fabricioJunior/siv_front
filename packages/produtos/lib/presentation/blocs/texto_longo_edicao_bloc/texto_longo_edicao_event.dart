part of 'texto_longo_edicao_bloc.dart';

abstract class TextoLongoEdicaoEvent extends Equatable {
  const TextoLongoEdicaoEvent();

  @override
  List<Object?> get props => [];
}

class TextoLongoEdicaoIniciou extends TextoLongoEdicaoEvent {
  final String titulo;
  final String hintText;
  final String textoInicial;

  const TextoLongoEdicaoIniciou({
    required this.titulo,
    required this.hintText,
    required this.textoInicial,
  });

  @override
  List<Object?> get props => [titulo, hintText, textoInicial];
}

class TextoLongoEdicaoTextoAlterado extends TextoLongoEdicaoEvent {
  final String texto;

  const TextoLongoEdicaoTextoAlterado({required this.texto});

  @override
  List<Object?> get props => [texto];
}

class TextoLongoEdicaoLimparSolicitado extends TextoLongoEdicaoEvent {
  const TextoLongoEdicaoLimparSolicitado();
}
