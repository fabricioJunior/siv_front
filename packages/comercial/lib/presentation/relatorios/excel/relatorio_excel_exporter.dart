import 'package:comercial/domain/models/relatorios.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';

String _fmtData(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final p = iso.split('-');
  return p.length < 3 ? iso : '${p[2]}/${p[1]}/${p[0]}';
}

class RelatorioExcelExporter {
  RelatorioExcelExporter._();

  static const cabecalhoAniversariantes = [
    'Nome',
    'Documento',
    'E-mail',
    'Telefone',
    'Nascimento',
    'Última compra',
  ];

  static List<List<Object?>> linhasAniversariantes(
    List<RelatorioClienteAniversarianteItem> items,
  ) =>
      [
        cabecalhoAniversariantes,
        for (final item in items)
          [
            item.nome,
            item.documento,
            item.email ?? '',
            item.contato ?? '',
            _fmtData(item.nascimento),
            _fmtData(item.dataUltimaCompra),
          ],
      ];

  /// Gera o `.xlsx` e salva pelo [ArquivoService] (diálogo no desktop/celular, download na web).
  static Future<String?> exportarAniversariantes(
    List<RelatorioClienteAniversarianteItem> items,
  ) {
    final bytes = sl<PlanilhaService>().gerarXlsx(
      nomeAba: 'Aniversariantes',
      linhas: linhasAniversariantes(items),
    );
    return sl<ArquivoService>().salvarBytes(
      bytes: bytes,
      nomeSugerido: 'clientes_aniversariantes.xlsx',
    );
  }
}
