import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Passo 5: cada divergência recebe uma decisão; só então fatura (só as peças
/// conferidas entram no estoque).
class PassoRevisarFaturar extends StatefulWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final bool faturado;

  const PassoRevisarFaturar({
    super.key,
    required this.resumo,
    required this.salvando,
    required this.faturado,
  });

  @override
  State<PassoRevisarFaturar> createState() => _PassoRevisarFaturarState();
}

class _PassoRevisarFaturarState extends State<PassoRevisarFaturar> {
  int? _explicando;
  DateTime? _faturadoEm;
  final _obs = TextEditingController();

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  Future<void> _confirmarFaturar(int entra) async {
    final bloc = context.read<PedidoEntradaBloc>();
    final r = widget.resumo;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _FolhaFaturar(
          contado: r.revisao.contado > 0 ? r.revisao.contado : r.totalContado,
          conferido: r.conferencia.totalLido,
          entra: entra,
          mantidas: r.divergencias
              .where((d) => d.decisao == AcaoDivergencia.manter)
              .length,
        ),
      ),
    );
    if (ok == true && mounted) setState(() => _faturadoEm = DateTime.now());
  }

  void _decidir(EntradaDivergencia d, AcaoDivergencia a, {String? obs}) {
    context
        .read<PedidoEntradaBloc>()
        .add(PedidoEntradaDecidiuDivergencia(d.produtoId, a, observacao: obs));
    setState(() => _explicando = null);
    _obs.clear();
  }

  String _rotuloDecisao(AcaoDivergencia a, EntradaDivergencia d) => switch (a) {
        AcaoDivergencia.corrigir => 'Corrigir para ${qtd(d.lido)}',
        AcaoDivergencia.manter => 'Manter e explicar',
        AcaoDivergencia.removerLeitura => 'Bipado 2×, remover leitura',
        AcaoDivergencia.adicionarNaContagem => 'Adicionar à contagem',
        AcaoDivergencia.descartarLeitura => 'Descartar leitura',
      };

  List<AcaoDivergencia> _opcoes(TipoDivergencia t) => switch (t) {
        TipoDivergencia.falta => [AcaoDivergencia.corrigir, AcaoDivergencia.manter],
        TipoDivergencia.excede => [
            AcaoDivergencia.corrigir,
            AcaoDivergencia.removerLeitura,
          ],
        TipoDivergencia.foraDaContagem => [
            AcaoDivergencia.adicionarNaContagem,
            AcaoDivergencia.descartarLeitura,
          ],
      };

  @override
  Widget build(BuildContext context) {
    final r = widget.resumo;
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final restantes = TrilhaEntrada.divergenciasSemDecisao(r);
    final pode = TrilhaEntrada.podeFaturar(r) && !widget.faturado;
    final entra = r.revisao.entraNoEstoque > 0
        ? r.revisao.entraNoEstoque
        : r.conferencia.totalLido;

    if (widget.faturado) return _conclusao(r, entra, textos, cores);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (r.divergencias.isNotEmpty)
                Text(
                  '${restantes == 0 ? 'NENHUM' : restantes} ITENS PARA DECIDIR ANTES DE FATURAR',
                  key: const Key('revisao_titulo'),
                  style: textos.rotulo.copyWith(color: cores.parcialTexto),
                ),
              const SizedBox(height: 8),
              for (final d in r.divergencias) _cartao(d, textos, cores),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cores.superficie,
                  border: Border.all(color: cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _total('Contado', qtd(r.revisao.contado > 0 ? r.revisao.contado : r.totalContado), textos),
                    _total('Conferido', qtd(r.conferencia.totalLido), textos),
                    _total('Entra no estoque', '${qtd(entra)} peças', textos),
                  ],
                ),
              ),
            ],
          ),
        ),
        RodapeAcaoEntrada(
          aviso: restantes > 0
              ? Text('Decida os $restantes itens restantes para liberar.',
                  key: const Key('revisao_bloqueio'),
                  style: textos.apoio.copyWith(color: cores.parcialTexto))
              : Text('Só as peças conferidas entram no estoque.',
                  style: textos.apoio),
          acao: BotaoPrincipalEntrada(
            key: const Key('revisao_faturar'),
            rotulo: 'FATURAR ${qtd(entra)} PEÇAS',
            onPressed: pode && !widget.salvando
                ? () => _confirmarFaturar(entra.round())
                : null,
          ),
        ),
      ],
    );
  }

  Widget _conclusao(
      EntradaResumo r, double entra, SivTextStyles textos, SivColors cores) {
    final fornecedor = r.fornecedor?.nome ?? r.nfe?.emitenteNome;
    final em = _faturadoEm;
    final detalhe = [
      '${qtd(entra)} peças entraram no estoque',
      if (fornecedor != null && fornecedor.isNotEmpty) fornecedor,
      if (em != null)
        'hoje, ${em.hour.toString().padLeft(2, '0')}:${em.minute.toString().padLeft(2, '0')}',
    ].join(' · ');
    final refs = r.contagens.map((c) => c.referenciaId ?? c.produtoId).toSet().length;
    final skus = r.conferencia.itens.length;
    final decididas = r.divergencias.where((d) => d.decidida).length;
    final nav = Navigator.of(context);
    Widget acao(String chave, String rotulo, VoidCallback f) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: alturaBotaoPrincipal,
            child: OutlinedButton(
              key: Key(chave),
              onPressed: f,
              child: Text(rotulo),
            ),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('✓ Entrada #${r.pedidoId} faturada',
            key: const Key('revisao_faturado'), style: textos.secao),
        const SizedBox(height: 4),
        Text(detalhe, key: const Key('conclusao_detalhe'), style: textos.corpo),
        const SizedBox(height: 4),
        Text(
          '$refs referências · $skus SKUs · $decididas divergências decididas',
          key: const Key('conclusao_resumo'),
          style: textos.apoio,
        ),
        const SizedBox(height: 16),
        BotaoPrincipalEntrada(
          key: const Key('conclusao_contagens'),
          rotulo: 'VOLTAR ÀS CONTAGENS',
          onPressed: () => nav.pushNamedAndRemoveUntil(
              '/entrada_contagem', (rota) => rota.isFirst),
        ),
        acao(
          'conclusao_pedido',
          'ABRIR PEDIDO',
          () => nav.pushNamed('/pedido', arguments: {'idPedido': r.pedidoId}),
        ),
        acao(
          'conclusao_nova',
          'NOVA CONTAGEM',
          () => nav.pushReplacementNamed('/entrada_contagem/nova'),
        ),
      ],
    );
  }

  Widget _total(String t, String v, SivTextStyles textos) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.toUpperCase(), style: textos.rotulo),
          Text(v, style: textos.secao),
        ],
      );

  Widget _cartao(EntradaDivergencia d, SivTextStyles textos, SivColors cores) {
    final decididaTxt = d.decisao == null
        ? null
        : '${_rotuloDecisao(d.decisao!, d)}${d.observacao != null ? ' · ${d.observacao}' : ''}';
    return Container(
      key: Key('divergencia_${d.produtoId}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: d.decidida ? cores.conferidoFundo : cores.parcialFundo,
        border: Border.all(
          color: d.decidida ? cores.conferidoEtiqueta : cores.parcialBorda,
        ),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${d.descricao} · ${d.grade}',
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(
                d.tipo == TipoDivergencia.foraDaContagem
                    ? '${qtd(d.lido)} · não contado'
                    : '${qtd(d.lido)}/${qtd(d.contado)}',
                style: textos.secao,
              ),
            ],
          ),
          if (decididaTxt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Decidido: $decididaTxt',
                  key: Key('decisao_${d.produtoId}'),
                  style: textos.apoio.copyWith(color: cores.conferidoTexto)),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _opcoes(d.tipo))
                OutlinedButton(
                  key: Key('decidir_${d.produtoId}_${a.name}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor:
                        d.decisao == a ? cores.conferidoEtiqueta : null,
                  ),
                  onPressed: widget.salvando || widget.faturado
                      ? null
                      : a == AcaoDivergencia.manter
                          ? () => setState(() => _explicando = d.produtoId)
                          : () => _decidir(d, a),
                  child: Text(_rotuloDecisao(a, d)),
                ),
            ],
          ),
          if (_explicando == d.produtoId) ...[
            const SizedBox(height: 8),
            TextField(
              key: Key('explicacao_${d.produtoId}'),
              controller: _obs,
              maxLength: 255,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Explicação (ex.: veio 1 a menos na caixa 2)',
                counterText: '',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: Key('explicacao_confirmar_${d.produtoId}'),
                style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
                onPressed: _obs.text.trim().isEmpty
                    ? null
                    : () => _decidir(d, AcaoDivergencia.manter,
                        obs: _obs.text.trim()),
                child: const Text('Manter'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Folha de confirmação: só dispara o faturamento ao confirmar; em erro fica
/// aberta com a mensagem do servidor e TENTAR DE NOVO.
class _FolhaFaturar extends StatelessWidget {
  final double contado;
  final double conferido;
  final int entra;
  final int mantidas;

  const _FolhaFaturar({
    required this.contado,
    required this.conferido,
    required this.entra,
    required this.mantidas,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    Widget linha(String t, String v, {bool forte = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(t, style: forte ? textos.secao : textos.corpo),
              ),
              Text(v, style: forte ? textos.secao : textos.corpo),
            ],
          ),
        );
    return BlocConsumer<PedidoEntradaBloc, PedidoEntradaState>(
      listenWhen: (a, b) => !a.faturado && b.faturado,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) => PopScope(
        canPop: !state.salvando,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              key: const Key('faturar_folha'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Faturar $entra peças?', style: textos.secao),
                const SizedBox(height: 12),
                linha('Contado', qtd(contado)),
                linha('Conferido', qtd(conferido)),
                linha('Entra no estoque', '$entra peças', forte: true),
                if (mantidas > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    mantidas == 1
                        ? '1 divergência mantida com explicação.'
                        : '$mantidas divergências mantidas com explicação.',
                    style: textos.apoio.copyWith(color: cores.parcialTexto),
                  ),
                ],
                const SizedBox(height: 8),
                Text('Depois de faturar não dá para desfazer.',
                    style: textos.apoio),
                if (state.erroFaturar != null) ...[
                  const SizedBox(height: 8),
                  Text(state.erroFaturar!,
                      key: const Key('faturar_erro'),
                      style: textos.apoio.copyWith(color: cores.parcialTexto)),
                ],
                const SizedBox(height: 16),
                BotaoPrincipalEntrada(
                  key: const Key('faturar_confirmar'),
                  rotulo: state.erroFaturar != null
                      ? 'TENTAR DE NOVO'
                      : 'FATURAR $entra PEÇAS',
                  onPressed: state.salvando
                      ? null
                      : () => context
                          .read<PedidoEntradaBloc>()
                          .add(const PedidoEntradaFaturou()),
                ),
                if (state.salvando)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                TextButton(
                  key: const Key('faturar_voltar'),
                  onPressed: state.salvando
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('VOLTAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
