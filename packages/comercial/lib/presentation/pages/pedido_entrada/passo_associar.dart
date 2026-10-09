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
    for (final c in widget.resumo.contagensLivres) {
      g.putIfAbsent(c.descricao, () => []).add(c);
    }
    return g;
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _grupos;
    if (grupos.length > _totalVisto) _totalVisto = grupos.length;
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final faltam = grupos.length;

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
  late final _nome = TextEditingController(text: widget.descricao);
  bool _criar = false;
  int? _referenciaId;
  int? _categoriaId;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  bool get _pronto => (_criar ? _categoriaId : _referenciaId) != null;

  void _associar() {
    context.read<PedidoEntradaBloc>().add(
          PedidoEntradaAssociouContagemLivre(
            [for (final c in widget.itens) c.id],
            referenciaId: _criar ? null : _referenciaId,
            categoriaId: _criar ? _categoriaId : null,
            nome: _criar && _nome.text.trim().isNotEmpty
                ? _nome.text.trim()
                : null,
          ),
        );
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
          else ...[
            Text('NOME DA REFERÊNCIA',
                style: textos.rotulo.copyWith(color: cores.aco)),
            TextField(controller: _nome),
            const SizedBox(height: 12),
            Text('CATEGORIA', style: textos.rotulo.copyWith(color: cores.aco)),
            widget.seletores.categoriaSeletor(
              SeletorData(
                compacto: true,
                onChanged: (itens) => setState(
                  () => _categoriaId = itens.isEmpty ? null : itens.first.id,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fornecedor e preço vêm do pedido. As cores e tamanhos contados viram SKUs.',
              style: textos.apoio,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              key: Key('entrada_associar_${widget.descricao}'),
              onPressed: _pronto && !widget.salvando ? _associar : null,
              child: const Text('Associar'),
            ),
          ),
        ],
      ),
    );
  }
}
