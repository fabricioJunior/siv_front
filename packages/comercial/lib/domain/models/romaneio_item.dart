import 'package:core/equals.dart';

abstract class RomaneioItem implements Equatable {
  int? get produtoId;
  double? get quantidade;
  int? get referenciaId;
  String? get referenciaNome;
  String? get corNome;
  String? get tamanhoNome;

  factory RomaneioItem.create({
    int? produtoId,
    double? quantidade,
    int? referenciaId,
    String? referenciaNome,
    String? corNome,
    String? tamanhoNome,
  }) = _RomaneioItemImpl;

  @override
  List<Object?> get props => [
        produtoId,
        quantidade,
        referenciaId,
        referenciaNome,
        corNome,
        tamanhoNome,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioItemImpl implements RomaneioItem {
  @override
  final int? produtoId;
  @override
  final double? quantidade;
  @override
  final int? referenciaId;
  @override
  final String? referenciaNome;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;

  const _RomaneioItemImpl({
    this.produtoId,
    this.quantidade,
    this.referenciaId,
    this.referenciaNome,
    this.corNome,
    this.tamanhoNome,
  });

  @override
  List<Object?> get props => [
        produtoId,
        quantidade,
        referenciaId,
        referenciaNome,
        corNome,
        tamanhoNome,
      ];

  @override
  bool? get stringify => true;
}
