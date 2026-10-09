import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/bloc.dart';
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

  void _cadastrar(List<ContagemLivre> itens) =>
      context.read<PedidoEntradaBloc>().add(
            PedidoEntradaAssociouContagemLivre([for (final c in itens) c.id]),
          );

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
                    onCadastrar: () => _cadastrar(e.value),
                  ),
                if (variacoes.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: alturaBotaoPrincipal,
                      child: OutlinedButton(
                        key: const Key('cadastrar_todas_variacoes'),
                        onPressed: widget.salvando
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

class _GrupoVariacao extends StatelessWidget {
  final int referenciaId;
  final List<ContagemLivre> itens;
  final bool salvando;
  final VoidCallback onCadastrar;

  const _GrupoVariacao({
    super.key,
    required this.referenciaId,
    required this.itens,
    required this.salvando,
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
              '${nomesCor[c.corId] ?? '#${c.corId}'} · ${nomesTamanho[c.tamanhoId] ?? '#${c.tamanhoId}'} · ${qtd(c.quantidade)}',
              style: textos.corpo,
            ),
          const SizedBox(height: 4),
          Text('Esta cor/tamanho ainda não existe para a referência.',
              style: textos.apoio.copyWith(color: cores.parcialTexto)),
          const SizedBox(height: 12),
          BotaoPrincipalEntrada(
            key: Key('cadastrar_variacao_$referenciaId'),
            rotulo: itens.length > 1
                ? 'CADASTRAR ${itens.length} VARIAÇÕES'
                : 'CADASTRAR VARIAÇÃO',
            onPressed: salvando ? null : onCadastrar,
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

  const _GrupoAssociar({
    super.key,
    required this.descricao,
    required this.itens,
    required this.salvando,
    required this.seletores,
  });

  @override
  State<_GrupoAssociar> createState() => _GrupoAssociarState();
}

class _GrupoAssociarState extends State<_GrupoAssociar> {
  bool _criar = false;
  int? _referenciaId;

  void _associar([int? referenciaId]) {
    context.read<PedidoEntradaBloc>().add(
          PedidoEntradaAssociouContagemLivre(
            [for (final c in widget.itens) c.id],
            referenciaId: referenciaId ?? _referenciaId,
          ),
        );
  }

  /// Abre o wizard completo de cadastro de referência (rota montada no app),
  /// já com o nome e as cores/tamanhos contados; ao voltar com o id da
  /// referência criada, associa o grupo a ela.
  Future<void> _criarReferencia() async {
    final id = await Navigator.of(context).pushNamed<int>(
      '/referencia_cadastro',
      arguments: {
        'nome': widget.descricao,
        'corIds': widget.itens.map((c) => c.corId).toSet().toList(),
        'tamanhoIds': widget.itens.map((c) => c.tamanhoId).toSet().toList(),
      },
    );
    if (id != null && mounted) _associar(id);
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final pecas = widget.itens.fold<double>(0, (s, c) => s + c.quantidade);
    final resumo = widget.itens
        .map((c) =>
            '${nomesCor[c.corId] ?? '#${c.corId}'} ${nomesTamanho[c.tamanhoId] ?? '#${c.tamanhoId}'}·${qtd(c.quantidade)}')
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
          Text(widget.descricao,
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
          Text('$resumo · ${qtd(pecas)} peças', style: textos.apoio),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            key: Key('associar_modo_${widget.descricao}'),
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(0, 44)),
            ),
            segments: const [
              ButtonSegment(value: false, label: Text('Usar referência existente')),
              ButtonSegment(value: true, label: Text('Criar referência nova')),
            ],
            selected: {_criar},
            onSelectionChanged: (v) => setState(() => _criar = v.first),
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
              child: Text(_criar ? 'Criar referência nova' : 'Associar'),
            ),
          ),
        ],
      ),
    );
  }
}
