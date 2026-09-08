import 'package:core/equals.dart';

abstract class EcommerceReferencia implements Equatable {
  int? get id;
  int get ecommerceId;
  int get referenciaId;
  int? get tabelaDePrecoId;
  bool get rascunho;
  String? get referenciaNome;
  double? get valor;
  String? get descricao;
  String? get unidadeMedida;
  String? get imagemUrl;
  num? get saldo;

  /// Campos tolerantes -- podem não vir do backend ainda. Nunca deduzir
  /// valor local quando nulos; a UI trata ausência como "sem informação".
  String? get categoriaNome;
  int? get produtosTotal;
  int? get produtosDisponiveis;
  bool? get publicavel;
  List<String>? get motivosBloqueio;
  String? get tabelaDePrecoNome;

  factory EcommerceReferencia.create({
    int? id,
    required int ecommerceId,
    required int referenciaId,
    int? tabelaDePrecoId,
    required bool rascunho,
    String? referenciaNome,
    double? valor,
    String? descricao,
    String? unidadeMedida,
    String? imagemUrl,
    num? saldo,
    String? categoriaNome,
    int? produtosTotal,
    int? produtosDisponiveis,
    bool? publicavel,
    List<String>? motivosBloqueio,
    String? tabelaDePrecoNome,
  }) = _EcommerceReferenciaImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
        valor,
        descricao,
        unidadeMedida,
        imagemUrl,
        saldo,
        categoriaNome,
        produtosTotal,
        produtosDisponiveis,
        publicavel,
        motivosBloqueio,
        tabelaDePrecoNome,
      ];
}

class _EcommerceReferenciaImpl implements EcommerceReferencia {
  @override
  final int? id;
  @override
  final int ecommerceId;
  @override
  final int referenciaId;
  @override
  final int? tabelaDePrecoId;
  @override
  final bool rascunho;
  @override
  final String? referenciaNome;
  @override
  final double? valor;
  @override
  final String? descricao;
  @override
  final String? unidadeMedida;
  @override
  final String? imagemUrl;
  @override
  final num? saldo;
  @override
  final String? categoriaNome;
  @override
  final int? produtosTotal;
  @override
  final int? produtosDisponiveis;
  @override
  final bool? publicavel;
  @override
  final List<String>? motivosBloqueio;
  @override
  final String? tabelaDePrecoNome;

  const _EcommerceReferenciaImpl({
    this.id,
    required this.ecommerceId,
    required this.referenciaId,
    this.tabelaDePrecoId,
    this.rascunho = true,
    this.referenciaNome,
    this.valor,
    this.descricao,
    this.unidadeMedida,
    this.imagemUrl,
    this.saldo,
    this.categoriaNome,
    this.produtosTotal,
    this.produtosDisponiveis,
    this.publicavel,
    this.motivosBloqueio,
    this.tabelaDePrecoNome,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
        valor,
        descricao,
        unidadeMedida,
        imagemUrl,
        saldo,
        categoriaNome,
        produtosTotal,
        produtosDisponiveis,
        publicavel,
        motivosBloqueio,
        tabelaDePrecoNome,
      ];
}
