import 'dart:async';

import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_compras_do_cliente.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// `yyyy-MM-dd[...]` -> `dd/MM/yy`; `—` se vazio.
String frequenciaDataCurta(String? iso) {
  if (iso == null || iso.length < 10) return '—';
  final p = iso.substring(0, 10).split('-');
  if (p.length < 3) return '—';
  return '${p[2]}/${p[1]}/${p[0].substring(p[0].length - 2)}';
}

String frequenciaIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String frequenciaHa(int dias) => dias <= 0
    ? 'hoje'
    : dias == 1
        ? 'há 1 dia'
        : 'há $dias dias';

String frequenciaDias(num n) {
  final v = n.round();
  return v == 1 ? '1 dia' : '$v dias';
}

/// `{telefone} · cliente desde dd/MM/yy` (ou `primeira compra em ...` com 1 visita).
String frequenciaSub(FrequenciaClienteItem i) {
  final data = frequenciaDataCurta(i.primeiraCompra);
  final quando = i.primeiraCompra == null
      ? null
      : i.visitas == 1
          ? 'primeira compra em $data'
          : 'cliente desde $data';
  return [
    if (i.telefone != null && i.telefone!.isNotEmpty) i.telefone!,
    if (quando != null) quando,
  ].join(' · ');
}

/// Texto de insight da linha expandida; [ambar] quando atrasado.
({String texto, bool ambar}) frequenciaInsight(FrequenciaClienteItem i) {
  final intervalo = i.intervaloMedioDias;
  if (i.visitas <= 1 || intervalo == null) {
    return (texto: 'Comprou uma vez só no período.', ambar: false);
  }
  final base = 'Costuma voltar a cada ${frequenciaDias(intervalo)}.';
  final passou = (i.diasDesdeUltima - intervalo).round();
  if (i.atrasado) {
    final prox = i.proximaCompraEsperada == null
        ? ''
        : ' Próxima compra era esperada em ${frequenciaDataCurta(i.proximaCompraEsperada)} (${frequenciaHa(passou)}).';
    return (texto: '$base$prox', ambar: true);
  }
  if (passou > 0) {
    return (texto: '$base Já passou ${frequenciaDias(passou)} do esperado.', ambar: false);
  }
  final prox = i.proximaCompraEsperada == null
      ? ''
      : ' Próxima compra esperada por volta de ${frequenciaDataCurta(i.proximaCompraEsperada)}.';
  return (texto: '$base$prox', ambar: false);
}

List<int> frequenciaEmpresas(RelatorioFrequenciaClientesState s) {
  if (s.empresaIds.isNotEmpty) return s.empresaIds;
  final id = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
  return id == null ? const [] : [id];
}

Future<RelatorioClienteCompras> frequenciaBuscarCompras(
  RelatorioFrequenciaClientesState s,
  int clienteId,
) =>
    sl<GetComprasDoCliente>().call(
      empresaIds: frequenciaEmpresas(s),
      pessoaId: clienteId,
      limit: 5,
      dataInicial: frequenciaIso(s.inicio),
      dataFinal: frequenciaIso(s.fim),
    );

class FrequenciaComprasEntrada {
  final bool carregando;
  final bool erro;
  final List<RelatorioClienteCompraItem> itens;
  final int? total;
  const FrequenciaComprasEntrada({
    this.carregando = false,
    this.erro = false,
    this.itens = const [],
    this.total,
  });
}

/// Compras (F2) por cliente, carregadas só ao expandir e mantidas enquanto o
/// dono (tabela/cartões) estiver na tela. [limpar] quando o período muda.
class FrequenciaComprasCache extends ChangeNotifier {
  final Future<RelatorioClienteCompras> Function(int clienteId) _buscar;
  final _mapa = <int, FrequenciaComprasEntrada>{};
  bool _morto = false;

  FrequenciaComprasCache(this._buscar);

  FrequenciaComprasEntrada? operator [](int clienteId) => _mapa[clienteId];

  Future<void> carregar(int clienteId, {bool forcar = false}) async {
    final atual = _mapa[clienteId];
    if (atual != null && !forcar && !atual.erro) return;
    _mapa[clienteId] = const FrequenciaComprasEntrada(carregando: true);
    notifyListeners();
    FrequenciaComprasEntrada novo;
    try {
      final r = await _buscar(clienteId);
      novo = FrequenciaComprasEntrada(itens: r.items, total: r.totalNoPeriodo);
    } catch (_) {
      novo = const FrequenciaComprasEntrada(erro: true);
    }
    if (_morto) return;
    _mapa[clienteId] = novo;
    notifyListeners();
  }

  void limpar() {
    _mapa.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _morto = true;
    super.dispose();
  }
}

/// Conteúdo expandido do cliente: insight, preferências, link e compras.
/// [mobile] usa a grade de 3 colunas; senão a subtabela de 5 colunas.
class FrequenciaDetalhe extends StatefulWidget {
  final FrequenciaClienteItem item;
  final FrequenciaComprasCache cache;
  final bool mobile;
  const FrequenciaDetalhe({
    super.key,
    required this.item,
    required this.cache,
    this.mobile = false,
  });

  @override
  State<FrequenciaDetalhe> createState() => _FrequenciaDetalheState();
}

