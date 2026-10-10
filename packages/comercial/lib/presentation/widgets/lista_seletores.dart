import 'package:core/seletores.dart';

/// Seletores montados em `routes.dart` e usados pelo formulário/filtro de
/// listas do catálogo (comercial não importa produtos/promocoes).
class ListaSeletores {
  final SeletorWidget tabelaDePreco;
  final SeletorWidget categoria;
  final SeletorPorCategoriasWidget subCategoria;
  final SeletorWidget tamanho;
  final SeletorWidget cor;
  final SeletorWidget promocao;

  const ListaSeletores({
    required this.tabelaDePreco,
    required this.categoria,
    required this.subCategoria,
    required this.tamanho,
    required this.cor,
    required this.promocao,
  });
}
