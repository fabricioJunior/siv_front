import 'package:comercial/domain/models/ecommerce_vitrine.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class ListaGrupoDto {
  static ListaGrupo fromJson(Map<String, dynamic> json) {
    return ListaGrupo(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      icone: json['icone']?.toString(),
      ativo: json['ativo'] != false,
      listas: (json['listas'] as List<dynamic>? ?? []).map((e) {
        final l = e as Map<String, dynamic>;
        return ListaGrupoLista(
          listaId:
              int.tryParse((l['listaId'] ?? l['id'])?.toString() ?? '') ?? 0,
          nome: (l['nome'] ?? l['titulo'] ?? '').toString(),
          icone: l['icone']?.toString(),
          ordem: int.tryParse(l['ordem']?.toString() ?? '') ?? 0,
        );
      }).toList(),
    );
  }

  static Map<String, dynamic> listasToJson(List<int> listaIds) => {
        'itens': [
          for (var i = 0; i < listaIds.length; i++)
            {'listaId': listaIds[i], 'ordem': i},
        ],
      };

  static PaginaListasGrupos paginaFromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return PaginaListasGrupos(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: int.tryParse(meta['totalPages']?.toString() ?? '') ?? 1,
    );
  }
}

class EcommerceVitrineDto {
  static EcommerceVitrine fromJson(Map<String, dynamic> json) => EcommerceVitrine(
        menu: _itens(json['menu']),
        home: _itens(json['home']),
      );

  static List<EcommerceVitrineItem> _itens(dynamic raw) {
    final itens = (raw as List<dynamic>? ?? []).map((e) {
      final i = e as Map<String, dynamic>;
      return EcommerceVitrineItem(
        tipo: i['tipo'] == 'grupo' ? VitrineItemTipo.grupo : VitrineItemTipo.lista,
        itemId: int.tryParse(i['itemId']?.toString() ?? '') ?? 0,
        ordem: int.tryParse(i['ordem']?.toString() ?? '') ?? 0,
        nome: i['nome']?.toString() ?? '',
        icone: i['icone']?.toString(),
        situacao: i['situacao']?.toString(),
      );
    }).toList();
    itens.sort((a, b) => a.ordem.compareTo(b.ordem));
    return itens;
  }

  static Map<String, dynamic> itensToJson(List<EcommerceVitrineItem> itens) => {
        'itens': [
          for (final i in itens)
            {'tipo': i.tipo.name, 'itemId': i.itemId, 'ordem': i.ordem},
        ],
      };
}