class _FrequenciaDetalheState extends State<FrequenciaDetalhe> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() => widget.cache.carregar(widget.item.clienteId));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final i = widget.item;
    final ins = frequenciaInsight(i);
    final pref = [
      if (i.categoriaPreferida != null) 'Mais compra: ${i.categoriaPreferida}',
      if (i.pagamentoPreferido != null) 'paga com ${i.pagamentoPreferido}',
    ].join(' · ');
    final insight = Text(
      ins.texto,
      style: t.apoio.copyWith(
        fontSize: 12.5,
        color: ins.ambar ? c.atencao : c.tinta.withValues(alpha: 0.75),
      ),
    );
    final prefTxt = pref.isEmpty
        ? null
        : Text(pref, style: t.apoio.copyWith(fontSize: 12.5, color: c.textoApoio));
    final link = InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed('/pessoa_visualizacao', arguments: {'idPessoa': i.clienteId}),
      child: Text(
        'Abrir cadastro',
        style: t.apoio.copyWith(
          fontSize: 12.5,
          color: c.acoAtivo,
          decoration: TextDecoration.underline,
        ),
      ),
    );
    final topo = widget.mobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              insight,
              if (prefTxt != null) ...[const SizedBox(height: 4), prefTxt],
              const SizedBox(height: 6),
              link,
            ],
          )
        : Row(
            children: [
              Expanded(child: insight),
              const SizedBox(width: 20),
              if (prefTxt != null) ...[prefTxt, const SizedBox(width: 16)],
              link,
            ],
          );
    return Container(
      width: double.infinity,
      color: c.superficieRecuada,
      padding: widget.mobile
          ? const EdgeInsets.fromLTRB(14, 8, 14, 12)
          : const EdgeInsets.fromLTRB(74, 6, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: topo,
          ),
          ListenableBuilder(
            listenable: widget.cache,
            builder: (context, _) => _compras(context, widget.cache[i.clienteId]),
          ),
        ],
      ),
    );
  }

  Widget _compras(BuildContext context, FrequenciaComprasEntrada? e) {
    final c = context.sivColors;
    final apoio = context.sivTextos.apoio.copyWith(fontSize: 12, color: c.textoApoio);
    if (e == null || e.carregando) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.aco),
          ),
        ),
      );
    }
    if (e.erro) {
      return Row(
        children: [
          Text('Não foi possível carregar as compras.', style: apoio),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => widget.cache.carregar(widget.item.clienteId, forcar: true),
            child: Text(
              'Tentar de novo',
              style: apoio.copyWith(
                color: c.acoAtivo,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }
    if (e.itens.isEmpty) {
      return Text('Nenhuma compra no período.', style: apoio);
    }
    final total = e.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.mobile ? _gradeMobile(context, e) : _subtabela(context, e),
        if (total != null && total > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Mostrando as 5 compras mais recentes de $total.', style: apoio),
          ),
      ],
    );
  }

  Widget _subtabela(BuildContext context, FrequenciaComprasEntrada e) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final cab = t.apoio.copyWith(
      fontFamily: sivFonteCondensed,
      fontSize: 11,
      letterSpacing: 0.9,
      color: c.textoApoio,
    );
    Widget linha(List<Widget> f, {required Color borda, double v = 8}) => Container(
          padding: EdgeInsets.symmetric(vertical: v),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borda))),
          child: Row(
            children: [
              SizedBox(width: 110, child: f[0]),
              const SizedBox(width: 12),
              SizedBox(width: 110, child: f[1]),
              const SizedBox(width: 12),
              SizedBox(width: 80, child: Align(alignment: Alignment.centerRight, child: f[2])),
              const SizedBox(width: 12),
              Expanded(child: f[3]),
              const SizedBox(width: 12),
              SizedBox(width: 120, child: Align(alignment: Alignment.centerRight, child: f[4])),
            ],
          ),
        );
    final corpo = t.apoio.copyWith(fontSize: 13, color: c.tinta);
    return Column(
      children: [
        linha(
          [
            Text('DATA', style: cab),
            Text('CUPOM', style: cab),
            Text('ITENS', style: cab),
            Text('PAGAMENTO', style: cab),
            Text('VALOR', style: cab),
          ],
          borda: c.hairline,
          v: 6,
        ),
        for (final x in e.itens)
          linha(
            [
              Text(frequenciaDataCurta(x.data), style: corpo),
              Text(
                x.numeroCupom == null ? '—' : 'Nº ${x.numeroCupom}',
                style: corpo.copyWith(color: c.textoApoio),
              ),
              Text(x.quantidadeItens?.toString() ?? '—', style: corpo),
              Text(x.formaPagamento ?? '—', style: corpo, overflow: TextOverflow.ellipsis),
              Text(frequenciaMoeda(x.valorLiquido), style: corpo),
            ],
            borda: c.hairline,
          ),
      ],
    );
  }

  String _descricao(RelatorioClienteCompraItem x) {
    final d = [
      if (x.quantidadeItens != null) '${x.quantidadeItens} itens',
      if (x.formaPagamento != null) x.formaPagamento!,
    ].join(' · ');
    return d.isEmpty ? '—' : d;
  }

  Widget _gradeMobile(BuildContext context, FrequenciaComprasEntrada e) {
    final c = context.sivColors;
    final corpo = context.sivTextos.apoio.copyWith(fontSize: 12.5, color: c.tinta);
    return Column(
      children: [
        for (final x in e.itens)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(frequenciaDataCurta(x.data), style: corpo)),
                Expanded(
                  flex: 5,
                  child: Text(
                    _descricao(x),
                    style: corpo.copyWith(color: c.textoApoio),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    frequenciaMoeda(x.valorLiquido),
                    textAlign: TextAlign.right,
                    style: corpo,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
