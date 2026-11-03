import 'dart:math' as math;

import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/leitor.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Dados locais do leitor: resolve o código a partir dos itens da própria
/// entrada (zero rede por bipe).
class _FonteLocal implements ILeitorDataDatasource {
  List<ProdutoEsperado> itens = const [];

  LeitorData? _por(bool Function(ProdutoEsperado) f) {
    for (final p in itens) {
      if (f(p)) return _DadoLocal(p);
    }
    return null;
  }

  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      _por((p) => p.codigoDeBarras == codigo);

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async =>
      _por((p) => p.id == produtoId);
}

class _DadoLocal with LeitorData {
  final ProdutoEsperado p;
  _DadoLocal(this.p);
  @override
  String get codigoDeBarras => p.codigoDeBarras;
  @override
  String get descricao => p.descricao;
  @override
  int get quantidade => 0;
  @override
  int get idReferencia => p.idReferencia;
  @override
  String get tamanho => p.tamanho;
  @override
  String get cor => p.cor;
  @override
  String get estampa => p.estampa;
  @override
  double? get valor => null;
  @override
  int get id => p.id;
  @override
  Map<String, dynamic> get dados => const {};
}

/// Passo 4: LeitorWidget em modo conferência (contado × lido). O bipe é LOCAL
/// (sem rede): as leituras ficam pendentes no bloc e vão ao servidor em lote
/// ([onEnviar]); a tela já soma o pendente ao lido do servidor.
class PassoConferir extends StatefulWidget {
  final EntradaResumo resumo;

  /// produtoId -> variação do lido ainda não enviada.
  final Map<int, int> pendentes;
  final bool salvando;
  final ILeitorBuscaDataDatasource? buscaDataSource;

  /// +1 bipe, -1 remover leitura (local).
  final void Function(int produtoId, int delta) onLeu;

  /// Envia o lote; true se enviou (ou não havia nada). Com [irParaRevisar],
  /// só segue para Revisar se der certo.
  final Future<bool> Function({bool irParaRevisar}) onEnviar;
  final ValueChanged<int> onIrParaPasso;

  /// Quando a fila foi restaurada da cópia local ao abrir (faixa âmbar).
  final DateTime? restauradaEm;
  final bool erroEnvio;

  /// Apaga a fila e a cópia local (já confirmado pelo usuário).
  final VoidCallback? onDescartar;

  /// Zera as leituras no servidor; true se o lote foi aceito.
  final Future<bool> Function()? onZerar;

  const PassoConferir({
    super.key,
    required this.resumo,
    required this.pendentes,
    required this.onLeu,
    required this.onEnviar,
    required this.onIrParaPasso,
    this.salvando = false,
    this.buscaDataSource,
    this.restauradaEm,
    this.erroEnvio = false,
    this.onDescartar,
    this.onZerar,
  });

  @override
  State<PassoConferir> createState() => _PassoConferirState();
}

class _PassoConferirState extends State<PassoConferir> {
  final _fonte = _FonteLocal();
  final _leitorController = LeitorController();

  @override
  void dispose() {
    _leitorController.dispose();
    super.dispose();
  }

  Future<void> _zerar(int pecas) async {
    var ok = false;
    await SivDialogo.mostrar(
      context,
      titulo: 'Zerar as leituras desta conferência?',
      corpo: Text(
        '$pecas peças lidas voltam para 0. A contagem não muda. '
        'Fica registrado no histórico.',
      ),
      textoSaida: 'CANCELAR',
      textoAcao: 'ZERAR',
      onConfirmar: (_) => ok = true,
    );
    if (!ok || !mounted) return;
    // o leitor local só é limpo depois do lote aceito
    if (await widget.onZerar!()) _leitorController.limpar();
  }

