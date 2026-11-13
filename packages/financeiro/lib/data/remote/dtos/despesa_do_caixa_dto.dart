import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class DespesaDoCaixaDto extends DespesaDoCaixa {
  @override
  final int id;

  @override
  final double valor;

  @override
  final String descricao;

  @override
  final int categoriaId;

  @override
  final String? categoriaNome;

  @override
  final DateTime? dataHora;

  @override
  final String? operadorNome;

  @override
  final bool cancelado;

  @override
  final String? motivoCancelamento;

  DespesaDoCaixaDto({
    required this.id,
    required this.valor,
    required this.descricao,
    required this.categoriaId,
    this.categoriaNome,
    this.dataHora,
    this.operadorNome,
    this.cancelado = false,
    this.motivoCancelamento,
  });

  factory DespesaDoCaixaDto.fromJson(Map<String, dynamic> json) {
    return DespesaDoCaixaDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      valor: double.tryParse(json['valor']?.toString() ?? '') ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      categoriaId: int.tryParse(json['categoriaId']?.toString() ?? '') ?? 0,
      categoriaNome: json['categoriaNome']?.toString(),
      dataHora: DateTime.tryParse(json['dataHora']?.toString() ?? ''),
      operadorNome: json['operadorNome']?.toString(),
      cancelado: json['cancelado'] == true,
      motivoCancelamento: json['motivoCancelamento']?.toString(),
    );
  }
}

class CategoriaDespesaDoCaixaDto extends CategoriaDespesaDoCaixa {
  @override
  final int id;

  @override
  final String nome;

  CategoriaDespesaDoCaixaDto({required this.id, required this.nome});

  factory CategoriaDespesaDoCaixaDto.fromJson(Map<String, dynamic> json) {
    return CategoriaDespesaDoCaixaDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
    );
  }
}
