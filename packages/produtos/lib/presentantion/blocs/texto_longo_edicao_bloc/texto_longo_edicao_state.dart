part of 'texto_longo_edicao_bloc.dart';

class TextoLongoEdicaoState extends Equatable {
  final String titulo;
  final String hintText;
  final String texto;

  const TextoLongoEdicaoState({
    this.titulo = '',
    this.hintText = '',
    this.texto = '',
  });

  TextoLongoEdicaoState copyWith({
    String? titulo,
    String? hintText,
    String? texto,
  }) {
    return TextoLongoEdicaoState(
      titulo: titulo ?? this.titulo,
      hintText: hintText ?? this.hintText,
      texto: texto ?? this.texto,
    );
  }

  @override
  List<Object?> get props => [titulo, hintText, texto];
}
