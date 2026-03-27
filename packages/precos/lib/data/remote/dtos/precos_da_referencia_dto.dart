import 'preco_da_referencia_dto.dart';

class PrecosDaReferenciaDto {
  final List<PrecoDaReferenciaDto> items;
  final PaginacaoDto meta;

  PrecosDaReferenciaDto({required this.items, required this.meta});

  factory PrecosDaReferenciaDto.fromJson(Map<String, dynamic> json) {
    return PrecosDaReferenciaDto(
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PrecoDaReferenciaDto.fromJson)
          .toList(),
      meta: PaginacaoDto.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList(), ...meta.toJson()};
  }
}

class PaginacaoDto {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const PaginacaoDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginacaoDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse((value ?? '').toString()) ?? 0;
    }

    return PaginacaoDto(
      totalItems: parseInt(json['totalItems']),
      itemCount: parseInt(json['itemCount']),
      itemsPerPage: parseInt(json['itemsPerPage']),
      totalPages: parseInt(json['totalPages']),
      currentPage: parseInt(json['currentPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'itemCount': itemCount,
      'itemsPerPage': itemsPerPage,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }
}
