import 'dart:math' as math;

import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/leitor.dart';
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

  const PassoConferir({
    super.key,
    required this.resumo,
    required this.pendentes,
    required this.onLeu,
    required this.onEnviar,
    required this.onIrParaPasso,
    this.salvando = false,
    this.buscaDataSource,
  });

  @override
  State<PassoConferir> createState() => _PassoConferirState();
}

class _PassoConferirState extends State<PassoConferir> {
  final _fonte = _FonteLocal();

  List<ProdutoEsperado>? get _esperados {
    final itens = widget.resumo.conferencia.itens;
    if (itens.isEmpty) return null;
    return [
      for (final i in itens)
        ProdutoEsperado(
          id: i.produtoId,
          codigoDeBarras: i.codigoDeBarras,
          descricao: i.descricao,
          idReferencia: i.idReferencia,
          cor: i.cor,
          tamanho: i.tamanho,
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LeitorWidget(
              dataSource: _fonte,
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
            ),
          ),
        ),
        RodapeAcaoEntrada(
          aviso: temPend
              ? Text(
                  '$nPend leitura(s) ainda não enviada(s)',
                  key: const Key('conferir_pendentes'),
                  style: textos.apoio.copyWith(color: cores.parcialTexto),
                )
              : null,
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
