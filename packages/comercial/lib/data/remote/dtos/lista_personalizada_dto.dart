import 'package:comercial/domain/models/lista_personalizada.dart';

class ListaPersonalizadaDto {
  static ListaPersonalizada fromJson(Map<String, dynamic> json) {
    return ListaPersonalizada(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      hash: json['hash']?.toString() ?? '',
      tabelaPrecoId: int.tryParse(json['tabelaPrecoId']?.toString() ?? '') ?? 0,
      dataExpiracao:
          DateTime.tryParse(json['dataExpiracao']?.toString() ?? '') ?? DateTime.now(),
      situacao: situacaoDeJson(json['situacao']?.toString()),
      itens: (json['itens'] as List<dynamic>? ?? [])
          .map((item) => _item(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static ListaPersonalizadaItem _item(Map<String, dynamic> json) {
    return ListaPersonalizadaItem(
      referenciaId: int.tryParse(json['referenciaId']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      valor: num.tryParse(json['valor']?.toString() ?? '') ?? 0,
      imagemUrl: json['imagemUrl']?.toString(),
    );
  }

}

ListaPersonalizadaSituacao situacaoDeJson(String? valor) {
  switch (valor) {
    case 'cancelada':
      return ListaPersonalizadaSituacao.cancelada;
    case 'expirada':
      return ListaPersonalizadaSituacao.expirada;
    default:
      return ListaPersonalizadaSituacao.ativa;
  }
}
