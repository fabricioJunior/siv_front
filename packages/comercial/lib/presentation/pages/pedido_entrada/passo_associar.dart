import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/foto_ampliada_dialog.dart';
import 'package:comercial/presentation/pages/pedido_entrada/fotos_livres.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Passo 2: um verbo só -- "Usar referência existente" ou "Criar referência
/// nova" -- para cada produto contado sem referência. As cores e tamanhos
/// contados viram SKUs (mesmo endpoint de sempre).
class PassoAssociar extends StatefulWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final SeletoresEntrada seletores;
  final ValueChanged<int> onIrParaPasso;

  const PassoAssociar({
    super.key,
    required this.resumo,
    required this.salvando,
    required this.seletores,
    required this.onIrParaPasso,
  });

  @override
  State<PassoAssociar> createState() => _PassoAssociarState();
}

class _PassoAssociarState extends State<PassoAssociar> {
  int _totalVisto = 0;

  /// descrição -> associação feita: só aparece quando o grupo já saiu da lista
  /// (aceita pelo servidor) e guarda o que precisa para desfazer.
  final _associados = <String, _Associado>{};

  /// Esperadas do fornecedor para sugestões de associação.
  List<ReferenciaEsperada> _esperadas = const [];

  @override
  void initState() {
    super.initState();
    _carregarEsperadas();
  }

  Future<void> _carregarEsperadas() async {
    try {
      final lista =
          await sl<ObterEsperadasEntrada>().call(widget.resumo.pedidoId);
      if (mounted) setState(() => _esperadas = lista);
    } catch (_) {
      // sem sugestões, fluxo segue normalmente
    }
  }

  /// Sugestões para um grupo pelo nome/descrição (top-3 por similaridade de nome).
  List<ReferenciaEsperada> _sugestoes(String descricao) {
    final termo = semAcento(descricao.trim());
    if (termo.isEmpty) return const [];
    return _esperadas
        .where((e) =>
            semAcento(e.nome).contains(termo) ||
            termo.contains(semAcento(e.nome.split(' ').first)))
        .take(3)
        .toList();
  }

  Map<String, List<ContagemLivre>> get _grupos {
    final g = <String, List<ContagemLivre>>{};
    for (final c in widget.resumo.livresSemReferencia) {
      g.putIfAbsent(c.descricao, () => []).add(c);
    }
    return g;
  }

  /// Variações novas (cor/tamanho sem SKU) agrupadas por referência.
  Map<int, List<ContagemLivre>> get _variacoes {
    final g = <int, List<ContagemLivre>>{};
    for (final c in widget.resumo.variacoesNovas) {
      g.putIfAbsent(c.referenciaId!, () => []).add(c);
    }
    return g;
  }

  bool get _podeCadastrarVariacao =>
      PermissaoPorNome.acessoPermitido('PRDFM008');

  void _cadastrar(List<ContagemLivre> itens) =>
      context.read<PedidoEntradaBloc>().add(
            PedidoEntradaAssociouContagemLivre([for (final c in itens) c.id]),
          );

