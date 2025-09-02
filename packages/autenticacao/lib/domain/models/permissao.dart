// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:core/equals.dart';

mixin Permissao implements Equatable {
  String get id;
  String get nome;
  bool get descontinuado;

  static Permissao instance({
    required String id,
    required String nome,
    required bool descontinuado,
  }) =>
      _Permissao(
        id: id,
        nome: nome,
        descontinuado: descontinuado,
      );

  Permissao copyWith({
    String? id,
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
  final String id;
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
