import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:json_annotation/json_annotation.dart';

part 'produto_do_estoque_dto.g.dart';

@JsonSerializable()
class ProdutoDoEstoqueDto implements ProdutoDoEstoque {
  @override
  final int empresaId;

  @override
  final int referenciaId;

  @override
  final String? referenciaIdExterno;

  @override
  @JsonKey(fromJson: _bigIntFromJson)
  final BigInt produtoId;

  @override
  final String? produtoIdExterno;

  @override
  final String nome;

  @override
  final int corId;

  @override
  final String corNome;

  @override
  final int tamanhoId;

  @override
  final String tamanhoNome;

  @override
  final String? unidadeMedida;

  @override
  final double saldo;

  @override
  final DateTime? atualizadoEm;

  ProdutoDoEstoqueDto({
    required this.empresaId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.produtoId,
    required this.produtoIdExterno,
    required this.nome,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.unidadeMedida,
    required this.saldo,
    this.atualizadoEm,
  });

  factory ProdutoDoEstoqueDto.fromJson(Map<String, dynamic> json) =>
      _$ProdutoDoEstoqueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProdutoDoEstoqueDtoToJson(this);

  static BigInt _bigIntFromJson(dynamic json) => BigInt.parse(json as String);
  @override
  List<Object?> get props => [
    empresaId,
    referenciaId,
    referenciaIdExterno,
    produtoId,
    produtoIdExterno,
    nome,
    corId,
    corNome,
    tamanhoId,
    tamanhoNome,
    unidadeMedida,
    saldo,
    atualizadoEm,
  ];

  @override
  bool? get stringify => true;
}
