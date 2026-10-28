import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/borda_tracejada.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

enum FiltroEsperadas { todas, primeiraEntrada, reposicao }

/// Modo "Esperadas" do painel de contagem: referências do fornecedor da entrada
/// cadastradas antes da peça chegar. O contador escolhe na lista (com foto)
/// em vez de digitar a descrição. Só informa: nada daqui bloqueia a entrada.
class ListaEsperadas extends StatefulWidget {
  final List<ReferenciaEsperada> esperadas;

  /// Peças já contadas nesta entrada, por referência.
  final Map<int, double> contadoPorReferencia;
  final ValueChanged<ReferenciaEsperada> onEscolher;

  const ListaEsperadas({
    super.key,
    required this.esperadas,
    required this.contadoPorReferencia,
    required this.onEscolher,
  });

  @override
  State<ListaEsperadas> createState() => _ListaEsperadasState();
}

class _ListaEsperadasState extends State<ListaEsperadas> {
  String _busca = '';
  FiltroEsperadas _filtro = FiltroEsperadas.todas;

  int _total(FiltroEsperadas f) => widget.esperadas.where((e) => _passa(e, f)).length;

  bool _passa(ReferenciaEsperada e, FiltroEsperadas f) => switch (f) {
        FiltroEsperadas.todas => true,
        FiltroEsperadas.primeiraEntrada => e.aguardandoPrimeiraEntrada,
        FiltroEsperadas.reposicao => e.aguardandoReposicao,
      };

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final visiveis = ordenarEsperadas(
      widget.esperadas
          .where((e) => _passa(e, _filtro) && esperadaCorresponde(e, _busca))
          .toList(),
      widget.contadoPorReferencia,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('esperadas_busca'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Nome, código do fornecedor ou REF',
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (filtro, rotulo) in [
              (FiltroEsperadas.todas, 'Todas'),
              (FiltroEsperadas.primeiraEntrada, '1ª entrada'),
              (FiltroEsperadas.reposicao, 'Reposição'),
            ])
              ChoiceChip(
                key: Key('esperadas_filtro_${filtro.name}'),
                label: Text('$rotulo · ${_total(filtro)}'),
                selected: _filtro == filtro,
                onSelected: (_) => setState(() => _filtro = filtro),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (visiveis.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma referência esperada com esse filtro.',
              key: const Key('esperadas_vazio'),
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          )
        else
          for (final e in visiveis)
            _ItemEsperada(
              esperada: e,
              contado: widget.contadoPorReferencia[e.id] ?? 0,
              onTap: () => widget.onEscolher(e),
            ),
        const SizedBox(height: 12),
        Text(
          'Não está na lista? Use Com referência ou Sem referência.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
      ],
    );
  }
}

class _ItemEsperada extends StatelessWidget {
  final ReferenciaEsperada esperada;
  final double contado;
  final VoidCallback onTap;

  const _ItemEsperada({
    required this.esperada,
    required this.contado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final situacao = esperada.situacao(contado);
    final contada = situacao != SituacaoContagemEsperada.naoContada;
    final codigo = esperada.codigoNoFornecedor;

    return Opacity(
      opacity: contada ? 0.6 : 1,
      child: InkWell(
        key: Key('esperada_${esperada.id}'),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cores.hairline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FotoEsperada(url: esperada.foto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esperada.nome,
                      style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        if (codigo != null && codigo.isNotEmpty) 'Cód. $codigo',
                        'REF ${esperada.id}',
                      ].join(' · '),
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                    Text(esperada.resumoGrade, style: textos.apoio),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (esperada.nova) const _EtiquetaStatus('Nova', tracejada: true),
                        if (esperada.aguardandoPrimeiraEntrada)
                          const _EtiquetaStatus('Aguardando 1ª entrada'),
                        if (esperada.aguardandoReposicao)
                          const _EtiquetaStatus('Aguardando reposição'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Quantidade(esperada: esperada, contado: contado, situacao: situacao),
            ],
          ),
        ),
      ),
    );
  }
}

class _Quantidade extends StatelessWidget {
  final ReferenciaEsperada esperada;
  final double contado;
  final SituacaoContagemEsperada situacao;

  const _Quantidade({
    required this.esperada,
    required this.contado,
    required this.situacao,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final esperado = esperada.quantidadeEsperada;
    return switch (situacao) {
      SituacaoContagemEsperada.naoContada => esperado == null
          ? const SizedBox.shrink()
          : Text('$esperado esperadas', style: textos.apoio),
      SituacaoContagemEsperada.contada => Text(
          '✓ contado',
          style: textos.apoio.copyWith(color: cores.conferidoTexto),
        ),
      // verde quando contado >= esperado; âmbar quando falta (só informa)
      SituacaoContagemEsperada.completa => Text(
          '${qtd(contado)}/$esperado',
          style: textos.secao.copyWith(color: cores.conferidoTexto),
        ),
      SituacaoContagemEsperada.parcial => Text(
          '${qtd(contado)}/$esperado',
          style: textos.secao.copyWith(color: cores.parcialTexto),
        ),
    };
  }
}

class _FotoEsperada extends StatelessWidget {
  final String? url;
  const _FotoEsperada({required this.url});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    const lado = 52.0;
    final vazio = BordaTracejada(
      cor: cores.hairline,
      child: SizedBox(
        width: lado,
        height: lado,
        child: Icon(Icons.image_outlined, color: cores.textoApoio),
      ),
    );
    if (url == null || url!.isEmpty) return vazio;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: lado,
        height: lado,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => vazio,
      ),
    );
  }
}

const _azulNova = Color(0xFF5980A6);

class _EtiquetaStatus extends StatelessWidget {
  final String texto;
  final bool tracejada;
  const _EtiquetaStatus(this.texto, {this.tracejada = false});

  @override
  Widget build(BuildContext context) {
    final conteudo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tracejada ? _azulNova : const Color(0xFF34495E),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
    if (tracejada) return BordaTracejada(cor: _azulNova, child: conteudo);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC9D7E4)),
      ),
      child: conteudo,
    );
  }
}
