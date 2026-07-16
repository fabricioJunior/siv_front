import 'package:produtos/domain/models/codigo_barras_resumo.dart';
import 'package:produtos/domain/models/pagina_codigos_de_barras.dart';

class CodigoBarrasResumoDto {
  static CodigoBarrasResumo fromJson(Map<String, dynamic> json) {
    return CodigoBarrasResumo(
      codigo: json['codigo'] as String,
      produtoId: json['produtoId'] as int,
      referenciaId: json['referenciaId'] as int?,
    );
  }
}

class MetaCodigosDeBarrasDto {
  static MetaCodigosDeBarras fromJson(Map<String, dynamic> json) {
    return MetaCodigosDeBarras(
      totalItems: json['totalItems'] as int? ?? 0,
      itemCount: json['itemCount'] as int? ?? 0,
      itemsPerPage: json['itemsPerPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
    );
  }
}

class PaginaCodigosDeBarrasDto {
  static PaginaCodigosDeBarras fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? const []);
    return PaginaCodigosDeBarras(
      meta: MetaCodigosDeBarrasDto.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
      items: itemsJson
          .map(
            (e) => CodigoBarrasResumoDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
