import 'package:comercial/domain/models/importacao_pedido_transferencia.dart'
    show ImportacaoSituacao;
import 'package:core/equals.dart';

// Venda do CSV que não foi importada (as demais seguem). Espelha o `rejeitados`
// do resultado de ImportacaoVendaService no backend.
class ImportacaoVendaRejeitada extends Equatable {
  final int numeroVendaExterno;
  final String motivo;

  const ImportacaoVendaRejeitada({
    required this.numeroVendaExterno,
    required this.motivo,
  });

  factory ImportacaoVendaRejeitada.fromJson(Map<String, dynamic> json) {
    return ImportacaoVendaRejeitada(
      numeroVendaExterno: (json['numeroVendaExterno'] as num?)?.toInt() ?? 0,
      motivo: json['motivo'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [numeroVendaExterno, motivo];
}

// totalRecebidos/importados contam VENDAS (não linhas do CSV).
class ImportacaoVendaResultado extends Equatable {
  final int totalRecebidos;
  final int importados;
  final int itensImportados;
  final List<ImportacaoVendaRejeitada> rejeitados;

  const ImportacaoVendaResultado({
    required this.totalRecebidos,
    required this.importados,
    this.itensImportados = 0,
    this.rejeitados = const [],
  });

  factory ImportacaoVendaResultado.fromJson(Map<String, dynamic> json) {
    return ImportacaoVendaResultado(
      totalRecebidos: (json['totalRecebidos'] as num?)?.toInt() ?? 0,
      importados: (json['importados'] as num?)?.toInt() ?? 0,
      itensImportados: (json['itensImportados'] as num?)?.toInt() ?? 0,
      rejeitados: (json['rejeitados'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ImportacaoVendaRejeitada.fromJson)
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props =>
      [totalRecebidos, importados, itensImportados, rejeitados];
}

// Espelha ImportacaoEntity do backend.
class ImportacaoVenda extends Equatable {
  final int id;
  final ImportacaoSituacao situacao;
  final String? erro;
  final ImportacaoVendaResultado? resultado;

  const ImportacaoVenda({
    required this.id,
    required this.situacao,
    this.erro,
    this.resultado,
  });

  factory ImportacaoVenda.fromJson(Map<String, dynamic> json) {
    final resultado = json['resultado'] as Map<String, dynamic>?;
    return ImportacaoVenda(
      id: (json['id'] as num).toInt(),
      situacao: ImportacaoSituacao.fromString(json['situacao'] as String?),
      erro: json['erro'] as String?,
      resultado:
          resultado == null ? null : ImportacaoVendaResultado.fromJson(resultado),
    );
  }

  @override
  List<Object?> get props => [id, situacao, erro, resultado];
}
