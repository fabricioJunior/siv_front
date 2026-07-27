import 'package:produtos/domain/models/grade_da_referencia.dart';
import 'package:produtos/domain/models/imagem_da_referencia.dart';
import 'package:produtos/domain/models/produto_da_grade.dart';

class GradeDaReferenciaDto {
  static GradeDaReferencia fromJson(Map<String, dynamic> json) {
    final imagemJson = json['imagem'] as Map<String, dynamic>?;
    final produtosJson = json['produtos'] as List? ?? const [];

    return GradeDaReferencia(
      referenciaId: (json['referenciaId'] as num).toInt(),
      referenciaIdExterno: json['referenciaIdExterno']?.toString(),
      nome: (json['nome'] ?? '').toString(),
      unidadeMedida: json['unidadeMedida']?.toString(),
      tabelaDePrecoId: (json['tabelaDePrecoId'] as num?)?.toInt(),
      valor: (json['valor'] as num?)?.toDouble(),
      totalEmEstoque: (json['totalEmEstoque'] as num?)?.toInt() ?? 0,
      imagem: imagemJson != null
          ? _ImagemDaReferenciaDto.fromJson(imagemJson)
          : null,
      produtos: produtosJson
          .map((e) => _ProdutoDaGradeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class _ImagemDaReferenciaDto {
  static ImagemDaReferencia fromJson(Map<String, dynamic> json) {
    return ImagemDaReferencia(
      id: (json['id'] as num).toInt(),
      url: (json['url'] ?? '').toString(),
      isDefault: json['isDefault'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }
}

class _ProdutoDaGradeDto {
  static ProdutoDaGrade fromJson(Map<String, dynamic> json) {
    final codigosJson = json['codigosBarras'] as List? ?? const [];

    return ProdutoDaGrade(
      produtoId: (json['produtoId'] as num).toInt(),
      produtoIdExterno: json['produtoIdExterno']?.toString(),
      corId: (json['corId'] as num?)?.toInt() ?? 0,
      corNome: (json['corNome'] ?? '').toString(),
      tamanhoId: (json['tamanhoId'] as num?)?.toInt() ?? 0,
      tamanhoNome: (json['tamanhoNome'] ?? '').toString(),
      codigosBarras: codigosJson.map((e) => e.toString()).toList(),
      saldo: (json['saldo'] as num?)?.toInt() ?? 0,
    );
  }
}