  /// Erro na associação: devolve o grupo para "sem referência" (a referência
  /// criada, se houver, continua cadastrada).
  void _desfazer(String descricao, _Associado a) {
    _associados.remove(descricao);
    context.read<PedidoEntradaBloc>().add(
          PedidoEntradaDesassociouContagemLivre(a.referenciaId, [
            for (final c in a.itens)
              ItemContagem(
                descricao: c.descricao,
                corId: c.corId,
                tamanhoId: c.tamanhoId,
                estampaId: c.estampaId,
                quantidade: c.quantidade,
              ),
          ]),
        );
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _grupos;
    final variacoes = _variacoes;
    final total = grupos.length + variacoes.length;
    if (total > _totalVisto) _totalVisto = total;
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final faltam = total;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (faltam == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _totalVisto > 0
                        ? 'Tudo associado: $_totalVisto de $_totalVisto feitos.'
                        : 'Tudo com referência. Nada a associar.',
                    key: const Key('associar_tudo_feito'),
                    style: textos.corpo,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_totalVisto - faltam} de $_totalVisto feito',
                    style: textos.rotulo.copyWith(color: cores.textoApoio),
                  ),
                ),
              for (final e in _associados.entries)
                if (!grupos.containsKey(e.key))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('✓ ${e.key} → ${e.value.rotulo}',
                              key: Key('associado_${e.key}'),
                              style: textos.apoio
                                  .copyWith(color: cores.conferidoTexto)),
                        ),
                        TextButton(
                          key: Key('desfazer_${e.key}'),
                          onPressed: widget.salvando
                              ? null
                              : () => _desfazer(e.key, e.value),
                          child: const Text('DESFAZER'),
                        ),
                      ],
                    ),
                  ),
              if (variacoes.isNotEmpty) ...[
                Text('VARIAÇÕES NOVAS · cadastrar',
                    key: const Key('secao_variacoes_novas'),
                    style: textos.rotulo.copyWith(color: cores.parcialTexto)),
                const SizedBox(height: 8),
                for (final e in variacoes.entries)
                  _GrupoVariacao(
                    key: Key('grupo_variacao_${e.key}'),
                    referenciaId: e.key,
                    itens: e.value,
                    salvando: widget.salvando,
                    permitido: _podeCadastrarVariacao,
                    onCadastrar: () => _cadastrar(e.value),
                  ),
                if (variacoes.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: alturaBotaoPrincipal,
                      child: OutlinedButton(
                        key: const Key('cadastrar_todas_variacoes'),
                        onPressed: widget.salvando || !_podeCadastrarVariacao
                            ? null
                            : () => _cadastrar(
                                  [for (final v in variacoes.values) ...v],
                                ),
                        child: const Text('CADASTRAR TODAS'),
                      ),
                    ),
                  ),
                if (grupos.isNotEmpty) const SizedBox(height: 8),
              ],
              if (grupos.isNotEmpty && variacoes.isNotEmpty)
                Text('SEM REFERÊNCIA · associar',
                    style: textos.rotulo.copyWith(color: cores.parcialTexto)),
              for (final e in grupos.entries)
                _GrupoAssociar(
                  key: Key('grupo_associar_${e.key}'),
                  descricao: e.key,
                  itens: e.value,
                  salvando: widget.salvando,
                  seletores: widget.seletores,
                  sugestoes: _sugestoes(e.key),
                  fotos: widget.resumo.fotosDaDescricao(e.key),
                  onAssociou: (ref, criada) =>
                      _associados[e.key] = _Associado(ref, criada, e.value),
                ),
            ],
          ),
        ),
        RodapeAcaoEntrada(
          aviso: faltam > 0
              ? Text(
                  'Falta $faltam. As etiquetas liberam quando todos estiverem associados.',
                  key: const Key('associar_bloqueio'),
                  style: textos.apoio.copyWith(color: cores.parcialTexto),
                )
              : null,
          acao: BotaoPrincipalEntrada(
            key: const Key('associar_imprimir_etiquetas'),
            rotulo: 'IMPRIMIR ETIQUETAS',
            onPressed:
                faltam > 0 || widget.salvando ? null : () => widget.onIrParaPasso(2),
          ),
        ),
      ],
    );
  }
}

class _Associado {
  final int referenciaId;
  final bool criada;
  final List<ContagemLivre> itens;
  const _Associado(this.referenciaId, this.criada, this.itens);

  String get rotulo =>
      'REF $referenciaId · ${criada ? 'criada agora' : 'associada'}';
}

class _GrupoVariacao extends StatelessWidget {
  final int referenciaId;
  final List<ContagemLivre> itens;
  final bool salvando;
  final bool permitido;
  final VoidCallback onCadastrar;

  const _GrupoVariacao({
    super.key,
    required this.referenciaId,
    required this.itens,
    required this.salvando,
    required this.permitido,
    required this.onCadastrar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final nome = itens.first.referenciaNome ?? itens.first.descricao;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cores.parcialFundo,
        border: Border.all(color: cores.parcialBorda),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$nome · REF $referenciaId',
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          for (final c in itens)
            Text(
              '${c.corNome ?? nomesCor[c.corId] ?? '#${c.corId}'} · ${c.tamanhoNome ?? nomesTamanho[c.tamanhoId] ?? '#${c.tamanhoId}'} · ${qtd(c.quantidade)}',
              style: textos.corpo,
            ),
          const SizedBox(height: 4),
          Text(
              permitido
                  ? 'Esta cor/tamanho ainda não existe para a referência.'
                  : 'Sem permissão para cadastrar variação (cor/tamanho novo).',
              key: permitido ? null : const Key('sem_permissao_variacao'),
              style: textos.apoio.copyWith(color: cores.parcialTexto)),
          const SizedBox(height: 12),
          BotaoPrincipalEntrada(
            key: Key('cadastrar_variacao_$referenciaId'),
            rotulo: itens.length > 1
                ? 'CADASTRAR ${itens.length} VARIAÇÕES'
                : 'CADASTRAR VARIAÇÃO',
            onPressed: salvando || !permitido ? null : onCadastrar,
          ),
        ],
      ),
    );
  }
}

