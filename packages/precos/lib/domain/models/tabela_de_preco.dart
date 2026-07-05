import 'package:core/equals.dart';

abstract class TabelaDePreco implements Equatable {
  int? get id;
  String get nome;
  double? get terminador;
  bool get inativa;
  bool get padrao;

  factory TabelaDePreco.create({
    int? id,
    required String nome,
    double? terminador,
    required bool inativa,
    bool padrao,
  }) = _TabelaDePrecoImpl;

  @override
  List<Object?> get props => [id, nome, terminador, inativa, padrao];

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
  @override
  final bool padrao;

  _TabelaDePrecoImpl({
    this.id,
    required this.nome,
    this.terminador,
    required this.inativa,
    this.padrao = false,
  });

  _TabelaDePrecoImpl copyWith({
    int? id,
    String? nome,
    double? terminador,
    bool? inativa,
    bool? padrao,
  }) {
    return _TabelaDePrecoImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      terminador: terminador ?? this.terminador,
      inativa: inativa ?? this.inativa,
      padrao: padrao ?? this.padrao,
    );
  }

  @override
  List<Object?> get props => [id, nome, terminador, inativa, padrao];

  @override
  bool? get stringify => true;
}

extension TabelaDePrecoCopyWith on TabelaDePreco {
  TabelaDePreco copyWith({
    int? id,
    String? nome,
    double? terminador,
    bool? inativa,
    bool? padrao,
  }) {
    if (this is _TabelaDePrecoImpl) {
      return (this as _TabelaDePrecoImpl).copyWith(
        id: id,
        nome: nome,
        terminador: terminador,
        inativa: inativa,
        padrao: padrao,
      );
    }
    return TabelaDePreco.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      terminador: terminador ?? this.terminador,
      inativa: inativa ?? this.inativa,
      padrao: padrao ?? this.padrao,
    );
  }
}
