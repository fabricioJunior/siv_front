import 'package:core/equals.dart';

// Espelha ImportacaoSituacao do backend (apps/api/.../importacao/enum).
enum ImportacaoSituacao {
  pendente,
  processando,
  concluida,
  falha,
  cancelada;

  static ImportacaoSituacao fromString(String? value) {
    return ImportacaoSituacao.values.firstWhere(
      (situacao) => situacao.name == value,
      orElse: () => ImportacaoSituacao.pendente,
    );
  }

  bool get finalizada =>
      this == ImportacaoSituacao.concluida ||
      this == ImportacaoSituacao.falha ||
      this == ImportacaoSituacao.cancelada;
}

enum ImportacaoProdutoVariante {
  completo,
  somente;

  String get value => name;
}

// Espelha item de `resultado.rejeitados` -- a variante "somente" traz
// referenciaId/produtoId/conteudo, "completo" traz só linha+motivo. Campos
// extras ficam nulos quando a variante não os envia.
class ImportacaoProdutoRejeicao extends Equatable {
  final int linha;
  final String motivo;
  final String? conteudo;
  final int? referenciaId;
  final int? produtoId;

  const ImportacaoProdutoRejeicao({
    required this.linha,
    required this.motivo,
    this.conteudo,
    this.referenciaId,
    this.produtoId,
  });

  factory ImportacaoProdutoRejeicao.fromJson(Map<String, dynamic> json) {
    return ImportacaoProdutoRejeicao(
      linha: (json['linha'] as num?)?.toInt() ?? 0,
      motivo: json['motivo'] as String? ?? '',
      conteudo: json['conteudo'] as String?,
      referenciaId: (json['referenciaId'] as num?)?.toInt(),
      produtoId: (json['produtoId'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props =>
      [linha, motivo, conteudo, referenciaId, produtoId];
}

// Espelha `resultado` -- "importados" cobre tanto a chave `importados`
// (completo) quanto `cadastrados` (somente).
class ImportacaoProdutoResultado extends Equatable {
  final int totalRecebidos;
  final int importados;
  final List<ImportacaoProdutoRejeicao> rejeitados;

  const ImportacaoProdutoResultado({
    required this.totalRecebidos,
    required this.importados,
    required this.rejeitados,
  });

  factory ImportacaoProdutoResultado.fromJson(Map<String, dynamic> json) {
    final rejeitados = json['rejeitados'] as List<dynamic>? ?? const [];
    return ImportacaoProdutoResultado(
      totalRecebidos: (json['totalRecebidos'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ??
          (json['cadastrados'] as num?)?.toInt() ??
          0,
      rejeitados: rejeitados
          .map((item) =>
              ImportacaoProdutoRejeicao.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totalRecebidos, importados, rejeitados];
}

// Espelha ImportacaoEntity do backend.
class ImportacaoProduto extends Equatable {
  final int id;
  final ImportacaoSituacao situacao;
  final int totalRegistros;
  final int processados;
  final int importados;
  final int rejeitados;
  final String? erro;
  final ImportacaoProdutoResultado? resultado;

  const ImportacaoProduto({
    required this.id,
    required this.situacao,
    required this.totalRegistros,
    required this.processados,
    required this.importados,
    required this.rejeitados,
    this.erro,
    this.resultado,
  });

  factory ImportacaoProduto.fromJson(Map<String, dynamic> json) {
    final resultado = json['resultado'] as Map<String, dynamic>?;
    return ImportacaoProduto(
      id: (json['id'] as num).toInt(),
      situacao: ImportacaoSituacao.fromString(json['situacao'] as String?),
      totalRegistros: (json['totalRegistros'] as num?)?.toInt() ?? 0,
      processados: (json['processados'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
      rejeitados: (json['rejeitados'] as num?)?.toInt() ?? 0,
      erro: json['erro'] as String?,
      resultado: resultado == null
          ? null
          : ImportacaoProdutoResultado.fromJson(resultado),
    );
  }

  @override
  List<Object?> get props => [
        id,
        situacao,
        totalRegistros,
        processados,
        importados,
        rejeitados,
        erro,
        resultado,
      ];
}