class _GrupoAssociar extends StatefulWidget {
  final String descricao;
  final List<ContagemLivre> itens;
  final bool salvando;
  final SeletoresEntrada seletores;
  final List<ReferenciaEsperada> sugestoes;
  final List<FotoLivre> fotos;
  final void Function(int referenciaId, bool criada) onAssociou;

  const _GrupoAssociar({
    super.key,
    required this.descricao,
    required this.itens,
    required this.salvando,
    required this.seletores,
    this.sugestoes = const [],
    this.fotos = const [],
    required this.onAssociou,
  });

  @override
  State<_GrupoAssociar> createState() => _GrupoAssociarState();
}

class _GrupoAssociarState extends State<_GrupoAssociar> {
  bool _criar = false;
  bool _naoCadastrada = false;
  int? _referenciaId;
  final bool _podeCriar = PermissaoPorNome.acessoPermitido('PRDFM003');

  void _selecionarSugestao(ReferenciaEsperada e) {
    setState(() {
      _referenciaId = e.id;
      _criar = false;
    });
  }

  void _associar([int? criadaId]) {
    final ref = criadaId ?? _referenciaId;
    if (ref != null) widget.onAssociou(ref, criadaId != null);
    setState(() => _naoCadastrada = false);
    context.read<PedidoEntradaBloc>().add(
          PedidoEntradaAssociouContagemLivre(
            [for (final c in widget.itens) c.id],
            referenciaId: ref,
            descricao: widget.descricao,
          ),
        );
  }

  /// Abre o wizard completo de cadastro de referência (rota montada no app),
  /// já com o nome e as cores/tamanhos contados; ao voltar com o id da
  /// referência criada, associa o grupo a ela.
  Future<void> _criarReferencia() async {
    // Sem type arg: o onGenerateRoute cria MaterialPageRoute<dynamic> e o cast quebra.
    final fornecedor = context.read<PedidoEntradaBloc>().state.resumo?.fornecedor;
    final id = await Navigator.of(context).pushNamed(
      '/referencia_cadastro',
      arguments: {
        'nome': widget.descricao,
        'fornecedorId': fornecedor?.id,
        'fornecedorNome': fornecedor?.nome,
        'corIds': widget.itens.map((c) => c.corId).toSet().toList(),
        'tamanhoIds': widget.itens.map((c) => c.tamanhoId).toSet().toList(),
      },
    );
    if (!mounted) return;
    if (id is int) {
      _associar(id);
    } else {
      setState(() => _naoCadastrada = true);
    }
  }

