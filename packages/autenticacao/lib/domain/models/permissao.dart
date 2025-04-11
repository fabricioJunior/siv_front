// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:core/equals.dart';

mixin Permissao implements Equatable {
  int get id;
  String get nome;
  bool get descontinuado;

  static Permissao instance({
    required int id,
    required String nome,
    required bool descontinuado,
  }) =>
      _Permissao(
        id: id,
        nome: nome,
        descontinuado: descontinuado,
      );

  Permissao copyWith({
    int? id,
    String? nome,
    bool? descontinuado,
  }) {
    return _Permissao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descontinuado: descontinuado ?? this.descontinuado,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}

class _Permissao with Permissao {
  @override
  final int id;
  @override
  final String nome;
  @override
  final bool descontinuado;

  _Permissao({
    required this.id,
    required this.nome,
    required this.descontinuado,
  });
}
