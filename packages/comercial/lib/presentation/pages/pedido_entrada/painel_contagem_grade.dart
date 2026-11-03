import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/grade_fixa.dart';
import 'package:comercial/presentation/pages/pedido_entrada/lista_esperadas.dart';
import 'package:comercial/presentation/blocs/variacoes_produto_bloc/variacoes_produto_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/variacao_tela_cheia.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

// Nomes de cor/tamanho vistos nos seletores (a API da contagem sem referência
// só devolve ids); o que não foi visto cai em "#id".
final nomesCor = <int, String>{};
final nomesTamanho = <int, String>{};

const mensagemContadoAbaixoDoLido =
    'O contado não pode ficar abaixo do que já foi lido. '
    'Se precisar, remova a leitura no leitor antes.';

/// Painel de contagem (substitui o antigo `_ContagemDialog`): grade
/// cor × tamanho com células de 52px e barra −1/+1/LIMPAR/PRÓX. acima do
/// teclado. Tela cheia no mobile, inline no desktop. Três usos: referência
/// (aba COM REFERÊNCIA), produto sem referência (aba SEM REFERÊNCIA) e linha
/// de NF-e (SKU único ou grade).
class PainelContagemGrade extends StatefulWidget {
  final String titulo;
  final String subtitulo;

  /// Mostra as abas COM/SEM REFERÊNCIA (contagem nova, sem NF-e).
  final bool permiteTrocarAba;
  final bool livreInicial;
  final EntradaLinha? linha;
  final int? referenciaId;
  final String? referenciaNome;
  final String? descricaoInicial;
  final int? estampaIdInicial;
  final String? estampaNomeInicial;
  final List<EntradaContagem> existentes;

  /// produtoId -> lido na conferência (o contado nunca fica abaixo dele).
  final Map<int, double> lidoPorProduto;

  /// Etiquetas já impressas por produto (não nulo = edição após etiquetas:
  /// o salvar mostra só a diferença a imprimir).
  final Map<int, double>? impressasPorProduto;
  final SeletorWidget? referenciaSeletor;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;
  final SeletorWidget? estampaSeletor;
  final BuscaReferenciasParecidas? buscarParecidas;
  final void Function(bool livre, List<ItemContagem> itens) onSalvar;
  final VoidCallback onFechar;

  /// Referências esperadas do fornecedor (aba ESPERADAS). Vazio = a aba não aparece.
  final List<ReferenciaEsperada> esperadas;

  /// Peças já contadas nesta entrada, por referência (esmaece e mostra contado/esperado).
  final Map<int, double> contadoPorReferencia;

  /// Abre já na aba ESPERADAS (só em contagem nova, com esperadas).
  final bool esperadasInicial;

  /// Contagens já feitas de uma referência (pré-carrega a grade ao escolher uma esperada).
  final List<EntradaContagem> Function(int referenciaId, int? estampaId)?
      existentesDaReferencia;

  const PainelContagemGrade({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.permiteTrocarAba = false,
    this.livreInicial = false,
    this.linha,
    this.referenciaId,
    this.referenciaNome,
    this.descricaoInicial,
    this.estampaIdInicial,
    this.estampaNomeInicial,
    this.existentes = const [],
    this.lidoPorProduto = const {},
    this.impressasPorProduto,
    this.referenciaSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
    this.estampaSeletor,
    this.buscarParecidas,
    required this.onSalvar,
    required this.onFechar,
    this.esperadas = const [],
    this.contadoPorReferencia = const {},
    this.esperadasInicial = false,
    this.existentesDaReferencia,
  });

  @override
  State<PainelContagemGrade> createState() => _PainelContagemGradeState();
}

class _PainelContagemGradeState extends State<PainelContagemGrade> {
  final _simples = TextEditingController();
  late final _descricao = TextEditingController(text: widget.descricaoInicial);
  final _cores = <int, String>{};
  final _tamanhos = <int, String>{};
  final _coresSeletor = <int, String>{};
  final _tamanhosSeletor = <int, String>{};
  final _celulas = <String, TextEditingController>{};
  final _focos = <String, FocusNode>{};
  final _debounce = Debouncer(milliseconds: 350);

  late bool _livre = widget.livreInicial;
  late bool _modoEsperadas = widget.esperadasInicial &&
      widget.permiteTrocarAba &&
      widget.esperadas.isNotEmpty;
  ReferenciaEsperada? _esperadaEscolhida;
  late int? _referenciaId = widget.referenciaId ?? widget.linha?.referenciaId;
  late String? _referenciaNome = widget.referenciaNome;
  // Estampas escolhidas para esta contagem (id -> nome). Cada uma ganha a sua grade,
  // além da grade LISO (sem estampa).
  final _estampas = <int, String>{};

  /// Grades da contagem: 0 = liso. Editando uma contagem já estampada só ela
  /// (outra estampa = outra contagem); senão o liso e as estampas escolhidas.
  List<int> get _blocos => widget.estampaIdInicial != null
      ? [widget.estampaIdInicial!]
      : [0, ..._estampas.keys];

  String _nomeBloco(int est) => est == 0
      ? 'LISO (SEM ESTAMPA)'
      : (_estampas[est] ?? widget.estampaNomeInicial ?? '#$est').toUpperCase();
  bool? _tamanhosNumericos;
  bool _carregandoTamanhos = false;
  String? _focado;
  // null = padrão pela largura/nº de tamanhos (ver _modoPorCor).
  bool? _porCor;
  int? _corAtiva;
  List<ReferenciaParecida> _parecidas = const [];
  int _buscaSeq = 0;

  bool get _skuUnico => widget.linha?.status == StatusLinhaEntrada.mapeado;

  @override
  void initState() {
    super.initState();
    if (_skuUnico) {
      final atual = widget.existentes.firstOrNull;
      if (atual != null) _simples.text = qtd(atual.quantidade);
    }
    for (final c in widget.existentes) {
      if (c.corId == null || c.tamanhoId == null) continue;
      _cores[c.corId!] = c.corNome ?? nomesCor[c.corId] ?? '${c.corId}';
      _tamanhos[c.tamanhoId!] =
          c.tamanhoNome ?? nomesTamanho[c.tamanhoId] ?? '${c.tamanhoId}';
      _celula(c.corId!, c.tamanhoId!, c.estampaId ?? 0).text = qtd(c.quantidade);
    }
    _ordenarTamanhos();
    nomesCor.addAll(_cores);
    nomesTamanho.addAll(_tamanhos);
  }

