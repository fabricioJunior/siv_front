import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:core/arquivos.dart';
import 'package:flutter_test/flutter_test.dart';

String _parte(Archive zip, String caminho) =>
    utf8.decode(zip.findFile(caminho)!.content as List<int>);

void main() {
  final service = PlanilhaService();

  test('gera um pacote xlsx com as partes obrigatórias', () {
    final bytes = service.gerarXlsx(nomeAba: 'Aniversariantes', linhas: [
      ['Nome', 'Qtd'],
      ['Ana', 3],
    ]);

    final zip = ZipDecoder().decodeBytes(bytes);
    for (final parte in [
      '[Content_Types].xml',
      '_rels/.rels',
      'xl/workbook.xml',
      'xl/_rels/workbook.xml.rels',
      'xl/styles.xml',
      'xl/worksheets/sheet1.xml',
    ]) {
      expect(zip.findFile(parte), isNotNull, reason: parte);
    }
    expect(_parte(zip, 'xl/workbook.xml'), contains('name="Aniversariantes"'));
  });

  test('cabeçalho em negrito, número como número, texto escapado e sem caractere de controle', () {
    final zip = ZipDecoder().decodeBytes(service.gerarXlsx(nomeAba: 'X', linhas: [
      ['Nome', 'Valor'],
      ['Ana & <Cia> "x"\u0001', 12.5],
      [null, 7],
    ]));
    final sheet = _parte(zip, 'xl/worksheets/sheet1.xml');

    expect(sheet, contains('<c r="A1" s="1" t="inlineStr">'));
    expect(sheet, contains('Ana &amp; &lt;Cia&gt; &quot;x&quot;</t>'));
    expect(sheet, contains('<c r="B2"><v>12.5</v></c>'));
    expect(sheet, contains('<row r="3"><c r="B3"><v>7</v></c></row>')); // null não gera célula
  });

  test('referência de coluna passa de Z para AA', () {
    final linha = List<Object?>.generate(28, (i) => 'c$i');
    final zip = ZipDecoder().decodeBytes(service.gerarXlsx(nomeAba: 'X', linhas: [linha]));
    final sheet = _parte(zip, 'xl/worksheets/sheet1.xml');

    expect(sheet, contains('<c r="Z1"'));
    expect(sheet, contains('<c r="AA1"'));
    expect(sheet, contains('<c r="AB1"'));
  });

  test('nome da aba é saneado (31 caracteres, sem []:*?/\\)', () {
    final zip = ZipDecoder().decodeBytes(service.gerarXlsx(
      nomeAba: 'Relatório [de] clientes: aniversariantes do mês de outubro',
      linhas: [
        ['a']
      ],
    ));
    final nome = RegExp(r'name="([^"]*)"').firstMatch(_parte(zip, 'xl/workbook.xml'))!.group(1)!;

    expect(nome.length, lessThanOrEqualTo(31));
    expect(nome, isNot(contains(RegExp(r'[\[\]:*?/\\]'))));
  });

  test('grava o arquivo quando PLANILHA_OUT está definido (validação externa com openpyxl)', () {
    final saida = Platform.environment['PLANILHA_OUT'];
    if (saida == null) return;
    File(saida).writeAsBytesSync(service.gerarXlsx(nomeAba: 'Aniversariantes', linhas: [
      ['Nome', 'Documento', 'Nascimento', 'Qtd'],
      ['DENISE PATRICIA LOPES COIMBRA', '02739834314', '01/10/1987', 2],
      ['Ana & <Cia> "x"', null, '', 10.5],
    ]));
  });
}
