import 'package:core/equals.dart';

abstract class TabelaDePreco implements Equatable {
  int? get id;
  String get nome;
  double? get terminador;
  bool get inativa;

  factory TabelaDePreco.create({
    int? id,
    required String nome,
    double? terminador,
    required bool inativa,
  }) = _TabelaDePrecoImpl;

  @override
  List<Object?> get props => [id, nome, terminador, inativa];

  @override
  bool? get stringify => true;
}

class _TabelaDePrecoImpl implements TabelaDePreco {
  @override
  final int? id;
  @override
  final String nome;
  @override
  final double? terminador;
  @override
  final bool inativa;

  _TabelaDePrecoImpl({
    this.id,
    required this.nome,
    this.terminador,
    required this.inativa,
  });

  _TabelaDePrecoImpl copyWith({
    int? id,
    String? nome,
    double? terminador,
    bool? inativa,
  }) {
    return _TabelaDePrecoImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      terminador: terminador ?? this.terminador,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [id, nome, terminador, inativa];

  @override
  bool? get stringify => true;
}

extension TabelaDePrecoCopyWith on TabelaDePreco {
  TabelaDePreco copyWith({
    int? id,
    String? nome,
    double? terminador,
    bool? inativa,
  }) {
    if (this is _TabelaDePrecoImpl) {
      return (this as _TabelaDePrecoImpl).copyWith(
        id: id,
        nome: nome,
        terminador: terminador,
        inativa: inativa,
      );
    }
    return TabelaDePreco.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      terminador: terminador ?? this.terminador,
      inativa: inativa ?? this.inativa,
    );
  }
}
