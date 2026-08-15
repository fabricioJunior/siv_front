import 'package:comercial/models.dart';

class EcommerceReferenciaProdutoDto implements EcommerceReferenciaProduto {
  @override
  final int? id;
  @override
  final int ecommerceReferenciaId;
  @override
  final int produtoId;
  @override
  final bool disponivel;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;
  @override
  final num saldo;

  const EcommerceReferenciaProdutoDto({
    this.id,
    required this.ecommerceReferenciaId,
    required this.produtoId,
    this.disponivel = true,
    this.corNome,
    this.tamanhoNome,
    this.saldo = 0,
  });

  factory EcommerceReferenciaProdutoDto.fromJson(Map<String, dynamic> json) {
    return EcommerceReferenciaProdutoDto(
      id: _toInt(json['id']),
      ecommerceReferenciaId: _toInt(json['ecommerceReferenciaId']) ?? 0,
      produtoId: _toInt(json['produtoId']) ?? 0,
      disponivel: json['disponivel'] as bool? ?? true,
      corNome: json['corNome']?.toString(),
      tamanhoNome: json['tamanhoNome']?.toString(),
      saldo: num.tryParse(json['saldo']?.toString() ?? '') ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ecommerceReferenciaId,
        produtoId,
        disponivel,
        corNome,
        tamanhoNome,
        saldo,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');
