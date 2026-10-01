import 'package:comercial/domain/models/relatorios.dart';

/// Percorre todas as páginas do relatório de aniversariantes (a tela mostra uma página de 100 por
/// vez). A exportação precisa do relatório inteiro, não só da página aberta.
Future<List<RelatorioClienteAniversarianteItem>> buscarTodosAniversariantes(
  Future<RelatorioClientesAniversariantes> Function(int page) buscarPagina,
) async {
  final todos = <RelatorioClienteAniversarianteItem>[];
  var pagina = 1;
  late int totalPaginas;
  do {
    final dados = await buscarPagina(pagina);
    todos.addAll(dados.items);
    totalPaginas = dados.meta.totalPages;
    pagina++;
  } while (pagina <= totalPaginas);
  return todos;
}
