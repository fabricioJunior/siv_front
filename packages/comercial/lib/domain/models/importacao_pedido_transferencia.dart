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

class ImportacaoPedidoTransferenciaResultado extends Equatable {
  final int totalRecebidos;
  final int importados;

  const ImportacaoPedidoTransferenciaResultado({
    required this.totalRecebidos,
    required this.importados,
  });

  factory ImportacaoPedidoTransferenciaResultado.fromJson(
    Map<String, dynamic> json,
  ) {
    return ImportacaoPedidoTransferenciaResultado(
      totalRecebidos: (json['totalRecebidos'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalRecebidos, importados];
}

// Espelha ImportacaoEntity do backend.
class ImportacaoPedidoTransferencia extends Equatable {
  final int id;
  final ImportacaoSituacao situacao;
  final int totalRegistros;
  final int processados;
  final int importados;
  final int rejeitados;
  final String? erro;
  final ImportacaoPedidoTransferenciaResultado? resultado;

  const ImportacaoPedidoTransferencia({
    required this.id,
    required this.situacao,
    required this.totalRegistros,
    required this.processados,
    required this.importados,
    required this.rejeitados,
    this.erro,
    this.resultado,
  });

  factory ImportacaoPedidoTransferencia.fromJson(Map<String, dynamic> json) {
    final resultado = json['resultado'] as Map<String, dynamic>?;
    return ImportacaoPedidoTransferencia(
      id: (json['id'] as num).toInt(),
      situacao: ImportacaoSituacao.fromString(json['situacao'] as String?),
      totalRegistros: (json['totalRegistros'] as num?)?.toInt() ?? 0,
      processados: (json['processados'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
      rejeitados: (json['rejeitados'] as num?)?.toInt() ?? 0,
      erro: json['erro'] as String?,
      resultado: resultado == null
          ? null
          : ImportacaoPedidoTransferenciaResultado.fromJson(resultado),
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
