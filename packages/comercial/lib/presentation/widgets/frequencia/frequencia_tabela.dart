import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_linha_detalhe.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _colunas = <RelatorioColuna>[
  RelatorioColuna(id: 'rank', titulo: '#', flex: 4),
  RelatorioColuna(id: 'nome', titulo: 'Cliente', flex: 24),
  RelatorioColuna(id: 'classe', titulo: 'Classe', flex: 7),
  RelatorioColuna(id: 'visitas', titulo: 'Visitas', numerica: true, flex: 7),
  RelatorioColuna(id: 'ultimaCompra', titulo: 'Última compra', flex: 14),
  RelatorioColuna(id: 'intervalo', titulo: 'Compra a cada', numerica: true, flex: 11),
  RelatorioColuna(id: 'valor', titulo: 'Valor acumulado', numerica: true, flex: 13),
  RelatorioColuna(id: 'ticketMedio', titulo: 'Ticket médio', numerica: true, flex: 11),
  RelatorioColuna(id: 'percentualAcumulado', titulo: '% acumulado', numerica: true, flex: 10),
];

const _gap = 12.0;
const _larguraChevron = 18.0;
const _padH = 22.0;

/// Rodapé: `{n} clientes [classe A | atrasados (exibindo classe A)] · página p de n`.
String frequenciaRodape(RelatorioFrequenciaClientesState s, {bool pagina = true}) {
  final n = s.meta.totalItems;
  final String base;
  if (s.atrasados) {
    base = '$n clientes atrasados${s.classe == null ? '' : ' (exibindo classe ${s.classe})'}';
  } else if (s.classe != null) {
    base = '$n clientes classe ${s.classe}';
  } else {
    base = '$n clientes';
  }
  return pagina ? '$base · página ${s.page} de ${s.totalPages}' : base;
}

Widget _blocoEsqueleto(BuildContext context, double h) => Container(
      height: h,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.sivColors.hairline,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
    );

/// Esqueleto de 10 linhas da lista.
class FrequenciaListaEsqueleto extends StatelessWidget {
  const FrequenciaListaEsqueleto({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [for (var i = 0; i < 10; i++) _blocoEsqueleto(context, 44)],
      );
}

/// Tabela desktop com linha expansível. Ordenação é do servidor.
class FrequenciaTabela extends StatefulWidget {
  final RelatorioFrequenciaClientesState state;
  final ValueChanged<String> onOrdenar;
  final ValueChanged<int> onAlternar;
  final Widget? rodape;
  const FrequenciaTabela({
    super.key,
    required this.state,
    required this.onOrdenar,
    required this.onAlternar,
    this.rodape,
  });

  @override
  State<FrequenciaTabela> createState() => _FrequenciaTabelaState();
}

class _FrequenciaTabelaState extends State<FrequenciaTabela> {
  late final FrequenciaComprasCache _cache;

  @override
  void initState() {
    super.initState();
    _cache = FrequenciaComprasCache(
      (id) => frequenciaBuscarCompras(widget.state, id),
    );
  }

  @override
  void didUpdateWidget(FrequenciaTabela old) {
    super.didUpdateWidget(old);
    final a = old.state;
    final b = widget.state;
    if (a.inicio != b.inicio ||
        a.fim != b.fim ||
        !listEquals(a.empresaIds, b.empresaIds)) {
      _cache.limpar();
    }
  }

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final s = widget.state;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: c.superficie,
            border: Border.all(color: c.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _linha(
                _colunas.map((col) => _cabecalho(context, col)).toList(),
                const SizedBox(width: _larguraChevron),
              ),
              for (final i in s.items) _item(context, i),
              if (widget.rodape != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: _padH, vertical: 12),
                  child: widget.rodape,
                ),
            ],
          ),
        ),
        ...sivCantosBlueprint(c.aco.withValues(alpha: 0.4)),
      ],
    );
  }

  Widget _linha(List<Widget> celulas, Widget chevron) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padH, vertical: 11),
        child: Row(
          children: [
            for (var k = 0; k < _colunas.length; k++) ...[
              if (k > 0) const SizedBox(width: _gap),
              Expanded(
                flex: _colunas[k].flex,
                child: Align(
                  alignment: _colunas[k].numerica
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: celulas[k],
                ),
              ),
            ],
            const SizedBox(width: _gap),
            chevron,
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context, RelatorioColuna col) {
    final c = context.sivColors;
    final ativa = col.id == widget.state.ordenarPor;
    final asc = widget.state.ordem == 'asc';
    return InkWell(
      key: ValueKey('frequencia-ordenar-${col.id}'),
      onTap: () => widget.onOrdenar(col.id),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              col.titulo.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.sivTextos.apoio.copyWith(
                fontFamily: sivFonteCondensed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: c.acoAtivo,
              ),
            ),
          ),
          if (ativa)
            Icon(asc ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: c.aco),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, FrequenciaClienteItem i) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final aberta = widget.state.linhasAbertas.contains(i.clienteId);
    final apoio = t.apoio.copyWith(fontSize: 11.5, color: c.textoApoio);
    final corpo = t.apoio.copyWith(fontSize: 13.5, color: c.tinta);
    final ha = frequenciaHa(i.diasDesdeUltima);
    final celulas = <Widget>[
      Text('${i.rank}', style: t.apoio.copyWith(fontFamily: sivFonteCondensed, fontSize: 15, color: c.textoApoio)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            i.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: corpo.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(frequenciaSub(i), maxLines: 1, overflow: TextOverflow.ellipsis, style: apoio),
        ],
      ),
      FrequenciaTag(i.classe),
      Text('${i.visitas}', style: corpo.copyWith(fontWeight: FontWeight.w600)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(frequenciaDataCurta(i.ultimaCompra), style: corpo),
          Text.rich(
            TextSpan(
              text: ha,
              children: [
                if (i.atrasado)
                  TextSpan(text: ' · atrasado', style: TextStyle(color: c.atencao)),
              ],
            ),
            style: apoio,
          ),
        ],
      ),
      Text(
        i.intervaloMedioDias == null ? '—' : frequenciaDias(i.intervaloMedioDias!),
        style: corpo,
      ),
      Text(frequenciaMoeda(i.valor), style: t.valor.copyWith(fontSize: 17, color: c.tinta)),
      Text(frequenciaMoeda(i.ticketMedio), style: corpo),
      Text(frequenciaPct(i.percentualAcumulado), style: corpo.copyWith(color: c.tinta.withValues(alpha: 0.7))),
    ];
    return Container(
      key: ValueKey('frequencia-linha-${i.clienteId}'),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.hairline))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: aberta ? c.selecaoFundo : c.superficie,
            child: InkWell(
              hoverColor: c.selecaoFundo,
              onTap: () => widget.onAlternar(i.clienteId),
              child: _linha(
                celulas,
                AnimatedRotation(
                  turns: aberta ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more, size: 18, color: c.textoApoio),
                ),
              ),
            ),
          ),
          if (aberta) FrequenciaDetalhe(item: i, cache: _cache),
        ],
      ),
    );
  }
}
