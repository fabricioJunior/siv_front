import 'package:core/equals.dart';

abstract class Tamanho extends Equatable {
  int? get id;
  String get nome;
  bool get inativo;

  @override
  List<Object?> get props => [id, nome, inativo];
}
