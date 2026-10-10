enum VitrineLocal { menu, home }

enum VitrineItemTipo { lista, grupo }

class EcommerceVitrineItem {
  final VitrineItemTipo tipo;
  final int itemId;
  final int ordem;
  final String nome;
  final String? icone;
  final String? situacao;

  const EcommerceVitrineItem({
    required this.tipo,
    required this.itemId,
    required this.ordem,
    required this.nome,
    this.icone,
    this.situacao,
  });

  EcommerceVitrineItem comOrdem(int novaOrdem) => EcommerceVitrineItem(
        tipo: tipo,
        itemId: itemId,
        ordem: novaOrdem,
        nome: nome,
        icone: icone,
        situacao: situacao,
      );
}

class EcommerceVitrine {
  final List<EcommerceVitrineItem> menu;
  final List<EcommerceVitrineItem> home;

  const EcommerceVitrine({this.menu = const [], this.home = const []});

  List<EcommerceVitrineItem> doLocal(VitrineLocal local) =>
      local == VitrineLocal.menu ? menu : home;
}
