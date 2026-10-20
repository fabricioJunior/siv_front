import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_linha_detalhe.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lista mobile de cartões blueprint expansíveis (paginação infinita no bloc).
class FrequenciaCartoesMobile extends StatefulWidget {
  final RelatorioFrequenciaClientesState state;
  final ValueChanged<int> onAlternar;
  const FrequenciaCartoesMobile({super.key, required this.state, required this.onAlternar});

  @override
  State<FrequenciaCartoesMobile> createState() => _FrequenciaCartoesMobileState();
}

class _FrequenciaCartoesMobileState extends State<FrequenciaCartoesMobile> {
  late final FrequenciaComprasCache _cache;

  @override
  void initState() {
    super.initState();
    _cache = FrequenciaComprasCache(
      (id) => frequenciaBuscarCompras(widget.state, id),
    );
  }

  @override
  void didUpdateWidget(FrequenciaCartoesMobile old) {
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
    final s = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final i in s.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Cartao(
              key: ValueKey('frequencia-cartao-${i.clienteId}'),
              item: i,
              aberto: s.linhasAbertas.contains(i.clienteId),
              cache: _cache,
              onTap: () => widget.onAlternar(i.clienteId),
            ),
          ),
        if (s.carregandoMais)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _Cartao extends StatelessWidget {
  final FrequenciaClienteItem item;
  final bool aberto;
  final FrequenciaComprasCache cache;
  final VoidCallback onTap;
  const _Cartao({
    super.key,
    required this.item,
    required this.aberto,
    required this.cache,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final i = item;
    final apoio = t.apoio.copyWith(fontSize: 11.5, color: c.textoApoio);
    final corpo = t.apoio.copyWith(fontSize: 13, color: c.tinta);
    final ambar = i.atrasado;
    final cadencia = [
      '${i.visitas} ${i.visitas == 1 ? 'visita' : 'visitas'}',
      if (i.intervaloMedioDias != null) 'a cada ${frequenciaDias(i.intervaloMedioDias!)}',
    ].join(' · ');
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
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${i.rank}',
                            style: t.apoio.copyWith(
                              fontFamily: sivFonteCondensed,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.textoApoio,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i.nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: corpo.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Text(
                                  frequenciaSub(i),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: apoio,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FrequenciaTag(i.classe),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Última: ${frequenciaDataCurta(i.ultimaCompra)}',
                                  style: apoio,
                                ),
                                Text(
                                  '${frequenciaHa(i.diasDesdeUltima)}${ambar ? ' · atrasado' : ''}',
                                  style: corpo.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: ambar ? c.atencao : c.tinta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                frequenciaMoeda(i.valor),
                                style: t.valor.copyWith(fontSize: 20, color: c.tinta),
                              ),
                              Text(cadencia, style: apoio),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (aberto)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.hairline)),
                  ),
                  child: FrequenciaDetalhe(item: i, cache: cache, mobile: true),
                ),
            ],
          ),
        ),
        ...sivCantosBlueprint(c.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}
