import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Gera planilhas `.xlsx` (uma aba) -- wrapper fino sobre `archive` (ver convenção do projeto).
///
/// O pacote `excel` não resolve junto com `pdf`/`flutter_zpl_generator` (conflito de `xml`), e um
/// `.xlsx` é só um ZIP com alguns XMLs: aqui só o necessário -- cabeçalho em negrito, números como
/// número (somam/ordenam no Excel), demais valores como texto e largura de coluna pelo conteúdo.
class PlanilhaService {
  /// [linhas]: a primeira é o cabeçalho (negrito). Valores `num` viram número; `null` fica vazio;
  /// qualquer outro tipo vira texto (`toString()`).
  Uint8List gerarXlsx({
    required String nomeAba,
    required List<List<Object?>> linhas,
  }) {
    final arquivo = Archive()
      ..addFile(_texto('[Content_Types].xml', _contentTypes))
      ..addFile(_texto('_rels/.rels', _relsRaiz))
      ..addFile(_texto('xl/workbook.xml', _workbook(_nomeAbaValido(nomeAba))))
      ..addFile(_texto('xl/_rels/workbook.xml.rels', _relsWorkbook))
      ..addFile(_texto('xl/styles.xml', _styles))
      ..addFile(_texto('xl/worksheets/sheet1.xml', _planilha(linhas)));

    return Uint8List.fromList(ZipEncoder().encode(arquivo));
  }

  ArchiveFile _texto(String caminho, String conteudo) {
    final bytes = utf8.encode(conteudo);
    return ArchiveFile(caminho, bytes.length, bytes);
  }

  // Aba: até 31 caracteres, sem []:*?/\ e não vazia.
  String _nomeAbaValido(String nome) {
    final limpo = nome.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
    if (limpo.isEmpty) return 'Planilha';
    return limpo.length > 31 ? limpo.substring(0, 31) : limpo;
  }

  String _planilha(List<List<Object?>> linhas) {
    final colunas = linhas.fold<int>(0, (m, l) => l.length > m ? l.length : m);
    final larguras = List<double>.filled(colunas, 8);
    for (final linha in linhas) {
      for (var c = 0; c < linha.length; c++) {
        final tamanho = (linha[c]?.toString().length ?? 0) + 2.0;
        if (tamanho > larguras[c]) larguras[c] = tamanho > 60 ? 60 : tamanho;
      }
    }

    final buffer = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    );
    if (colunas > 0) {
      buffer.write('<cols>');
      for (var c = 0; c < colunas; c++) {
        buffer.write(
          '<col min="${c + 1}" max="${c + 1}" width="${larguras[c]}" customWidth="1"/>',
        );
      }
      buffer.write('</cols>');
    }

    buffer.write('<sheetData>');
    for (var l = 0; l < linhas.length; l++) {
      buffer.write('<row r="${l + 1}">');
      for (var c = 0; c < linhas[l].length; c++) {
        final valor = linhas[l][c];
        if (valor == null) continue;
        final ref = '${_coluna(c)}${l + 1}';
        final estilo = l == 0 ? ' s="1"' : '';
        if (valor is num && valor.isFinite) {
          buffer.write('<c r="$ref"$estilo><v>$valor</v></c>');
        } else {
          buffer.write(
            '<c r="$ref"$estilo t="inlineStr"><is>'
            '<t xml:space="preserve">${_escapar(valor.toString())}</t></is></c>',
          );
        }
      }
      buffer.write('</row>');
    }
    buffer.write('</sheetData></worksheet>');
    return buffer.toString();
  }

  // 0 -> A, 25 -> Z, 26 -> AA ...
  String _coluna(int indice) {
    var n = indice + 1;
    final letras = StringBuffer();
    while (n > 0) {
      final resto = (n - 1) % 26;
      letras.write(String.fromCharCode(65 + resto));
      n = (n - 1) ~/ 26;
    }
    return letras.toString().split('').reversed.join();
  }

  // Escapa XML e descarta caracteres de controle (inválidos em XML 1.0 -- o Excel recusa o arquivo).
  String _escapar(String valor) {
    final semControle = valor.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
      '',
    );
    return semControle
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  String _workbook(String nomeAba) =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="${_escapar(nomeAba)}" sheetId="1" r:id="rId1"/></sheets></workbook>';

  static const _contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
      '</Types>';

  static const _relsRaiz =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
      '</Relationships>';

  static const _relsWorkbook =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '</Relationships>';

  // Estilo 0 = normal, 1 = negrito (cabeçalho).
  static const _styles =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
      '<fills count="2"><fill><patternFill patternType="none"/></fill>'
      '<fill><patternFill patternType="gray125"/></fill></fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
      '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
      '</styleSheet>';
}
