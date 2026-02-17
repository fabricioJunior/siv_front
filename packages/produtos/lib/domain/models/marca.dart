import 'package:core/equals.dart';

abstract class Marca implements Equatable {
  int? get id;
  String get nome;
  bool get inativa;

  factory Marca.create({int? id, required String nome, required bool inativa}) =
      _MarcaImpl;

  @override
  List<Object?> get props => [id, nome, inativa];

  @override
  bool? get stringify => true;
}

class _MarcaImpl implements Marca {
  @override
  final int? id;
  @override
  final String nome;
  @override
  final bool inativa;

  _MarcaImpl({this.id, required this.nome, required this.inativa});

  _MarcaImpl copyWith({int? id, String? nome, bool? inativa}) {
    return _MarcaImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [id, nome, inativa];

  @override
  bool? get stringify => true;
}

extension MarcaCopyWith on Marca {
  Marca copyWith({int? id, String? nome, bool? inativa}) {
    if (this is _MarcaImpl) {
      return (this as _MarcaImpl).copyWith(
        id: id,
        nome: nome,
        inativa: inativa,
      );
    }
    return Marca.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      inativa: inativa ?? this.inativa,
    );
  }
}
