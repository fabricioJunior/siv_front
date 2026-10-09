import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/cartao_linha_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// O que o painel de contagem está editando.
class _Edicao {
  final String titulo;
  final bool livre;
  final bool novo;
  final int? referenciaId;
  final String? referenciaNome;
  final String? descricao;
  final EntradaLinha? linha;
  final List<EntradaContagem> existentes;

  const _Edicao({
    required this.titulo,
    this.livre = false,
    this.novo = false,
    this.referenciaId,
    this.referenciaNome,
    this.descricao,
    this.linha,
    this.existentes = const [],
  });
}

/// Passo 1: visão geral da contagem + painel de grade (inline no desktop, tela
/// cheia no mobile). Origem NF-e: mantém os cartões de linha.
class PassoContar extends StatefulWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final SeletoresEntrada seletores;
  final ValueChanged<int> onIrParaPasso;

  const PassoContar({
    super.key,
    required this.resumo,
    required this.salvando,
    required this.seletores,
    required this.onIrParaPasso,
  });

  @override
  State<PassoContar> createState() => _PassoContarState();
}

class _PassoContarState extends State<PassoContar> {
  _Edicao? _edicao; // desktop: painel inline

  EntradaResumo get _r => widget.resumo;

  Map<int, double> get _lidos => {
        for (final i in _r.conferencia.itens) i.produtoId: i.lido,
      };

