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

// Espelha item de `resultado.rejeitados` do backend.
class ImportacaoPromocaoRejeicao extends Equatable {
  final int numeroLinha;
  final String referenciaIdExterno;
  final String motivo;

  const ImportacaoPromocaoRejeicao({
    required this.numeroLinha,
    required this.referenciaIdExterno,
    required this.motivo,
  });

  factory ImportacaoPromocaoRejeicao.fromJson(Map<String, dynamic> json) {
    return ImportacaoPromocaoRejeicao(
      numeroLinha: (json['numeroLinha'] as num).toInt(),
      referenciaIdExterno: json['referenciaIdExterno'] as String? ?? '',
      motivo: json['motivo'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [numeroLinha, referenciaIdExterno, motivo];
}

// Espelha item de `resultado.promocoesCriadas` do backend.
class ImportacaoPromocaoCriada extends Equatable {
  final int id;
  final String nome;
  final double valorPercentual;
  final int quantidadeReferencias;

  const ImportacaoPromocaoCriada({
    required this.id,
    required this.nome,
    required this.valorPercentual,
    required this.quantidadeReferencias,
  });

  factory ImportacaoPromocaoCriada.fromJson(Map<String, dynamic> json) {
    return ImportacaoPromocaoCriada(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String? ?? '',
      valorPercentual: (json['valorPercentual'] as num?)?.toDouble() ?? 0,
      quantidadeReferencias:
          (json['quantidadeReferencias'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, nome, valorPercentual, quantidadeReferencias];
}

// Espelha o objeto `resultado` do backend -- só populado quando
// situacao='concluida'.
class ImportacaoPromocaoResultado extends Equatable {
  final int totalRecebidos;
  final int importados;
  final List<ImportacaoPromocaoRejeicao> rejeitados;
  final List<ImportacaoPromocaoCriada> promocoesCriadas;

  const ImportacaoPromocaoResultado({
    required this.totalRecebidos,
    required this.importados,
    required this.rejeitados,
    required this.promocoesCriadas,
  });

  factory ImportacaoPromocaoResultado.fromJson(Map<String, dynamic> json) {
    final rejeitados = json['rejeitados'] as List<dynamic>? ?? const [];
    final promocoesCriadas =
        json['promocoesCriadas'] as List<dynamic>? ?? const [];
    return ImportacaoPromocaoResultado(
      totalRecebidos: (json['totalRecebidos'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
      rejeitados: rejeitados
          .map((item) =>
              ImportacaoPromocaoRejeicao.fromJson(item as Map<String, dynamic>))
          .toList(),
      promocoesCriadas: promocoesCriadas
          .map((item) =>
              ImportacaoPromocaoCriada.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [totalRecebidos, importados, rejeitados, promocoesCriadas];
}

// Espelha ImportacaoEntity do backend.
class ImportacaoPromocao extends Equatable {
  final int id;
  final ImportacaoSituacao situacao;
  final int totalRegistros;
  final int processados;
  final int importados;
  final int rejeitados;
  final String? erro;
  final ImportacaoPromocaoResultado? resultado;

  const ImportacaoPromocao({
    required this.id,
    required this.situacao,
    required this.totalRegistros,
    required this.processados,
    required this.importados,
    required this.rejeitados,
    this.erro,
    this.resultado,
  });

  factory ImportacaoPromocao.fromJson(Map<String, dynamic> json) {
    final resultado = json['resultado'] as Map<String, dynamic>?;
    return ImportacaoPromocao(
      id: (json['id'] as num).toInt(),
      situacao: ImportacaoSituacao.fromString(json['situacao'] as String?),
      totalRegistros: (json['totalRegistros'] as num?)?.toInt() ?? 0,
      processados: (json['processados'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
      rejeitados: (json['rejeitados'] as num?)?.toInt() ?? 0,
      erro: json['erro'] as String?,
      resultado: resultado == null
          ? null
          : ImportacaoPromocaoResultado.fromJson(resultado),
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