  @override
  void dispose() {
    _debounce.cancel();
    _simples.dispose();
    _descricao.dispose();
    for (final c in _celulas.values) {
      c.dispose();
    }
    for (final f in _focos.values) {
      f.dispose();
    }
    super.dispose();
  }

  // Liso mantém a chave 'cor|tam'; estampa acrescenta '|estampaId'.
  String _chave(int cor, int tam, [int est = 0]) =>
      est == 0 ? '$cor|$tam' : '$cor|$tam|$est';

  TextEditingController _celula(int cor, int tam, [int est = 0]) =>
      _celulas.putIfAbsent(_chave(cor, tam, est), () {
        final c = TextEditingController();
        c.addListener(() {
          if (mounted) setState(() {});
        });
        return c;
      });

  FocusNode _foco(int cor, int tam, [int est = 0]) {
    final k = _chave(cor, tam, est);
    return _focos.putIfAbsent(k, () {
      final f = FocusNode();
      f.addListener(() {
        if (!mounted) return;
        if (f.hasFocus) {
          setState(() {
            _focado = k;
            _corAtiva = int.parse(k.split('|')[0]);
          });
          _manterVisivel(f);
        } else if (_focado == k) {
          setState(() => _focado = null);
        }
      });
      return f;
    });
  }

  // Célula sempre visível nos dois eixos (grade, coluna de cores e página).
  void _manterVisivel(FocusNode f) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = f.context;
      if (!mounted || !f.hasFocus || ctx == null || !ctx.mounted) return;
      // centraliza: vale para ir e voltar nos dois eixos e não mexe mais no
      // eixo que já está centrado (andar pela mesma linha). Sem animação: o
      // campo também revela o cursor e brigaria com uma rolagem em curso.
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
      );
    });
  }

  /// (cor, tamanho, estampa) da célula em foco.
  ({int cor, int tam, int est})? get _foco3 {
    final k = _focado;
    if (k == null) return null;
    final p = k.split('|');
    return (
      cor: int.parse(p[0]),
      tam: int.parse(p[1]),
      est: p.length > 2 ? int.parse(p[2]) : 0,
    );
  }

  bool get _mobile =>
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

  bool get _comGrade =>
      !_skuUnico &&
      !_modoEsperadas &&
      _cores.isNotEmpty &&
      _tamanhos.isNotEmpty;

  /// Grade x Por cor: mobile com mais de 4 tamanhos abre em Por cor; o
  /// desktop abre em Grade. A escolha do usuário vale sobre o padrão.
  bool get _modoPorCor =>
      _comGrade && (_porCor ?? (_mobile && _tamanhos.length > 4));

  /// C3: célula em foco no celular -> seletores resumidos, sem abas nem rodapé.
  bool get _focoMobile =>
      _focado != null && _mobile && !_skuUnico && !_modoEsperadas;

  int get _corAtivaId => _cores.containsKey(_corAtiva)
      ? _corAtiva!
      : _cores.keys.first;

  double _totalCor(int cor) {
    var t = 0.0;
    for (final est in _blocos) {
      for (final tam in _tamanhos.keys) {
        t += _ler(_celula(cor, tam, est)) ?? 0;
      }
    }
    return t;
  }

  double? _ler(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  double? _lidoDaCelula(int cor, int tam, [int est = 0]) {
    for (final e in widget.existentes) {
      if (e.corId == cor && e.tamanhoId == tam && (e.estampaId ?? 0) == est) {
        return widget.lidoPorProduto[e.produtoId];
      }
    }
    return null;
  }

  bool _abaixoDoLido(int cor, int tam, [int est = 0]) {
    final lido = _lidoDaCelula(cor, tam, est);
    final v = _ler(_celula(cor, tam, est));
    return lido != null && v != null && v < lido;
  }

  bool get _temViolacao {
    if (_skuUnico) {
      final lido = widget.lidoPorProduto[widget.linha?.produtoId];
      final q = _ler(_simples);
      return lido != null && q != null && q < lido;
    }
    for (final est in _blocos) {
      for (final cor in _cores.keys) {
        for (final tam in _tamanhos.keys) {
          if (_abaixoDoLido(cor, tam, est)) return true;
        }
      }
    }
    return false;
  }

  /// Mantém as colunas de tamanho em ordem (34, 36, 38… / P, M, G…): a grade e
  /// o PRÓX. → seguem a ordem do mapa.
  void _ordenarTamanhos() {
    final ordenado = _tamanhos.entries.toList()
      ..sort((a, b) => compararTamanhos(a.value, b.value));
    _tamanhos
      ..clear()
      ..addEntries(ordenado);
  }

  void _sincronizarSeletores() {
    setState(() {
      for (final e in _coresSeletor.entries) {
        _cores[e.key] = e.value;
      }
      for (final e in _tamanhosSeletor.entries) {
        _tamanhos[e.key] = e.value;
      }
      // chip removido no seletor some da grade (se não tem valor digitado)
      _cores.removeWhere(
        (id, _) =>
            !_coresSeletor.containsKey(id) && !_comValor(cor: id, tam: null),
      );
      _tamanhos.removeWhere(
        (id, _) =>
            !_tamanhosSeletor.containsKey(id) && !_comValor(cor: null, tam: id),
      );
      _ordenarTamanhos();
      nomesCor.addAll(_cores);
      nomesTamanho.addAll(_tamanhos);
    });
  }

  bool _comValor({int? cor, int? tam}) {
    for (final e in _celulas.entries) {
      final p = e.key.split('|');
      final bate =
          (cor == null || p[0] == '$cor') && (tam == null || p[1] == '$tam');
      if (bate && _ler(e.value) != null) return true;
    }
    return false;
  }

  List<ItemContagem> _montar() {
    if (_skuUnico) {
      final q = _ler(_simples);
      return q == null
          ? const []
          : [
              ItemContagem(
                linhaId: widget.linha!.id,
                produtoId: widget.linha!.produtoId,
                quantidade: q,
              ),
            ];
    }
    final descricao = _descricao.text.trim();
    if (_livre ? descricao.isEmpty : _referenciaId == null) return const [];
    return [
      for (final est in _blocos)
        for (final cor in _cores.keys)
          for (final tam in _tamanhos.keys)
            if (_ler(_celula(cor, tam, est)) != null)
              ItemContagem(
                linhaId: widget.linha?.id,
                referenciaId: _livre ? null : _referenciaId,
                estampaId: est == 0 ? null : est,
                descricao: _livre ? descricao : null,
                corId: cor,
                tamanhoId: tam,
                quantidade: _ler(_celula(cor, tam, est))!,
              ),
    ];
  }

  double get _totalPecas {
    if (_skuUnico) return _ler(_simples) ?? 0;
    var t = 0.0;
    for (final est in _blocos) {
      for (final cor in _cores.keys) {
        for (final tam in _tamanhos.keys) {
          t += _ler(_celula(cor, tam, est)) ?? 0;
        }
      }
    }
    return t;
  }

  /// Etiquetas a imprimir a mais com a edição atual (3c/5j).
  double get _aImprimir {
    final imp = widget.impressasPorProduto;
    if (imp == null) return 0;
    var t = 0.0;
    for (final est in _blocos) {
      for (final cor in _cores.keys) {
        for (final tam in _tamanhos.keys) {
          final v = _ler(_celula(cor, tam, est));
          if (v == null) continue;
          final produto = widget.existentes
              .where((e) =>
                  e.corId == cor &&
                  e.tamanhoId == tam &&
                  (e.estampaId ?? 0) == est)
              .map((e) => e.produtoId)
              .firstOrNull;
          final dif = v - (imp[produto] ?? 0);
          if (dif > 0) t += dif;
        }
      }
    }
    return t;
  }

  bool get _podeSalvar => !_temViolacao && _montar().isNotEmpty;

  void _salvar() {
    final itens = _montar();
    if (itens.isEmpty || _temViolacao) return;
    widget.onSalvar(_livre, itens);
  }

  void _buscarParecidas(String texto) {
    final busca = widget.buscarParecidas;
    final nome = texto.trim();
    if (busca == null || nome.length < 3) {
      if (_parecidas.isNotEmpty) setState(() => _parecidas = const []);
      return;
    }
    _debounce.run(() async {
      final seq = ++_buscaSeq;
      try {
        final r = await busca(nome);
        if (mounted && seq == _buscaSeq) {
          setState(() => _parecidas = r.take(3).toList());
        }
      } catch (_) {
        // sugestão é só ajuda; falha de busca não atrapalha a contagem
      }
    });
  }

  /// Escolheu uma esperada na lista: vira uma contagem COM referência, com a
  /// grade já preenchida se a referência foi contada antes nesta entrada.
  void _escolherEsperada(ReferenciaEsperada e) => setState(() {
        _modoEsperadas = false;
        _livre = false;
        _referenciaId = e.id;
        _referenciaNome = e.nome;
        _esperadaEscolhida = e;
        _parecidas = const [];
        _recarregarGrade(e.id);
      });

  /// Grade da referência escolhida na aba Esperadas: o que já foi contado dela,
  /// no liso e em cada estampa escolhida (estampa diferente = outro SKU).
  void _recarregarGrade(int referenciaId) {
    _cores.clear();
    _tamanhos.clear();
    _coresSeletor.clear();
    _tamanhosSeletor.clear();
    for (final c in _celulas.values) {
      c.clear();
    }
    for (final est in _blocos) {
      _preencherExistentes(referenciaId, est);
    }
    _ordenarTamanhos();
    nomesCor.addAll(_cores);
    nomesTamanho.addAll(_tamanhos);
  }

  void _preencherExistentes(int referenciaId, int est) {
    for (final c in widget.existentesDaReferencia
            ?.call(referenciaId, est == 0 ? null : est) ??
        const <EntradaContagem>[]) {
      if (c.corId == null || c.tamanhoId == null) continue;
      _cores[c.corId!] = c.corNome ?? nomesCor[c.corId] ?? '${c.corId}';
      _tamanhos[c.tamanhoId!] =
          c.tamanhoNome ?? nomesTamanho[c.tamanhoId] ?? '${c.tamanhoId}';
      final celula = _celula(c.corId!, c.tamanhoId!, est);
      if (celula.text.isEmpty) celula.text = qtd(c.quantidade);
    }
  }

  void _contarNesta(ReferenciaParecida r) => setState(() {
        _livre = false;
        _referenciaId = r.id;
        _referenciaNome = r.nome;
        _parecidas = const [];
      });

  // --- barra acima do teclado -------------------------------------------

  TextEditingController? get _celulaFocada {
    final k = _focado;
    return k == null ? null : _celulas[k];
  }

  void _somar(int delta) {
    final c = _celulaFocada;
    if (c != null) _ajustar(c, delta);
  }

  void _ajustar(TextEditingController c, int delta) {
    final atual = _ler(c);
    if (atual == null && delta < 0) return;
    final novo = ((atual ?? 0) + delta).clamp(0, 999999).toDouble();
    c.text = qtd(novo);
    c.selection = TextSelection.collapsed(offset: c.text.length);
  }

  void _proxima() {
    final ordem = [
      for (final est in _blocos)
        for (final cor in _cores.keys)
          for (final tam in _tamanhos.keys) _chave(cor, tam, est),
    ];
    final i = ordem.indexOf(_focado ?? '');
    if (i < 0 || i + 1 >= ordem.length) {
      FocusScope.of(context).unfocus();
      return;
    }
    final p = ordem[i + 1].split('|');
    final no = _foco(
        int.parse(p[0]), int.parse(p[1]), p.length > 2 ? int.parse(p[2]) : 0);
    if (_modoPorCor && int.parse(p[0]) != _corAtivaId) {
      // outra cor = outra lista: o campo só existe depois de trocar a cor ativa
      setState(() => _corAtiva = int.parse(p[0]));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) no.requestFocus();
      });
    } else {
      no.requestFocus();
    }
  }

  Widget _barraTeclado(SivColors cores, SivTextStyles textos) {
    Widget botao(String rotulo, VoidCallback acao, {Key? key}) => Expanded(
          child: TextButton(
            key: key,
            onPressed: acao,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              foregroundColor: cores.acoEscuro,
            ),
            child: Text(rotulo,
                style: textos.rotulo.copyWith(
                  color: cores.acoEscuro,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
        );
    // TextFieldTapRegion: tocar na barra não conta como "fora" do campo
    // (senão o campo perde o foco, a barra some e o toque se perde).
    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: Container(
          key: const Key('barra_teclado'),
          color: cores.superficieRecuada,
          child: Row(
            children: [
              botao('−1', () => _somar(-1), key: const Key('barra_menos')),
              botao('+1', () => _somar(1), key: const Key('barra_mais')),
              botao('LIMPAR', () => _celulaFocada?.clear(),
                  key: const Key('barra_limpar')),
              botao('PRÓX. →', _proxima, key: const Key('barra_proxima')),
            ],
          ),
        ),
      ),
    );
  }

  // --- build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final foco = _focoMobile;
    final tabs = widget.permiteTrocarAba && !foco;
    final podeSalvar = _podeSalvar;
    final porCor = _modoPorCor;
    return Material(
      color: cores.papel,
      child: Column(
        children: [
          Container(
            height: 52,
            color: cores.superficie,
            padding: const EdgeInsets.only(left: 4, right: 12),
            child: Row(
              children: [
                IconButton(
                  key: const Key('painel_fechar'),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  onPressed: widget.onFechar,
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.secao),
                      Text(widget.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.apoio),
                    ],
                  ),
                ),
                if (foco)
                  Text('${qtd(_totalPecas)} pç',
                      key: const Key('painel_total_cabecalho'),
                      style: textos.secao),
              ],
            ),
          ),
          if (widget.impressasPorProduto != null)
            Container(
              key: const Key('painel_aviso_etiquetas'),
              width: double.infinity,
              color: cores.parcialFundo,
              padding: const EdgeInsets.all(12),
              child: Text(
                'Etiquetas já impressas. Ao salvar, o app mostra só a diferença: quantas imprimir a mais e quantas descartar. As leituras continuam valendo.',
                style: textos.apoio.copyWith(color: cores.parcialTexto),
              ),
            ),
          if (tabs) _abas(cores, textos),
          // key: as abas somem com o foco; sem ela o corpo remonta e perde o foco
          Expanded(
            key: const Key('painel_corpo'),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: _modoEsperadas
                  ? ListaEsperadas(
                      esperadas: widget.esperadas,
                      contadoPorReferencia: widget.contadoPorReferencia,
                      onEscolher: _escolherEsperada,
                    )
                  : _skuUnico
                      ? _campoUnico()
                      : _corpo(cores, textos),
            ),
          ),
          if (foco && _temViolacao)
            Container(
              width: double.infinity,
              color: cores.excedenteFundo,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                mensagemContadoAbaixoDoLido,
                key: const Key('painel_aviso_lido'),
                style: textos.apoio.copyWith(color: cores.vinho),
              ),
            ),
          if (_focado != null && !_modoEsperadas && !_skuUnico && !porCor)
            _faixaEditando(cores, textos),
          if (_focado != null && !_modoEsperadas) _barraTeclado(cores, textos),
          if (!_modoEsperadas && !foco)
            RodapeAcaoEntrada(
              resumo: porCor
                  ? _proximaCor(cores, textos)
                  : Text(
                      '${qtd(_totalPecas)} peças',
                      key: const Key('painel_total'),
                      style: textos.secao,
                    ),
              aviso: _temViolacao
                  ? Text(
                      mensagemContadoAbaixoDoLido,
                      key: const Key('painel_aviso_lido'),
                      style: textos.apoio.copyWith(color: cores.vinho),
                    )
                  : null,
              acao: BotaoPrincipalEntrada(
                rotulo: _livre
                    ? 'Salvar sem referência'
                    : widget.impressasPorProduto != null
                        ? 'SALVAR · IMPRIMIR ${qtd(_aImprimir)}'
                        : porCor
                        ? 'SALVAR · ${qtd(_totalPecas)} PEÇAS'
                        : 'SALVAR',
                onPressed: podeSalvar ? _salvar : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _abas(SivColors cores, SivTextStyles textos) {
    Widget aba(String rotulo, bool livre, Key key) {
      final sel = !_modoEsperadas && _livre == livre;
      return Expanded(
        child: InkWell(
          key: key,
          onTap: () => setState(() {
            _modoEsperadas = false;
            _livre = livre;
          }),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cores.superficie,
              border: Border(
                bottom: BorderSide(
                  color: sel ? cores.acoEscuro : cores.hairline,
                  width: sel ? 3 : 1,
                ),
              ),
            ),
            child: Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textos.rotulo.copyWith(
                color: sel ? cores.acoEscuro : cores.textoApoio,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    final temEsperadas = widget.esperadas.isNotEmpty;
    return Row(
      children: [
        if (temEsperadas)
          Expanded(
            child: InkWell(
              key: const Key('aba_esperadas'),
              onTap: () => setState(() => _modoEsperadas = true),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cores.superficie,
                  border: Border(
                    bottom: BorderSide(
                      color: _modoEsperadas ? cores.acoEscuro : cores.hairline,
                      width: _modoEsperadas ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'ESPERADAS · ${widget.esperadas.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textos.rotulo.copyWith(
                    color: _modoEsperadas ? cores.acoEscuro : cores.textoApoio,
                    fontWeight:
                        _modoEsperadas ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        aba('COM REFERÊNCIA', false, const Key('aba_com_referencia')),
        aba('SEM REFERÊNCIA', true, const Key('aba_sem_referencia')),
      ],
    );
  }

  Widget _campoUnico() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NF-e: ${qtd(widget.linha!.quantidadeNfe)}'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('contagem_quantidade'),
            controller: _simples,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                const InputDecoration(labelText: 'Quantidade encontrada'),
          ),
        ],
      );

  Widget _rotulo(String t, SivColors cores, SivTextStyles textos) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: textos.rotulo.copyWith(color: cores.aco)),
      );

  Widget _corpo(SivColors cores, SivTextStyles textos) {
    final linhaNfe = widget.linha;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_livre)
          ..._camposLivre(cores, textos)
        else
          ..._campoReferencia(cores, textos),
        if (!_livre && _esperadaEscolhida != null)
          ..._avisoEsperada(cores, textos),
        if (linhaNfe != null) ...[
          Text(
            'NF-e: ${qtd(linhaNfe.quantidadeNfe)} — digite o que foi '
            'encontrado em cada cor e tamanho.',
          ),
          const SizedBox(height: 12),
        ],
        if (_focoMobile && _telaCheia)
          ..._resumoSeletores(cores, textos)
        else ...[
        if (_telaCheia)
          _variacao('COR', _cores, '+ cor', _escolherCores, _removerCor,
              'cor', cores, textos)
        else
          widget.corSeletor(
            SeletorData(
              onChanged: (itens) {
                _coresSeletor
                  ..clear()
                  ..addEntries(itens.map((i) => MapEntry(i.id, i.nome)));
                _sincronizarSeletores();
              },
            ),
          ),
        const SizedBox(height: 12),
        if (widget.linha == null && widget.estampaSeletor != null) ...[
          // Editando uma contagem já estampada a estampa fica fixa (outra estampa = outra contagem).
          if (widget.estampaIdInicial != null)
            Text(
              'Estampa: ${widget.estampaNomeInicial ?? '#${widget.estampaIdInicial}'}',
              key: const Key('contagem_estampa_fixa'),
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
            )
          else if (_telaCheia)
            _variacao('ESTAMPA', _estampas, '+ estampa', _escolherEstampa,
                _removerEstampa, 'estampa', cores, textos)
          else
            widget.estampaSeletor!(
              SeletorData(
                compacto: true,
                onChanged: _estampasMudaram,
              ),
            ),
          const SizedBox(height: 12),
        ],
        if (_telaCheia)
          _variacao('TAMANHO', _tamanhos, '+ tam.', _escolherTamanhos,
              _removerTamanho, 'tam', cores, textos)
        else if (_variacoes != null)
          _tipoTamanho(cores, textos)
        else
          widget.tamanhoSeletor(
            SeletorData(
              onChanged: (itens) {
                _tamanhosSeletor
                  ..clear()
                  ..addEntries(itens.map((i) => MapEntry(i.id, i.nome)));
                _sincronizarSeletores();
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_cores.isNotEmpty && _tamanhos.isNotEmpty) ...[
          _seletorModo(cores, textos),
          if (_modoPorCor)
            _porCorView(cores, textos)
          else
            for (final est in _blocos)
              Column(
                key: ValueKey('bloco_$est'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_blocos.length > 1 || est != 0)
                    _rotulo(_nomeBloco(est), cores, textos),
                  _grade(cores, textos, est),
                  const SizedBox(height: 16),
                ],
              ),
        ] else if (_estampas.isNotEmpty)
          Text(
            'Escolha as cores e os tamanhos para preencher a grade de cada estampa e do liso.',
            key: const Key('contagem_estampa_sem_grade'),
            style: textos.apoio,
          ),
        if (_livre) ...[
          const SizedBox(height: 12),
          Text(
            'Fica em “Sem referência” até ser associado no passo 2.',
            style: textos.apoio,
          ),
        ],
      ],
    );
  }

  void _estampasMudaram(List<SelectData> itens) => setState(() {
        final antes = _estampas.keys.toSet();
        _estampas
          ..clear()
          ..addEntries(itens.map((i) => MapEntry(i.id, i.nome)));
        final ref = _referenciaId;
        if (_esperadaEscolhida != null && ref != null) {
          for (final est in _estampas.keys.where((e) => !antes.contains(e))) {
            _preencherExistentes(ref, est);
          }
          _ordenarTamanhos();
        }
      });

  // --- seletores em tela cheia (mobile, C4) ------------------------------

  // Bloc das variações (provido pela página); sem ele, fluxo legado/desktop.
  late final VariacoesProdutoBloc? _variacoes = _lerVariacoes();

  VariacoesProdutoBloc? _lerVariacoes() {
    try {
      return context.read<VariacoesProdutoBloc>();
    } catch (_) {
      return null;
    }
  }

  bool get _telaCheia =>
      _variacoes != null &&
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

  String? get _subtituloSeletor => _referenciaId == null
      ? null
      : '${_referenciaNome ?? widget.linha?.descricao ?? 'Referência'} · REF $_referenciaId';

  SelectData _sd(int id, String nome) =>
      SelectData(id: id, nome: nome, data: const {});

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  /// Linha "RÓTULO  [chip ×] ... [+ botão]"; tocar no chip remove.
  Widget _variacao(
    String rotulo,
    Map<int, String> itens,
    String botao,
    VoidCallback abrir,
    void Function(int id) remover,
    String chave,
    SivColors cores,
    SivTextStyles textos,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rotulo(rotulo, cores, textos),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in itens.entries)
                  InputChip(
                    key: Key('chip_${chave}_${e.key}'),
                    label: Text(e.value),
                    onDeleted: () => remover(e.key),
                  ),
                OutlinedButton(
                  key: Key('add_$chave'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(48, 44)),
                  onPressed: abrir,
                  child: Text(botao),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _escolherCores() async {
    final usadas = {
      for (final c in widget.existentes) if (c.corId != null) c.corId!,
      for (final c in widget.existentesDaReferencia?.call(_referenciaId ?? -1, null) ??
          const <EntradaContagem>[])
        if (c.corId != null) c.corId!,
    };
    final r = await VariacaoTelaCheia.abrir(
      context,
      _variacoes!,
      VariacaoTelaCheia(
        titulo: 'Cores',
        subtitulo: _subtituloSeletor,
        lista: (s) => s.cores,
        cadastrar: VariacoesCorCadastrada.new,
        singular: 'cor',
        plural: 'cores',
        selecionados: [for (final e in _cores.entries) _sd(e.key, e.value)],
        usados: usadas,
      ),
    );
    if (r == null) return;
    _coresSeletor
      ..clear()
      ..addEntries(r.map((i) => MapEntry(i.id, i.nome)));
    _sincronizarSeletores();
  }

  void _removerCor(int id) {
    if (_comValor(cor: id, tam: null)) {
      return _aviso('Zere as quantidades desta cor antes de remover.');
    }
    _coresSeletor.remove(id);
    _sincronizarSeletores();
  }

  Future<void> _escolherEstampa() async {
    final r = await VariacaoTelaCheia.abrir(
      context,
      _variacoes!,
      VariacaoTelaCheia(
        titulo: 'Estampa',
        subtitulo: _subtituloSeletor,
        lista: (s) => s.estampas,
        cadastrar: VariacoesEstampaCadastrada.new,
        singular: 'estampa',
        plural: 'estampas',
        modo: SeletorGenericoModo.unica,
        ocultos: _estampas.keys.toSet(),
      ),
    );
    if (r == null || r.isEmpty) return;
    _estampasMudaram([
      for (final e in _estampas.entries) _sd(e.key, e.value),
      r.first,
    ]);
  }

  void _removerEstampa(int id) {
    final comValor = _celulas.entries.any((e) {
      final p = e.key.split('|');
      return p.length > 2 && p[2] == '$id' && _ler(e.value) != null;
    });
    if (comValor) {
      return _aviso('Zere as quantidades desta estampa antes de remover.');
    }
    _estampasMudaram([
      for (final e in _estampas.entries)
        if (e.key != id) _sd(e.key, e.value),
    ]);
  }

  Future<void> _escolherTamanhos() async {
    final bloc = _variacoes!;
    final r = await TamanhosVariacaoTelaCheia.abrir(
      context,
      bloc,
      TamanhosVariacaoTelaCheia(
        subtitulo: _subtituloSeletor,
        selecionados: _tamanhos.keys.toSet(),
      ),
    );
    if (r == null) return;
    _tamanhosSeletor
      ..clear()
      ..addEntries(
        bloc.state.tamanhos.itens
            .where((t) => r.contains(t.id))
            .map((t) => MapEntry(t.id, t.nome)),
      );
    _sincronizarSeletores();
  }

  void _removerTamanho(int id) {
    if (_comValor(cor: null, tam: id)) {
      return _aviso('Zere as quantidades deste tamanho antes de remover.');
    }
    _tamanhosSeletor.remove(id);
    _sincronizarSeletores();
  }

  /// Cartão da esperada escolhida: quanto já foi contado e, se a referência
  /// ainda não tem variações, o convite para informar as cores e tamanhos.
  List<Widget> _avisoEsperada(SivColors cores, SivTextStyles textos) {
    final e = _esperadaEscolhida!;
    final esperado = e.quantidadeEsperada;
    return [
      if (esperado != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${qtd(_totalPecas)} de $esperado esperadas',
            key: const Key('esperada_x_de_y'),
            style: textos.apoio.copyWith(
              color: _totalPecas >= esperado
                  ? cores.conferidoTexto
                  : cores.parcialTexto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      if (e.nova && _cores.isEmpty)
        Container(
          key: const Key('esperada_sem_variacoes'),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cores.superficieRecuada,
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Text(
            'Esta referência ainda não tem variações. Adicione as cores e os '
            'tamanhos que chegaram.',
            style: textos.apoio,
          ),
        ),
    ];
  }

  /// "Numérico | Letras": carrega a grade com todos os tamanhos do tipo.
  static bool _nomeNumerico(String nome) =>
      RegExp(r'^\d+([.,]\d+)?$').hasMatch(nome.trim());

  /// Trocar o tipo tira da grade os tamanhos do outro tipo. Quantidade já
  /// digitada neles só é descartada depois de confirmar; o que veio de uma
  /// contagem já salva (`existentes`) nunca é descartado por aqui.
  Future<bool> _confirmarTrocaDeTipo(bool numerico) async {
    final salvos = {
      for (final c in widget.existentes)
        if (c.tamanhoId != null) c.tamanhoId!,
    };
    final comValor = [
      for (final e in _tamanhos.entries)
        if (_nomeNumerico(e.value) != numerico &&
            !salvos.contains(e.key) &&
            _comValor(cor: null, tam: e.key))
          e.key,
    ];
    if (comValor.isEmpty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trocar o tipo de tamanho?'),
        content: Text(
          'Os tamanhos ${numerico ? 'em letras' : 'numéricos'} que você já '
          'preencheu (${comValor.map((id) => _tamanhos[id]).join(', ')}) saem '
          'da grade e as quantidades digitadas neles são descartadas.',
        ),
        actions: [
          TextButton(
            key: const Key('trocar_tipo_cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            key: const Key('trocar_tipo_confirmar'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('TROCAR'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return false;
    for (final e in _celulas.entries) {
      if (comValor.contains(int.parse(e.key.split('|')[1]))) e.value.clear();
    }
    return true;
  }

  Future<void> _escolherTipoTamanho(bool numerico) async {
    if (!await _confirmarTrocaDeTipo(numerico)) return;
    // Colunas do outro tipo que sobraram (só as salvas) continuam; as demais
    // saem em _sincronizarSeletores.
    if (!mounted) return;
    setState(() {
      _tamanhosNumericos = numerico;
      _carregandoTamanhos = true;
    });
    try {
      final bloc = _variacoes!;
      var pronto = bloc.state;
      if (pronto.tamanhos.status != VariacaoStatus.sucesso) {
        if (pronto.tamanhos.status == VariacaoStatus.falha) {
          bloc.add(const VariacoesCarregadas());
        }
        pronto = await bloc.stream.firstWhere(
          (s) => s.tamanhos.status != VariacaoStatus.carregando,
        );
      }
      if (!mounted) return;
      if (pronto.tamanhos.status != VariacaoStatus.sucesso) {
        throw StateError('tamanhos');
      }
      final todos = pronto.tamanhos.itens;
      _tamanhosSeletor
        ..clear()
        ..addEntries(
          todos
              .where((t) => t.numerico == numerico)
              .map((t) => MapEntry(t.id, t.nome)),
        );
      _sincronizarSeletores();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível carregar os tamanhos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoTamanhos = false);
    }
  }

  Widget _tipoTamanho(SivColors cores, SivTextStyles textos) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rotulo('TIPO DE TAMANHO', cores, textos),
          SegmentedButton<bool>(
            key: const Key('tipo_tamanho'),
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(minimumSize: const Size(0, 48)),
            segments: const [
              ButtonSegment(value: true, label: Text('NUMÉRICO')),
              ButtonSegment(value: false, label: Text('LETRAS')),
            ],
            selected: {if (_tamanhosNumericos != null) _tamanhosNumericos!},
            onSelectionChanged: _carregandoTamanhos
                ? null
                : (s) {
                    if (s.isNotEmpty) _escolherTipoTamanho(s.first);
                  },
          ),
        ],
      );

  List<Widget> _campoReferencia(SivColors cores, SivTextStyles textos) {
    final fixa = widget.referenciaId != null || widget.linha != null;
    if (_referenciaId != null && (fixa || _referenciaNome != null)) {
      return [
        _rotulo('REFERÊNCIA', cores, textos),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_referenciaNome ?? widget.linha?.descricao ?? 'Referência'} · REF $_referenciaId',
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!fixa)
                IconButton(
                  tooltip: 'Trocar referência',
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () => setState(() {
                    _referenciaId = null;
                    _referenciaNome = null;
                  }),
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ];
    }
    if (widget.referenciaSeletor == null) return const [];
    return [
      widget.referenciaSeletor!(
        SeletorData(
          compacto: true,
          onChanged: (itens) => setState(() {
            _referenciaId = itens.isEmpty ? null : itens.first.id;
            _referenciaNome = null;
          }),
        ),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _camposLivre(SivColors cores, SivTextStyles textos) => [
        _rotulo('DESCRIÇÃO', cores, textos),
        TextField(
          key: const Key('contagem_descricao'),
          controller: _descricao,
          maxLength: 255,
          onChanged: (t) {
            setState(() {});
            _buscarParecidas(t);
          },
          decoration: const InputDecoration(
            hintText: 'Ex.: Body rendado vinho',
            counterText: '',
          ),
        ),
        if (_parecidas.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('parecidas'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cores.parcialFundo,
              border: Border.all(color: cores.parcialBorda),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Já existe? Referências parecidas',
                  style: textos.rotulo.copyWith(color: cores.parcialTexto),
                ),
                for (final r in _parecidas)
                  Row(
                    children: [
                      Expanded(
                        child: Text('${r.nome} · REF ${r.id}',
                            style: textos.corpo),
                      ),
                      TextButton(
                        key: Key('contar_nesta_${r.id}'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(44, 44),
                        ),
                        onPressed: () => _contarNesta(r),
                        child: const Text('Contar nesta →'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Cor e tamanho são obrigatórios.',
          style: textos.apoio,
        ),
        const SizedBox(height: 8),
      ];

  // --- grade fixa (C5) ---------------------------------------------------

  Color _tinta(SivColors cores) =>
      Color.alphaBlend(cores.aco.withValues(alpha: 0.16), cores.superficie);

  Widget _grade(SivColors cores, SivTextStyles textos, int est) {
    final cs = _cores.entries.toList();
    final ts = _tamanhos.entries.toList();
    final f = _foco3;
    final aqui = f != null && f.est == est;
    final alturaMax = ((MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom) *
            0.5)
        .clamp(160.0, 520.0);
    return GradeFixa(
      cores: [for (final c in cs) c.value],
      tamanhos: [for (final t in ts) t.value],
      subtotais: [for (final c in cs) '${qtd(_totalCorBloco(c.key, est))} pç'],
      linhaFoco: aqui ? cs.indexWhere((c) => c.key == f.cor) : null,
      colunaFoco: aqui ? ts.indexWhere((t) => t.key == f.tam) : null,
      alturaMax: alturaMax,
      celula: (l, c) {
        final cor = cs[l].key, tam = ts[c].key;
        final focada = aqui && f.cor == cor && f.tam == tam;
        final cruz = aqui && !focada && (f.cor == cor || f.tam == tam);
        final abaixo = _abaixoDoLido(cor, tam, est);
        OutlineInputBorder borda(Color cor, double w) => OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: BorderSide(color: cor, width: w),
            );
        final controller = _celula(cor, tam, est);
        // No Android o TextField vence qualquer arrasto horizontal; o toque é
        // do GestureDetector e o campo só recebe o foco, assim a grade rola
        // começando por uma célula.
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _foco(cor, tam, est).requestFocus();
            controller.selection =
                TextSelection(baseOffset: 0, extentOffset: controller.text.length);
          },
          child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            boxShadow: focada
                ? [
                    BoxShadow(
                      color: cores.aco.withValues(alpha: 0.28),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: IgnorePointer(child: TextField(
            key: Key(est == 0 ? 'contagem_${cor}_$tam' : 'contagem_${cor}_${tam}_e$est'),
            controller: controller,
            focusNode: _foco(cor, tam, est),
            textAlign: TextAlign.center,
            style: textos.secao,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              hintText: '—',
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              fillColor: abaixo
                  ? cores.excedenteFundo
                  : cruz
                      ? _tinta(cores)
                      : cores.superficie,
              border: borda(abaixo ? cores.vinho : cores.hairline, 1),
              enabledBorder: borda(abaixo ? cores.vinho : cores.hairline, 1),
              focusedBorder: borda(cores.aco, 2),
            ),
          )),
          ),
        );
      },
    );
  }

  double _totalCorBloco(int cor, int est) {
    var t = 0.0;
    for (final tam in _tamanhos.keys) {
      t += _ler(_celula(cor, tam, est)) ?? 0;
    }
    return t;
  }

  // --- faixa Editando + mapa 3x3 (C5) ------------------------------------

  Widget _faixaEditando(SivColors cores, SivTextStyles textos) {
    final f = _foco3;
    final cs = _cores.entries.toList();
    final ts = _tamanhos.entries.toList();
    final r = f == null ? -1 : cs.indexWhere((e) => e.key == f.cor);
    final c = f == null ? -1 : ts.indexWhere((e) => e.key == f.tam);
    if (f == null || r < 0 || c < 0) return const SizedBox.shrink();
    String nome(List<MapEntry<int, String>> l, int i) =>
        i >= 0 && i < l.length ? l[i].value : '';
    Widget vizinha(int dr, int dc) {
      final rr = r + dr, cc = c + dc;
      if (rr < 0 || rr >= cs.length || cc < 0 || cc >= ts.length) {
        return const SizedBox(width: 30, height: 24);
      }
      final centro = dr == 0 && dc == 0;
      final v = _ler(_celula(cs[rr].key, ts[cc].key, f.est));
      return GestureDetector(
        key: Key('mapa_${dr + 1}_${dc + 1}'),
        behavior: HitTestBehavior.opaque,
        onTap: centro
            ? null
            : () => _foco(cs[rr].key, ts[cc].key, f.est).requestFocus(),
        child: Container(
          width: 30,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: centro ? cores.aco : cores.superficie,
            border: Border.all(color: centro ? cores.aco : cores.hairline),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(v == null ? '' : qtd(v),
              style: textos.rotulo.copyWith(
                  fontSize: 12, color: centro ? cores.superficie : null)),
        ),
      );
    }

    Widget fila(int dr) => Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(nome(cs, r + dr),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.apoio.copyWith(
                        fontSize: 11,
                        fontWeight:
                            dr == 0 ? FontWeight.w700 : FontWeight.w400)),
              ),
              for (final dc in const [-1, 0, 1])
                Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: vizinha(dr, dc)),
            ],
          ),
        );

    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: Container(
          key: const Key('faixa_editando'),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border(top: BorderSide(color: cores.hairline)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EDITANDO',
                        style: textos.rotulo
                            .copyWith(fontSize: 10.5, color: cores.textoApoio)),
                    Text('${cs[r].value} · ${ts[c].value}',
                        key: const Key('editando_celula'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textos.secao
                            .copyWith(fontSize: 22, color: cores.acoEscuro)),
                    Text(
                        'linha ${r + 1} de ${cs.length} · coluna ${c + 1} de ${ts.length}',
                        key: const Key('editando_posicao'),
                        style: textos.apoio.copyWith(fontSize: 11)),
                  ],
                ),
                for (final t in ts)
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        key: Key(est == 0
                            ? 'contagem_${c.key}_${t.key}'
                            : 'contagem_${c.key}_${t.key}_e$est'),
                        controller: _celula(c.key, t.key, est),
                        focusNode: _foco(c.key, t.key, est),
                        textAlign: TextAlign.center,
                        style: textos.secao,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '—',
                          filled: true,
                          fillColor: _abaixoDoLido(c.key, t.key, est)
                              ? cores.excedenteFundo
                              : cores.superficie,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(SivDimensoes.raio),
                            borderSide: BorderSide(
                              color: _abaixoDoLido(c.key, t.key, est)
                                  ? cores.vinho
                                  : cores.hairline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final dr in const [-1, 0, 1]) fila(dr),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- resumo dos seletores com foco (C3) ---------------------------------

  List<Widget> _resumoSeletores(SivColors cores, SivTextStyles textos) {
    Widget link(String chave, String t, VoidCallback abrir) => TextButton(
          key: Key(chave),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            foregroundColor: cores.acoEscuro,
          ),
          onPressed: abrir,
          child: Text(t, style: textos.apoio.copyWith(color: cores.acoEscuro)),
        );
    final fixa = widget.estampaIdInicial != null;
    final estampa = fixa
        ? widget.estampaNomeInicial ?? '#${widget.estampaIdInicial}'
        : _estampas.values.join(', ');
    return [
      Wrap(
        key: const Key('resumo_seletores'),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          link('resumo_cores', '${_cores.length} cores', _escolherCores),
          Text('·', style: textos.apoio),
          link('resumo_tamanhos', '${_tamanhos.length} tamanhos',
              _escolherTamanhos),
          if (widget.linha == null &&
              widget.estampaSeletor != null &&
              (fixa || _variacoes != null || _estampas.isNotEmpty)) ...[
            Text('·', style: textos.apoio),
            if (fixa)
              Text('Estampa $estampa', style: textos.apoio)
            else
              link(
                'resumo_estampa',
                _estampas.isEmpty ? 'sem estampa' : 'Estampa $estampa',
                _escolherEstampa,
              ),
          ],
        ],
      ),
    ];
  }

  // --- Grade | Por cor (C5, 7d) --------------------------------------------

  Widget _seletorModo(SivColors cores, SivTextStyles textos) {
    final porCor = _modoPorCor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SegmentedButton<bool>(
        key: const Key('modo_grade_porcor'),
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(minimumSize: const Size(0, 36)),
        segments: const [
          ButtonSegment(value: false, label: Text('GRADE')),
          ButtonSegment(value: true, label: Text('POR COR')),
        ],
        selected: {porCor},
        onSelectionChanged: (s) => setState(() => _porCor = s.first),
      ),
    );
  }

  Widget _proximaCor(SivColors cores, SivTextStyles textos) {
    final ids = _cores.keys.toList();
    final i = ids.indexOf(_corAtivaId);
    final ultima = i + 1 >= ids.length;
    final proxima = ids[(i + 1) % ids.length];
    return TextButton(
      key: const Key('pc_proxima_cor'),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: cores.acoEscuro,
      ),
      onPressed: ids.length < 2 ? null : () => setState(() => _corAtiva = proxima),
      child: Text(
        ultima ? 'VOLTAR À PRIMEIRA COR' : 'PRÓXIMA COR · ${_cores[proxima]} →',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textos.rotulo.copyWith(
            color: cores.acoEscuro, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _porCorView(SivColors cores, SivTextStyles textos) {
    final ativa = _corAtivaId;
    return Column(
      key: const Key('por_cor'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final e in _cores.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    key: Key('pc_chip_${e.key}'),
                    canRequestFocus: false,
                    onTap: () => setState(() => _corAtiva = e.key),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: e.key == ativa
                            ? cores.acoEscuro
                            : cores.superficie,
                        border: Border.all(
                            color: e.key == ativa
                                ? cores.acoEscuro
                                : cores.hairline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.value,
                              style: textos.corpo.copyWith(
                                  color: e.key == ativa
                                      ? cores.superficie
                                      : null)),
                          const SizedBox(width: 8),
                          Text(qtd(_totalCor(e.key)),
                              style: textos.secao.copyWith(
                                  fontSize: 15,
                                  color: e.key == ativa
                                      ? cores.superficie
                                      : cores.textoApoio)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(_cores[ativa]!,
                  key: const Key('pc_titulo'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textos.secao
                      .copyWith(fontSize: 24, color: cores.acoEscuro)),
            ),
            Text('${qtd(_totalCor(ativa))} peças nesta cor',
                key: const Key('pc_total_cor'), style: textos.apoio),
          ],
        ),
        for (final est in _blocos) ...[
          if (_blocos.length > 1 || est != 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _rotulo(_nomeBloco(est), cores, textos),
            ),
          for (final t in _tamanhos.entries)
            _linhaTamanho(ativa, t.key, t.value, est, cores, textos),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _linhaTamanho(int cor, int tam, String nome, int est, SivColors cores,
      SivTextStyles textos) {
    final c = _celula(cor, tam, est);
    final sufixo = est == 0 ? '${cor}_$tam' : '${cor}_${tam}_e$est';
    final focada = _focado == _chave(cor, tam, est);
    final abaixo = _abaixoDoLido(cor, tam, est);
    Widget botao(String chave, String t, int delta) => InkWell(
          key: Key(chave),
          canRequestFocus: false,
          onTap: () => _ajustar(c, delta),
          child: Container(
            width: 48,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cores.superficie,
              border: Border.all(color: cores.hairline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(t, style: textos.secao.copyWith(fontSize: 22)),
          ),
        );
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: focada ? _tinta(cores) : null,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.secao
                    .copyWith(fontSize: 22, color: cores.acoEscuro)),
          ),
          const Spacer(),
          botao('pc_menos_$sufixo', '−', -1),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            height: 44,
            child: TextField(
              key: Key('pc_$sufixo'),
              controller: c,
              focusNode: _foco(cor, tam, est),
              textAlign: TextAlign.center,
              style: textos.secao.copyWith(fontSize: 22),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                hintText: '—',
                filled: true,
                fillColor: abaixo ? cores.excedenteFundo : cores.superficie,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      BorderSide(color: abaixo ? cores.vinho : cores.hairline),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          botao('pc_mais_$sufixo', '+', 1),
        ],
      ),
    );
  }
}
