import 'package:comercial/data/remote/dtos/lista_personalizada_dto.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

class ListaPersonalizadaResumoDto {
  static ListaPersonalizadaResumo fromJson(Map<String, dynamic> json) {
    return ListaPersonalizadaResumo(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      hash: json['hash']?.toString() ?? '',
      situacao: situacaoDeJson(json['situacao']?.toString()),
      dataExpiracao:
          DateTime.tryParse(json['dataExpiracao']?.toString() ?? '') ?? DateTime.now(),
      quantidadeItens: int.tryParse(json['quantidadeItens']?.toString() ?? '') ?? 0,
      criadoEm: DateTime.tryParse(json['criadoEm']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PaginaListasPersonalizadasDto {
  static PaginaListasPersonalizadas fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((item) => ListaPersonalizadaResumoDto.fromJson(item as Map<String, dynamic>))
        .toList();
    return PaginaListasPersonalizadas(
      items: items,
      meta: MetaListasPersonalizadas(
        totalItems: (meta['totalItems'] as num).toInt(),
        itemCount: (meta['itemCount'] as num).toInt(),
        itemsPerPage: (meta['itemsPerPage'] as num).toInt(),
        totalPages: (meta['totalPages'] as num).toInt(),
        currentPage: (meta['currentPage'] as num).toInt(),
      ),
    );
  }
}
