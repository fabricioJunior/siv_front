import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
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
  final List<EntradaContagem> existentes;

  /// produtoId -> lido na conferência (o contado nunca fica abaixo dele).
  final Map<int, double> lidoPorProduto;

  /// Etiquetas já impressas por produto (não nulo = edição após etiquetas:
  /// o salvar mostra só a diferença a imprimir).
  final Map<int, double>? impressasPorProduto;
  final SeletorWidget? referenciaSeletor;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;
  final BuscaReferenciasParecidas? buscarParecidas;
  final void Function(bool livre, List<ItemContagem> itens) onSalvar;
  final VoidCallback onFechar;

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
    this.existentes = const [],
    this.lidoPorProduto = const {},
    this.impressasPorProduto,
    this.referenciaSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
    this.buscarParecidas,
    required this.onSalvar,
    required this.onFechar,
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
  late int? _referenciaId = widget.referenciaId ?? widget.linha?.referenciaId;
  late String? _referenciaNome = widget.referenciaNome;
  String? _focado;
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
      _celula(c.corId!, c.tamanhoId!).text = qtd(c.quantidade);
    }
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

  String _chave(int cor, int tam) => '$cor|$tam';

  TextEditingController _celula(int cor, int tam) =>
      _celulas.putIfAbsent(_chave(cor, tam), () {
        final c = TextEditingController();
        c.addListener(() {
          if (mounted) setState(() {});
        });
        return c;
      });

  FocusNode _foco(int cor, int tam) {
    final k = _chave(cor, tam);
    return _focos.putIfAbsent(k, () {
      final f = FocusNode();
      f.addListener(() {
        if (!mounted) return;
        if (f.hasFocus) {
          setState(() => _focado = k);
        } else if (_focado == k) {
          setState(() => _focado = null);
        }
      });
      return f;
    });
  }

  double? _ler(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  double? _lidoDaCelula(int cor, int tam) {
    for (final e in widget.existentes) {
      if (e.corId == cor && e.tamanhoId == tam) {
        return widget.lidoPorProduto[e.produtoId];
      }
    }
    return null;
  }

  bool _abaixoDoLido(int cor, int tam) {
    final lido = _lidoDaCelula(cor, tam);
    final v = _ler(_celula(cor, tam));
    return lido != null && v != null && v < lido;
  }

  bool get _temViolacao {
    if (_skuUnico) {
      final lido = widget.lidoPorProduto[widget.linha?.produtoId];
      final q = _ler(_simples);
      return lido != null && q != null && q < lido;
    }
    for (final cor in _cores.keys) {
      for (final tam in _tamanhos.keys) {
        if (_abaixoDoLido(cor, tam)) return true;
      }
    }
    return false;
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
      nomesCor.addAll(_cores);
      nomesTamanho.addAll(_tamanhos);
    });
  }

  bool _comValor({int? cor, int? tam}) {
    for (final e in _celulas.entries) {
      final p = e.key.split('|');
      final bate = (cor == null || p[0] == '$cor') && (tam == null || p[1] == '$tam');
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
      for (final cor in _cores.keys)
        for (final tam in _tamanhos.keys)
          if (_ler(_celula(cor, tam)) != null)
            ItemContagem(
              linhaId: widget.linha?.id,
              referenciaId: _livre ? null : _referenciaId,
              descricao: _livre ? descricao : null,
              corId: cor,
              tamanhoId: tam,
              quantidade: _ler(_celula(cor, tam))!,
            ),
    ];
  }

  double get _totalPecas {
    if (_skuUnico) return _ler(_simples) ?? 0;
    var t = 0.0;
    for (final cor in _cores.keys) {
      for (final tam in _tamanhos.keys) {
        t += _ler(_celula(cor, tam)) ?? 0;
      }
    }
    return t;
  }

  /// Etiquetas a imprimir a mais com a edição atual (3c/5j).
  double get _aImprimir {
    final imp = widget.impressasPorProduto;
    if (imp == null) return 0;
    var t = 0.0;
    for (final cor in _cores.keys) {
      for (final tam in _tamanhos.keys) {
        final v = _ler(_celula(cor, tam));
        if (v == null) continue;
        final produto = widget.existentes
            .where((e) => e.corId == cor && e.tamanhoId == tam)
            .map((e) => e.produtoId)
            .firstOrNull;
        final dif = v - (imp[produto] ?? 0);
        if (dif > 0) t += dif;
      }
    }
    return t;
  }

  bool get _podeSalvar =>
      !_temViolacao && _montar().isNotEmpty;

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
    if (c == null) return;
    final atual = _ler(c);
    if (atual == null && delta < 0) return;
    final novo = ((atual ?? 0) + delta).clamp(0, 999999).toDouble();
    c.text = qtd(novo);
    c.selection = TextSelection.collapsed(offset: c.text.length);
  }

  void _proxima() {
    final ordem = [
      for (final cor in _cores.keys)
        for (final tam in _tamanhos.keys) _chave(cor, tam),
    ];
    final i = ordem.indexOf(_focado ?? '');
    if (i < 0 || i + 1 >= ordem.length) {
      FocusScope.of(context).unfocus();
      return;
    }
    final p = ordem[i + 1].split('|');
    _foco(int.parse(p[0]), int.parse(p[1])).requestFocus();
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
            child: Text(rotulo, style: textos.rotulo.copyWith(
              color: cores.acoEscuro,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
          ),
        );
    return ExcludeFocus(
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
    );
  }

  // --- build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final tabs = widget.permiteTrocarAba;
    final podeSalvar = _podeSalvar;
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
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: _skuUnico ? _campoUnico() : _corpo(cores, textos),
            ),
          ),
          if (_focado != null) _barraTeclado(cores, textos),
          RodapeAcaoEntrada(
            resumo: Text(
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
      final sel = _livre == livre;
      return Expanded(
        child: InkWell(
          key: key,
          onTap: () => setState(() => _livre = livre),
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
              style: textos.rotulo.copyWith(
                color: sel ? cores.acoEscuro : cores.textoApoio,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
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
            decoration: const InputDecoration(labelText: 'Quantidade encontrada'),
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
        if (_livre) ..._camposLivre(cores, textos) else ..._campoReferencia(cores, textos),
        if (linhaNfe != null) ...[
          Text(
            'NF-e: ${qtd(linhaNfe.quantidadeNfe)} — digite o que foi '
            'encontrado em cada cor e tamanho.',
          ),
          const SizedBox(height: 12),
        ],
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
        const SizedBox(height: 16),
        if (_cores.isNotEmpty && _tamanhos.isNotEmpty) _grade(cores, textos),
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
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
                        child: Text('${r.nome} · REF ${r.id}', style: textos.corpo),
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

  Widget _grade(SivColors cores, SivTextStyles textos) {
    final cs = _cores.entries.toList();
    final ts = _tamanhos.entries.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(72),
        columnWidths: const {0: FixedColumnWidth(96)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final t in ts)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    t.value,
                    textAlign: TextAlign.center,
                    style: textos.secao,
                  ),
                ),
            ],
          ),
          for (final c in cs)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(c.value, style: textos.corpo),
                ),
                for (final t in ts)
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        key: Key('contagem_${c.key}_${t.key}'),
                        controller: _celula(c.key, t.key),
                        focusNode: _foco(c.key, t.key),
                        textAlign: TextAlign.center,
                        style: textos.secao,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '—',
                          filled: true,
                          fillColor: _abaixoDoLido(c.key, t.key)
                              ? cores.excedenteFundo
                              : cores.superficie,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(SivDimensoes.raio),
                            borderSide: BorderSide(
                              color: _abaixoDoLido(c.key, t.key)
                                  ? cores.vinho
                                  : cores.hairline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
