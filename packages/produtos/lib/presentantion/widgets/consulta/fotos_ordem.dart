/// Move o item de [de] para [para] (índice final) e devolve a nova lista de ids.
List<int> reordenarIds(List<int> ids, int de, int para) {
  final novo = [...ids];
  final id = novo.removeAt(de);
  novo.insert(para.clamp(0, novo.length), id);
  return novo;
}
