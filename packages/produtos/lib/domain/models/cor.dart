import 'package:core/equals.dart';

abstract class Cor extends Equatable {
  int? get id;
  String get nome;
  bool? get inativo;

  @override
  List<Object?> get props => [id, nome, inativo];
}
