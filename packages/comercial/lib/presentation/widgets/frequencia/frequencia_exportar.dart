import 'dart:convert';
import 'dart:typed_data';

import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_linha_detalhe.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';

/// Percorre todas as páginas (200 por vez) com o filtro e a ordenação de [s].
Future<List<FrequenciaClienteItem>> buscarTodosFrequenciaClientes(
  GetRelatorioFrequenciaClientes useCase,
  RelatorioFrequenciaClientesState s,
  List<int> empresaIds,
) async {
  final todos = <FrequenciaClienteItem>[];
  var pagina = 1;
  late int total;
  do {
    final r = await useCase.call(
      empresaIds: empresaIds,
      dataInicial: frequenciaIso(s.inicio),
      dataFinal: frequenciaIso(s.fim),
      funcionarioIds: s.funcionarioIds.isEmpty ? null : s.funcionarioIds,
      categoriaIds: s.categoriaIds.isEmpty ? null : s.categoriaIds,
      classe: s.classe,
      atrasados: s.atrasados,
      busca: s.busca.isEmpty ? null : s.busca,
      ordenarPor: s.ordenarPor,
      ordem: s.ordem,
      page: pagina,
      limit: 200,
    );
    todos.addAll(r.items);
    total = r.meta.totalPages;
    pagina++;
  } while (pagina <= total);
  return todos;
}

String _campo(String v) =>
    v.contains(',') || v.contains('"') || v.contains('\n') ? '"${v.replaceAll('"', '""')}"' : v;

String _num(num v) => v.toStringAsFixed(2).replaceAll('.', ',');

/// CSV (BOM UTF-8, separador vírgula) com as colunas da tabela.
String frequenciaCsv(List<FrequenciaClienteItem> items) {
  String l(List<String> c) => c.map(_campo).join(',');
  return [
    l([
      '#',
      'Cliente',
      'Telefone',
      'Classe',
      'Visitas',
      'Última compra',
      'Dias desde a última',
      'Compra a cada (dias)',
      'Valor acumulado',
      'Ticket médio',
      '% acumulado',
      'Atrasado',
    ]),
    for (final i in items)
      l([
        '${i.rank}',
        i.nome,
        i.telefone ?? '',
        i.classe,
        '${i.visitas}',
        i.ultimaCompra == null ? '' : frequenciaDataCurta(i.ultimaCompra),
        '${i.diasDesdeUltima}',
        i.intervaloMedioDias == null ? '' : _num(i.intervaloMedioDias!),
        _num(i.valor),
        _num(i.ticketMedio),
        _num(i.percentualAcumulado),
        i.atrasado ? 'Sim' : 'Não',
      ]),
  ].join('\r\n');
}

/// Busca todas as páginas e abre o "Salvar como". Retorna (destino, total).
Future<(String?, int)> exportarFrequenciaCsv(RelatorioFrequenciaClientesState s) async {
  final empresas = frequenciaEmpresas(s);
  if (empresas.isEmpty) throw StateError('Empresa não selecionada.');
  final items = await buscarTodosFrequenciaClientes(
    sl<GetRelatorioFrequenciaClientes>(),
    s,
    empresas,
  );
  final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(frequenciaCsv(items))]);
  final destino = await sl<ArquivoService>().salvarBytes(
    bytes: bytes,
    nomeSugerido: 'frequencia_clientes.csv',
  );
  return (destino, items.length);
}
