import 'package:core/equals.dart';

abstract class Produto implements Equatable {
  int? get id;
  int get referenciaId;
  String get idExterno;
  int get corId;
  int get tamanhoId;

  factory Produto.create({
    int? id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  }) = _ProdutoImpl;

  @override
  List<Object?> get props => [id, referenciaId, idExterno, corId, tamanhoId];

  @override
  bool? get stringify => true;
}

class _ProdutoImpl implements Produto {
  @override
  final int? id;

  @override
  final int referenciaId;

  @override
  final String idExterno;

  @override
  final int corId;

  @override
  final int tamanhoId;

  _ProdutoImpl({
    this.id,
    required this.referenciaId,
    required this.idExterno,
    required this.corId,
    required this.tamanhoId,
  });

  _ProdutoImpl copyWith({
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
  }) {
    return _ProdutoImpl(
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
    );
  }

  @override
  List<Object?> get props => [id, referenciaId, idExterno, corId, tamanhoId];

  @override
  bool? get stringify => true;
}

extension ProdutoCopyWith on Produto {
  Produto copyWith({
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
  }) {
    if (this is _ProdutoImpl) {
      return (this as _ProdutoImpl).copyWith(
        id: id,
        referenciaId: referenciaId,
        idExterno: idExterno,
        corId: corId,
        tamanhoId: tamanhoId,
      );
    }

    return Produto.create(
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
    );
  }
}
