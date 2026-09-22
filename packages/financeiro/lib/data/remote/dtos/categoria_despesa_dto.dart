import 'package:financeiro/domain/models/categoria_despesa.dart';

class CategoriaDespesaDto extends CategoriaDespesa {
  const CategoriaDespesaDto({
    super.id,
    super.empresaId,
    required super.nome,
    super.inativa,
  });

  factory CategoriaDespesaDto.fromJson(Map<String, dynamic> json) {
    return CategoriaDespesaDto(
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      nome: (json['nome'] as String?) ?? '',
      inativa: json['inativa'] as bool? ?? false,
    );
  }

  factory CategoriaDespesaDto.fromModel(CategoriaDespesa categoria) {
    return CategoriaDespesaDto(
      id: categoria.id,
      empresaId: categoria.empresaId,
      nome: categoria.nome,
      inativa: categoria.inativa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (empresaId != null) 'empresaId': empresaId,
      'nome': nome,
      'inativa': inativa,
    };
  }
}