  void _abrir(_Edicao e) {
    if (ehMobile(context)) {
      final bloc = context.read<PedidoEntradaBloc>();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (ctx) => Scaffold(
            body: SafeArea(
              child: _painel(
                e,
                onSalvar: (livre, itens) {
                  Navigator.of(ctx).pop();
                  _enviar(bloc, livre, itens);
                },
                onFechar: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ),
      );
    } else {
      setState(() => _edicao = e);
    }
  }

  void _enviar(PedidoEntradaBloc bloc, bool livre, List<ItemContagem> itens) {
    if (livre) {
      bloc.add(PedidoEntradaRegistrouContagemLivre(itens));
    } else {
      bloc.add(
        PedidoEntradaRegistrouContagem(
          itens,
          origem: _r.etiquetas.concluidas ? 'edicao' : 'contagem',
        ),
      );
      // Editou depois das etiquetas: segue pra Etiquetas (só a diferença).
      if (_r.etiquetas.impressasPorProduto.isNotEmpty) {
        bloc.add(const PedidoEntradaSelecionouPasso(2));
      }
    }
  }

  Widget _painel(
    _Edicao e, {
    required void Function(bool livre, List<ItemContagem> itens) onSalvar,
    required VoidCallback onFechar,
  }) {
    final s = widget.seletores;
    return PainelContagemGrade(
      key: ObjectKey(e),
      titulo: e.titulo,
      subtitulo: 'Passo 1 de 5 · Entrada #${_r.pedidoId}',
      permiteTrocarAba: e.novo,
      livreInicial: e.livre,
      linha: e.linha,
      referenciaId: e.referenciaId,
      referenciaNome: e.referenciaNome,
      descricaoInicial: e.descricao,
      existentes: e.existentes,
      lidoPorProduto: _lidos,
      impressasPorProduto: _r.etiquetas.impressasPorProduto.isEmpty
          ? null
          : _r.etiquetas.impressasPorProduto,
      referenciaSeletor: s.referenciaContagemSeletor,
      corSeletor: s.corSeletor,
      tamanhoSeletor: s.tamanhoSeletor,
      buscarParecidas: s.buscarReferenciasParecidas,
      onSalvar: onSalvar,
      onFechar: onFechar,
    );
  }

  // --- agrupamentos ---------------------------------------------------------

  Map<int, List<EntradaContagem>> get _gruposRef {
    final g = <int, List<EntradaContagem>>{};
    for (final c in _r.contagens) {
      if (c.linhaId != null) continue; // NF-e aparece nos cartões
      g.putIfAbsent(c.referenciaId ?? 0, () => []).add(c);
    }
    return g;
  }

  Map<String, List<ContagemLivre>> get _gruposLivres {
    final g = <String, List<ContagemLivre>>{};
    for (final c in _r.livresSemReferencia) {
      g.putIfAbsent(c.descricao, () => []).add(c);
    }
    return g;
  }

  Map<int, List<ContagemLivre>> get _gruposVariacoes {
    final g = <int, List<ContagemLivre>>{};
    for (final c in _r.variacoesNovas) {
      g.putIfAbsent(c.referenciaId!, () => []).add(c);
    }
    return g;
  }

  /// Reabre a contagem COM referência dessa referência, com as variações
  /// novas (e as já cadastradas) para recontar.
  void _editarVariacao(int refId, List<ContagemLivre> itens) => _abrir(
        _Edicao(
          titulo: itens.first.referenciaNome ?? 'Referência',
          referenciaId: refId,
          referenciaNome: itens.first.referenciaNome,
          existentes: [
            ..._r.contagens.where((c) => c.referenciaId == refId),
            for (final c in itens)
              EntradaContagem(
                produtoId: 0,
                linhaId: null,
                quantidade: c.quantidade,
                referenciaId: refId,
                corId: c.corId,
                corNome: _corNome(c.corId),
                tamanhoId: c.tamanhoId,
                tamanhoNome: _tamNome(c.tamanhoId),
              ),
          ],
        ),
      );

  void _guardarNomes() {
    for (final c in _r.contagens) {
      if (c.corId != null) nomesCor[c.corId!] = c.corNome ?? '${c.corId}';
      if (c.tamanhoId != null) {
        nomesTamanho[c.tamanhoId!] = c.tamanhoNome ?? '${c.tamanhoId}';
      }
    }
  }

  String _corNome(int id) => nomesCor[id] ?? '#$id';
  String _tamNome(int id) => nomesTamanho[id] ?? '#$id';

  void _editarRef(int refId, List<EntradaContagem> itens) => _abrir(
        _Edicao(
          titulo: itens.first.referenciaNome ?? 'Referência',
          referenciaId: refId == 0 ? null : refId,
          referenciaNome: itens.first.referenciaNome,
          existentes: itens,
        ),
      );

  void _editarLivre(String descricao, List<ContagemLivre> itens) => _abrir(
        _Edicao(
          titulo: descricao,
          livre: true,
          descricao: descricao,
          existentes: [
            for (final c in itens)
              EntradaContagem(
                produtoId: 0,
                linhaId: null,
                quantidade: c.quantidade,
                corId: c.corId,
                corNome: _corNome(c.corId),
                tamanhoId: c.tamanhoId,
                tamanhoNome: _tamNome(c.tamanhoId),
              ),
          ],
        ),
      );

  void _contarLinha(EntradaLinha linha) => _abrir(
        _Edicao(
          titulo: 'Contar: ${linha.descricao}',
          linha: linha,
          referenciaId: linha.referenciaId,
          existentes: _r.contagensDaLinha(linha.id),
        ),
      );

  // --- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _guardarNomes();
    final mobile = ehMobile(context);
    final semRef = _gruposLivres.length;
    final variacoes = _r.variacoesNovas.length;
    final livres = semRef + variacoes;
    final temContagem = _r.contagens.isNotEmpty || _r.contagensLivres.isNotEmpty;
    final lista = _lista(context, mobile);
    final edicao = _edicao;

    return Column(
      children: [
        Expanded(
          child: mobile || edicao == null
              ? lista
              : Row(
                  children: [
                    Expanded(child: lista),
                    SizedBox(
                      width: 460,
                      child: _painel(
                        edicao,
                        onSalvar: (livre, itens) {
                          final bloc = context.read<PedidoEntradaBloc>();
                          setState(() => _edicao = null);
                          _enviar(bloc, livre, itens);
                        },
                        onFechar: () => setState(() => _edicao = null),
                      ),
                    ),
                  ],
                ),
        ),
        RodapeAcaoEntrada(
          resumo: mobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${qtd(_r.totalContado)} peças · ${_gruposRef.length + _gruposLivres.length + _gruposVariacoes.length} produtos',
                      style: context.sivTextos.apoio,
                    ),
                    if (semRef > 0)
                      Text(
                        '$semRef sem referência',
                        style: context.sivTextos.apoio
                            .copyWith(color: context.sivColors.parcialTexto),
                      ),
                    if (variacoes > 0)
                      Text(
                        variacoes == 1
                            ? '1 variação a cadastrar'
                            : '$variacoes variações a cadastrar',
                        style: context.sivTextos.apoio
                            .copyWith(color: context.sivColors.parcialTexto),
                      ),
                  ],
                )
              : null,
          acao: BotaoPrincipalEntrada(
            key: const Key('entrada_terminei_contar'),
            rotulo: livres > 0
                ? (mobile
                    ? 'TERMINEI · ASSOCIAR $livres'
                    : 'TERMINEI DE CONTAR · ASSOCIAR')
                : (mobile
                    ? 'TERMINEI · ETIQUETAS'
                    : 'TERMINEI DE CONTAR · ETIQUETAS'),
            onPressed: !temContagem || widget.salvando
                ? null
                : () => widget.onIrParaPasso(livres > 0 ? 1 : 2),
          ),
        ),
      ],
    );
  }

  Widget _lista(BuildContext context, bool mobile) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final refs = _gruposRef;
    final livres = _gruposLivres;
    final nfe = _r.nfe != null;
    final variacoesNovas = _gruposVariacoes;
    final vazio = !nfe && refs.isEmpty && livres.isEmpty && variacoesNovas.isEmpty;

    final conteudo = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        if (nfe) ...[
          CabecalhoEntrada(resumo: _r),
          const SizedBox(height: 12),
          if (_r.pendencias.isNotEmpty) ...[
            PendenciasEntrada(pendencias: _r.pendencias),
            const SizedBox(height: 12),
          ],
          for (final linha in _r.linhas)
            CartaoLinhaEntrada(
              resumo: _r,
              linha: linha,
              salvando: widget.salvando,
              seletores: widget.seletores,
              onContar: _contarLinha,
            ),
        ] else if (vazio)
          _estadoVazio(context)
        else ...[
          _secao(
            'COM REFERÊNCIA · ${qtd(refs.values.expand((e) => e).fold<double>(0, (s, c) => s + c.quantidade))}',
            textos,
            cores.textoApoio,
          ),
          for (final e in refs.entries)
            _linhaGrupo(
              chave: Key('entrada_grupo_${e.key}'),
              titulo: e.value.first.referenciaNome ?? 'Referência',
              resumo: e.value
                  .map((c) =>
                      '${c.corNome ?? '-'} ${c.tamanhoNome ?? ''}·${qtd(c.quantidade)}')
                  .join(' · '),
              total: e.value.fold<double>(0, (s, c) => s + c.quantidade),
              onTap: widget.salvando ? null : () => _editarRef(e.key, e.value),
            ),
          if (variacoesNovas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              color: cores.parcialFundo,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VARIAÇÃO NOVA · cadastrar no passo 2',
                      key: const Key('secao_variacao_nova'),
                      style: textos.rotulo.copyWith(color: cores.parcialTexto),
                    ),
                  ),
                  for (final e in variacoesNovas.entries)
                    _linhaGrupo(
                      chave: Key('entrada_variacao_${e.key}'),
                      titulo: e.value.first.referenciaNome ?? e.value.first.descricao,
                      resumo: e.value
                          .map((c) =>
                              '${_corNome(c.corId)} ${_tamNome(c.tamanhoId)}·${qtd(c.quantidade)}')
                          .join(' · '),
                      total:
                          e.value.fold<double>(0, (s, c) => s + c.quantidade),
                      onTap: widget.salvando
                          ? null
                          : () => _editarVariacao(e.key, e.value),
                    ),
                ],
              ),
            ),
          ],
          if (livres.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              color: cores.parcialFundo,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'SEM REFERÊNCIA · ${qtd(livres.values.expand((e) => e).fold<double>(0, (s, c) => s + c.quantidade))} · ASSOCIAR NO PASSO 2',
                      style: textos.rotulo.copyWith(color: cores.parcialTexto),
                    ),
                  ),
                  for (final e in livres.entries)
                    _linhaGrupo(
                      chave: Key('entrada_sem_ref_${e.key}'),
                      titulo: e.key,
                      resumo: e.value
                          .map((c) =>
                              '${_corNome(c.corId)} ${_tamNome(c.tamanhoId)}·${qtd(c.quantidade)}')
                          .join(' · '),
                      total:
                          e.value.fold<double>(0, (s, c) => s + c.quantidade),
                      onTap: widget.salvando
                          ? null
                          : () => _editarLivre(e.key, e.value),
                    ),
                ],
              ),
            ),
          ],
        ],
      ],
    );

    if (nfe || vazio) return conteudo;
    return Stack(
      children: [
        conteudo,
        Positioned(
          right: 16,
          bottom: 12,
          child: FloatingActionButton.extended(
            key: const Key('entrada_contar'),
            onPressed: widget.salvando
                ? null
                : () => _abrir(
                      const _Edicao(
                        titulo: 'Contar',
                        novo: true,
                      ),
                    ),
            backgroundColor: cores.acoEscuro,
            foregroundColor: cores.textoSobreEscuroTitulo,
            icon: const Icon(Icons.add),
            label: const Text('CONTAR'),
          ),
        ),
      ],
    );
  }

  /// Entrada ainda sem nenhuma contagem: explica e oferece os dois caminhos.
  Widget _estadoVazio(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 32, 4, 0),
      key: const Key('entrada_estado_vazio'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.fact_check_outlined, size: 44, color: cores.textoApoio),
          const SizedBox(height: 12),
          Text(
            'Nenhum produto contado ainda',
            textAlign: TextAlign.center,
            style: textos.secao,
          ),
          const SizedBox(height: 8),
          Text(
            'Conte o que chegou. Com referência: escolha a referência e digite '
            'a quantidade de cada cor e tamanho. Sem referência: descreva o '
            'produto e associe a uma referência depois.',
            textAlign: TextAlign.center,
            style: textos.corpo,
          ),
          const SizedBox(height: 24),
          BotaoPrincipalEntrada(
            key: const Key('entrada_vazio_contar_ref'),
            rotulo: 'CONTAR COM REFERÊNCIA',
            icone: Icons.add,
            onPressed: widget.salvando
                ? null
                : () => _abrir(const _Edicao(titulo: 'Contar', novo: true)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              key: const Key('entrada_vazio_contar_livre'),
              onPressed: widget.salvando
                  ? null
                  : () => _abrir(
                        const _Edicao(titulo: 'Contar', novo: true, livre: true),
                      ),
              icon: const Icon(Icons.add),
              label: const Text('CONTAR SEM REFERÊNCIA'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secao(String t, SivTextStyles textos, Color cor) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t, style: textos.rotulo.copyWith(color: cor)),
      );

  Widget _linhaGrupo({
    required Key chave,
    required String titulo,
    required String resumo,
    required double total,
    required VoidCallback? onTap,
  }) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return InkWell(
      key: chave,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                  Text(resumo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.apoio),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(qtd(total), style: textos.secao),
          ],
        ),
      ),
    );
  }
}