  Widget _avisoNaoCadastrada(SivTextStyles textos, SivColors cores) =>
      Container(
        key: Key('aviso_nao_cadastrada_${widget.descricao}'),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cores.parcialFundo,
          border: Border.all(color: cores.parcialBorda),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Referência não cadastrada. “${widget.descricao}” continua sem '
              'referência e não foi associado.',
              style: textos.apoio.copyWith(color: cores.parcialTexto),
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('aviso_tentar_de_novo'),
                  onPressed: widget.salvando ? null : _criarReferencia,
                  child: const Text('TENTAR DE NOVO'),
                ),
                TextButton(
                  key: const Key('aviso_usar_existente'),
                  onPressed: () => setState(() {
                    _criar = false;
                    _naoCadastrada = false;
                  }),
                  child: const Text('Usar referência existente'),
                ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final pecas = widget.itens.fold<double>(0, (s, c) => s + c.quantidade);
    final resumo = widget.itens
        .map((c) =>
            '${c.corNome ?? nomesCor[c.corId] ?? '#${c.corId}'} ${c.tamanhoNome ?? nomesTamanho[c.tamanhoId] ?? '#${c.tamanhoId}'}·${qtd(c.quantidade)}')
        .join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.sugestoes.isNotEmpty) ...[
            Text(
              'Aguardando do fornecedor',
              style: textos.rotulo.copyWith(color: cores.textoApoio),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 108,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.sugestoes.length,
                itemBuilder: (ctx, i) {
                  final s = widget.sugestoes[i];
                  final selecionada = _referenciaId == s.id;
                  return _CardSugestao(
                    key: Key('sugestao_${s.id}'),
                    esperada: s,
                    selecionada: selecionada,
                    onSelecionar: () => _selecionarSugestao(s),
                    onAmplifcarFoto: s.fotos.isEmpty
                        ? null
                        : (indice) => showFotoAmpliada(
                              context,
                              referenciaNome: s.nome,
                              referenciaCodigo: 'REF ${s.id}',
                              fotos: s.fotos,
                              indiceInicial: indice,
                              onAssociar: () => _selecionarSugestao(s),
                            ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.fotos.isNotEmpty) ...[
            FotosLivres(
              descricao: widget.descricao,
              fotos: widget.fotos,
              tamanho: 88,
            ),
            const SizedBox(height: 8),
          ],
          Text(widget.descricao,
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
          Text('$resumo · ${qtd(pecas)} peças', style: textos.apoio),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            key: Key('associar_modo_${widget.descricao}'),
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(0, 44)),
            ),
            segments: [
              const ButtonSegment(
                  value: false, label: Text('Usar referência existente')),
              ButtonSegment(
                  value: true,
                  enabled: _podeCriar,
                  label: const Text('Criar referência nova')),
            ],
            selected: {_criar && _podeCriar},
            onSelectionChanged: (v) => setState(() {
              _criar = v.first;
              _naoCadastrada = false;
            }),
          ),
          if (_naoCadastrada) _avisoNaoCadastrada(textos, cores),
          if (!_podeCriar)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Sem permissão para cadastrar referência',
                  key: const Key('sem_permissao_referencia'),
                  style: textos.apoio),
            ),
          const SizedBox(height: 12),
          if (!_criar)
            widget.seletores.referenciaContagemSeletor(
              SeletorData(
                compacto: true,
                onChanged: (itens) => setState(
                  () => _referenciaId = itens.isEmpty ? null : itens.first.id,
                ),
              ),
            )
          else
            Text(
              'Abre o cadastro completo da referência, já com as cores e '
              'tamanhos contados. Ao concluir, o grupo é associado a ela.',
              style: textos.apoio,
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              key: Key(_criar
                  ? 'entrada_criar_referencia_${widget.descricao}'
                  : 'entrada_associar_${widget.descricao}'),
              onPressed: widget.salvando
                  ? null
                  : _criar
                      ? _criarReferencia
                      : _referenciaId != null
                          ? _associar
                          : null,
              child: Text(_criar
                  ? 'Criar referência nova'
                  : _referenciaId != null
                      ? 'ASSOCIAR A REF $_referenciaId'
                      : 'Associar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de sugestão do fornecedor (rolagem horizontal em _GrupoAssociar).
class _CardSugestao extends StatelessWidget {
  final ReferenciaEsperada esperada;
  final bool selecionada;
  final VoidCallback onSelecionar;
  final void Function(int indice)? onAmplifcarFoto;

  const _CardSugestao({
    super.key,
    required this.esperada,
    required this.selecionada,
    required this.onSelecionar,
    this.onAmplifcarFoto,
  });

  static const double _fotoLado = 88.0;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final foto = esperada.fotos.isNotEmpty ? esperada.fotos.first : null;

    return GestureDetector(
      onTap: onSelecionar,
      child: Container(
        width: 96,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          border: Border.all(
            color: selecionada
                ? Theme.of(context).colorScheme.primary
                : cores.hairline,
            width: selecionada ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: foto != null && onAmplifcarFoto != null
                  ? () => onAmplifcarFoto!(0)
                  : onSelecionar,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SivDimensoes.raio - 1),
                ),
                child: foto != null
                    ? Image.network(
                        foto.urlParaMiniatura,
                        width: 96,
                        height: _fotoLado,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SizedBox(
                          width: 96,
                          height: _fotoLado,
                          child: Icon(Icons.image_outlined,
                              color: cores.textoApoio),
                        ),
                      )
                    : Container(
                        width: 96,
                        height: _fotoLado,
                        color: cores.hairline,
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Color(0xFFFFA000)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                esperada.nome,
                style: textos.apoio.copyWith(
                  fontWeight:
                      selecionada ? FontWeight.w700 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