  Future<void> _descartar() async {
    var ok = false;
    await SivDialogo.mostrar(
      context,
      titulo: 'Descartar as leituras não enviadas?',
      corpo: const Text('Elas serão apagadas deste aparelho.'),
      textoSaida: 'CANCELAR',
      textoAcao: 'DESCARTAR',
      onConfirmar: (_) => ok = true,
    );
    if (ok) widget.onDescartar?.call();
  }

  Widget _faixaRestaurada(int n, DateTime em) {
    final cores = context.sivColors;
    final l = em.toLocal();
    String p(int v) => v.toString().padLeft(2, '0');
    final agora = DateTime.now();
    final hoje =
        l.year == agora.year && l.month == agora.month && l.day == agora.day;
    final quando = '${hoje ? 'de hoje' : 'de ${p(l.day)}/${p(l.month)}'}, '
        '${p(l.hour)}:${p(l.minute)}';
    return Container(
      key: const Key('conferir_faixa_restaurada'),
      width: double.infinity,
      color: cores.parcialFundo,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$n leituras $quando, não foram enviadas.',
              style: context.sivTextos.apoio
                  .copyWith(color: cores.parcialTexto),
            ),
          ),
          TextButton(
            key: const Key('faixa_enviar'),
            onPressed: widget.salvando ? null : () => widget.onEnviar(),
            child: const Text('ENVIAR'),
          ),
          TextButton(
            key: const Key('faixa_descartar'),
            onPressed: widget.salvando ? null : _descartar,
            child: const Text('DESCARTAR'),
          ),
        ],
      ),
    );
  }

  List<ProdutoEsperado>? get _esperados {
    final itens = widget.resumo.conferencia.itens;
    if (itens.isEmpty) return null;
    // Liso vira "Liso" quando a mesma referência também tem SKU estampado.
    final refsComEstampa = {
      for (final i in itens)
        if (i.estampa.isNotEmpty) i.idReferencia,
    };
    return [
      for (final i in itens)
        ProdutoEsperado(
          id: i.produtoId,
          codigoDeBarras: i.codigoDeBarras,
          descricao: i.descricao,
          idReferencia: i.idReferencia,
          cor: i.cor,
          tamanho: i.tamanho,
          estampa: i.estampa.isEmpty && refsComEstampa.contains(i.idReferencia)
              ? 'Liso'
              : i.estampa,
          esperado: i.contado.round(),
          lido: math.max(
            0,
            i.lido.round() + (widget.pendentes[i.produtoId] ?? 0),
          ),
        ),
    ];
  }

  Future<void> _corrigir(ProdutoEsperado p, int lido) async {
    final bloc = context.read<PedidoEntradaBloc>();
    // o servidor valida para >= lido do servidor: envia o pendente antes
    if (widget.pendentes.isNotEmpty && !await widget.onEnviar()) return;
    if (!mounted) return;
    final r = await showModalBottomSheet<({bool corrigir, String? obs})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FolhaCorrigirContagem(produto: p, lido: lido),
    );
    if (r != null && r.corrigir) {
      bloc.add(
        PedidoEntradaCorrigiuContagem(
          p.id,
          lido.toDouble(),
          motivo: r.obs,
          origem: 'conferencia',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ehMobile(context);
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final esperados = _esperados;
    _fonte.itens = esperados ?? const [];
    final totalLido = esperados?.fold<int>(0, (s, p) => s + p.lido) ??
        widget.resumo.conferencia.totalLido.round();
    final total = widget.resumo.conferencia.totalContado > 0
        ? widget.resumo.conferencia.totalContado
        : widget.resumo.totalContado;
    final nPend = widget.pendentes.values.fold<int>(0, (s, d) => s + d.abs());
    final temPend = nPend > 0;

    final lidoTotal = esperados?.fold<int>(0, (s, p) => s + p.lido) ?? 0;

    return Column(
      children: [
        if (widget.restauradaEm != null && temPend)
          _faixaRestaurada(nPend, widget.restauradaEm!),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LeitorWidget(
              dataSource: _fonte,
              controller: _leitorController,
              buscaDataSource: widget.buscaDataSource,
              autofocus: !mobile,
              alturaLista: mobile ? 420 : 480,
              campoCodigoHint: 'Código de barras…',
              avisarCodigoDuplicado: false,
              produtosEsperados: esperados,
              onUltimoProdutoLido: (item) => widget.onLeu(item.id, 1),
              onRemoverLeitura: (p) {
                if (p.lido > 0) widget.onLeu(p.id, -1);
              },
              onCorrigirContagem: _corrigir,
              onZerarLeituras: widget.onZerar == null || lidoTotal == 0
                  ? null
                  : () => _zerar(lidoTotal),
            ),
          ),
        ),
        RodapeAcaoEntrada(
          aviso: Text(
            !temPend
                ? '✓ Tudo enviado'
                : widget.erroEnvio
                    ? 'Erro ao enviar · tentar de novo'
                    : '$nPend na fila · salvas no aparelho',
            key: const Key('conferir_pendentes'),
            style: textos.apoio.copyWith(
              color: !temPend ? cores.aco : cores.parcialTexto,
            ),
          ),
          resumo: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$totalLido de ${qtd(total)} peças', style: textos.apoio),
              if (temPend)
                TextButton(
                  key: const Key('conferir_enviar_agora'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: widget.salvando ? null : () => widget.onEnviar(),
                  child: const Text('Enviar agora'),
                ),
            ],
          ),
          acao: BotaoPrincipalEntrada(
            key: const Key('conferir_continuar'),
            rotulo: temPend ? 'ENVIAR E REVISAR' : 'CONTINUAR · REVISAR',
            onPressed: widget.salvando
                ? null
                : temPend
                    ? () => widget.onEnviar(irParaRevisar: true)
                    : () => widget.onIrParaPasso(4),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet "Corrigir contagem" (5g): contagem errada x ainda há peças.
class FolhaCorrigirContagem extends StatefulWidget {
  final ProdutoEsperado produto;
  final int lido;
  const FolhaCorrigirContagem({
    super.key,
    required this.produto,
    required this.lido,
  });

  @override
  State<FolhaCorrigirContagem> createState() => _FolhaCorrigirContagemState();
}

class _FolhaCorrigirContagemState extends State<FolhaCorrigirContagem> {
  bool _corrigir = true;
  final _obs = TextEditingController();

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final p = widget.produto;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Corrigir contagem', style: textos.secao),
            const SizedBox(height: 4),
            Text('${p.descricao} · ${p.grade}', style: textos.apoio),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('CONTADO ', style: textos.rotulo),
                Text('${p.esperado}', style: textos.secao),
                const SizedBox(width: 24),
                Text('LIDO ', style: textos.rotulo),
                Text('${widget.lido}', style: textos.secao),
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<bool>(
              groupValue: _corrigir,
              onChanged: (v) => setState(() => _corrigir = v ?? true),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    key: const Key('opcao_corrigir'),
                    value: true,
                    title: const Text('A contagem estava errada'),
                    subtitle: Text('Contado passa a ser ${widget.lido}.'),
                  ),
                  RadioListTile<bool>(
                    key: const Key('opcao_continuar'),
                    value: false,
                    title: const Text(
                      'A contagem está certa, ainda há peças para bipar',
                    ),
                    subtitle: Text('Mantém ${p.esperado}.'),
                  ),
                ],
              ),
            ),
            TextField(
              key: const Key('corrigir_obs'),
              controller: _obs,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(44, 48)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotaoPrincipalEntrada(
                    key: const Key('corrigir_confirmar'),
                    rotulo:
                        _corrigir ? 'CORRIGIR CONTAGEM' : 'CONTINUAR BIPANDO',
                    onPressed: () => Navigator.pop(
                      context,
                      (
                        corrigir: _corrigir,
                        obs: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
