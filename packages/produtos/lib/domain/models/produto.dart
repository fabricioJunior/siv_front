import 'package:core/equals.dart';
import 'package:produtos/models.dart';

abstract class Produto implements Equatable {
  int? get id;
  int get referenciaId;
  String get idExterno;
  int get corId;
  int get tamanhoId;
  int? get estampaId;
  Referencia? get referencia;
  Cor? get cor;
  Tamanho? get tamanho;
  Estampa? get estampa;

  factory Produto.create({
    int? id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
    Referencia? referencia,
    Cor? cor,
    Tamanho? tamanho,
    Estampa? estampa,
  }) = _ProdutoImpl;

  @override
  List<Object?> get props => [
    id,
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    estampaId,
  ];

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

  @override
  final int? estampaId;

  @override
  final Cor? cor;

  @override
  final Referencia? referencia;

  @override
  final Tamanho? tamanho;

  @override
  final Estampa? estampa;

  _ProdutoImpl({
    this.id,
    required this.referenciaId,
    required this.idExterno,
    required this.corId,
    required this.tamanhoId,
    this.estampaId,
    this.referencia,
    this.cor,
    this.tamanho,
    this.estampa,
  });

  _ProdutoImpl copyWith({
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
    int? estampaId,
    Referencia? referencia,
    Cor? cor,
    Tamanho? tamanho,
    Estampa? estampa,
  }) {
    return _ProdutoImpl(
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      estampaId: estampaId ?? this.estampaId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    estampaId,
  ];

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
    int? estampaId,
  }) {
    if (this is _ProdutoImpl) {
      return (this as _ProdutoImpl).copyWith(
        id: id,
        referenciaId: referenciaId,
        idExterno: idExterno,
        corId: corId,
        tamanhoId: tamanhoId,
        estampaId: estampaId,
      );
    }

    return Produto.create(
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      estampaId: estampaId ?? this.estampaId,
    );
  }
}
