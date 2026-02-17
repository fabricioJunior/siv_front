// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:core/equals.dart';

abstract class Permissao implements Equatable {
  String? get id;
  String? get nome;
  bool get descontinuado;

  @override
  List<Object?> get props => [
        id,
        nome,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}
