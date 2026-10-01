import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/relatorios/aniversariantes_todas_as_paginas.dart';
import 'package:comercial/presentation/relatorios/excel/relatorio_excel_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

class _Item implements RelatorioClienteAniversarianteItem {
  @override
  final int pessoaId;
  @override
  final String nome;
  @override
  final String documento;
  @override
  final String? email;
  @override
  final String? contato;
  @override
  final String nascimento;
  @override
  final String? dataUltimaCompra;

  _Item(this.pessoaId, {this.email, this.contato, this.dataUltimaCompra})
      : nome = 'Cliente $pessoaId',
        documento = '000$pessoaId',
        nascimento = '1987-10-01';
}

class _Meta implements RelatorioClienteAniversarianteMeta {
  @override
  final int totalItems;
  @override
  final int currentPage;
  @override
  final int totalPages;
  _Meta(this.totalItems, this.currentPage, this.totalPages);

  @override
  int get itemsPerPage => 2;
  @override
  int get itemCount => 2;
}

class _Pagina implements RelatorioClientesAniversariantes {
  @override
  final List<RelatorioClienteAniversarianteItem> items;
  @override
  final RelatorioClienteAniversarianteMeta meta;
  _Pagina(this.items, this.meta);
}

void main() {
  group('buscarTodosAniversariantes', () {
    test('percorre todas as páginas e junta os itens na ordem (a tela só tem 100 por vez)', () async {
      final paginas = <int>[];
      final todos = await buscarTodosAniversariantes((pagina) async {
        paginas.add(pagina);
        final inicio = (pagina - 1) * 2;
        final ids = [for (var i = inicio + 1; i <= inicio + 2 && i <= 5; i++) i];
        return _Pagina([for (final id in ids) _Item(id)], _Meta(5, pagina, 3));
      });

      expect(paginas, [1, 2, 3]);
      expect(todos.map((i) => i.pessoaId), [1, 2, 3, 4, 5]);
    });

    test('relatório de uma página só faz uma chamada', () async {
      var chamadas = 0;
      final todos = await buscarTodosAniversariantes((pagina) async {
        chamadas++;
        return _Pagina([_Item(1)], _Meta(1, 1, 1));
      });

      expect(chamadas, 1);
      expect(todos, hasLength(1));
    });

    test('relatório vazio (totalPages 0) devolve lista vazia sem entrar em loop', () async {
      var chamadas = 0;
      final todos = await buscarTodosAniversariantes((pagina) async {
        chamadas++;
        return _Pagina(const [], _Meta(0, 1, 0));
      });

      expect(chamadas, 1);
      expect(todos, isEmpty);
    });

    test('erro numa página propaga (a tela mostra "Falha ao exportar")', () async {
      expect(
        buscarTodosAniversariantes((pagina) async => throw StateError('falhou na página $pagina')),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('RelatorioExcelExporter.linhasAniversariantes', () {
    test('cabeçalho + uma linha por cliente, datas em DD/MM/AAAA e vazios como texto vazio', () {
      final linhas = RelatorioExcelExporter.linhasAniversariantes([
        _Item(7, email: 'a@b.com', contato: '86 99999-0000', dataUltimaCompra: '2026-08-11'),
        _Item(8),
      ]);

      expect(linhas, [
        ['Nome', 'Documento', 'E-mail', 'Telefone', 'Nascimento', 'Última compra'],
        ['Cliente 7', '0007', 'a@b.com', '86 99999-0000', '01/10/1987', '11/08/2026'],
        ['Cliente 8', '0008', '', '', '01/10/1987', ''],
      ]);
    });
  });
}
