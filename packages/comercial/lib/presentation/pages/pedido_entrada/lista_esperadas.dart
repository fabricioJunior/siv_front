import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/adicionar_foto_contagem.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/foto_ampliada_dialog.dart';
import 'package:core/borda_tracejada.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

enum FiltroEsperadas { todas, primeiraEntrada, reposicao }

/// Modo "Esperadas" do painel de contagem: referências do fornecedor da entrada
/// cadastradas antes da peça chegar. O contador escolhe na lista (com foto)
/// em vez de digitar a descrição. Só informa: nada daqui bloqueia a entrada.
class ListaEsperadas extends StatefulWidget {
  final List<ReferenciaEsperada> esperadas;

  /// Peças já contadas nesta entrada, por referência.
  final Map<int, double> contadoPorReferencia;
  final ValueChanged<ReferenciaEsperada> onEscolher;

  /// Chamado quando uma foto de chegada é registrada com sucesso.
  /// Permite ao pai atualizar a lista localmente sem reload.
  final void Function(int referenciaId, ReferenciaMidiaSimples foto)?
      onFotoChegadaRegistrada;

  const ListaEsperadas({
    super.key,
    required this.esperadas,
    required this.contadoPorReferencia,
    required this.onEscolher,
    this.onFotoChegadaRegistrada,
  });

  @override
  State<ListaEsperadas> createState() => _ListaEsperadasState();
}

class _ListaEsperadasState extends State<ListaEsperadas> {
  String _busca = '';
  FiltroEsperadas _filtro = FiltroEsperadas.todas;

  /// Fotos de chegada adicionadas localmente (key = referenciaId).
  final _fotosChegada = <int, List<ReferenciaMidiaSimples>>{};

  List<ReferenciaMidiaSimples> _fotosEsperada(ReferenciaEsperada e) => [
        ...e.fotos,
        ...(_fotosChegada[e.id] ?? const []),
      ];

  int _total(FiltroEsperadas f) =>
      widget.esperadas.where((e) => _passa(e, f)).length;

  bool _passa(ReferenciaEsperada e, FiltroEsperadas f) => switch (f) {
        FiltroEsperadas.todas => true,
        FiltroEsperadas.primeiraEntrada => e.aguardandoPrimeiraEntrada,
        FiltroEsperadas.reposicao => e.aguardandoReposicao,
      };

  Future<void> _tirarFoto(BuildContext context, ReferenciaEsperada e) async {
    final foto = await adicionarFotoContagem(context, e.id);
    if (foto == null || !mounted) return;
    setState(() => _fotosChegada.putIfAbsent(e.id, () => []).add(foto));
    widget.onFotoChegadaRegistrada?.call(e.id, foto);
  }

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
              fotos: _fotosEsperada(e),
              contado: widget.contadoPorReferencia[e.id] ?? 0,
              onTap: () => widget.onEscolher(e),
              onTirarFoto: () => _tirarFoto(context, e),
              onAmplifcar: (indice) => showFotoAmpliada(
                context,
                referenciaNome: e.nome,
                referenciaCodigo: [
                  if (e.codigoNoFornecedor != null &&
                      e.codigoNoFornecedor!.isNotEmpty)
                    'Cód. ${e.codigoNoFornecedor}',
                  'REF ${e.id}',
                ].join(' · '),
                fotos: _fotosEsperada(e),
                indiceInicial: indice,
                onContar: () => widget.onEscolher(e),
              ),
            ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Não está na lista? Use Com referência ou Sem referência.',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _Legenda(),
      ],
    );
  }
}

class _Legenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _LegendaItem(
          cor: const Color(0xFF34495E),
          rotulo: 'Foto do fornecedor',
          textos: textos,
          cores: cores,
        ),
        _LegendaItem(
          cor: const Color(0xFF416180),
          rotulo: 'Tirada na chegada',
          textos: textos,
          cores: cores,
        ),
        _LegendaItem(
          cor: null,
          rotulo: 'Foto da referência',
          textos: textos,
          cores: cores,
        ),
      ],
    );
  }
}

class _LegendaItem extends StatelessWidget {
  final Color? cor;
  final String rotulo;
  final SivTextStyles textos;
  final SivColors cores;

  const _LegendaItem({
    required this.cor,
    required this.rotulo,
    required this.textos,
    required this.cores,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor ?? cores.hairline,
            borderRadius: BorderRadius.circular(2),
            border: cor == null ? Border.all(color: cores.hairline) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(rotulo, style: textos.apoio.copyWith(color: cores.textoApoio)),
      ],
    );
  }
}

class _ItemEsperada extends StatelessWidget {
  final ReferenciaEsperada esperada;
  final List<ReferenciaMidiaSimples> fotos;
  final double contado;
  final VoidCallback onTap;
  final VoidCallback onTirarFoto;
  final void Function(int indice) onAmplifcar;

  const _ItemEsperada({
    required this.esperada,
    required this.fotos,
    required this.contado,
    required this.onTap,
    required this.onTirarFoto,
    required this.onAmplifcar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final situacao = esperada.situacao(contado);
    final contada = situacao != SituacaoContagemEsperada.naoContada;
    final codigo = esperada.codigoNoFornecedor;

    return Opacity(
      opacity: contada ? 0.7 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        decoration: BoxDecoration(
          color: contada ? const Color(0xFFF7F8F6) : null,
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // miniatura — toque abre ampliação
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _MiniaturasEsperada(
                fotos: fotos,
                onTirarFoto: onTirarFoto,
                onAmplifcar: onAmplifcar,
              ),
            ),
            const SizedBox(width: 12),
            // texto — toque abre contagem
            Expanded(
              child: InkWell(
                key: Key('esperada_${esperada.id}'),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esperada.nome,
                        style:
                            textos.corpo.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        [
                          if (codigo != null && codigo.isNotEmpty)
                            'Cód. $codigo',
                          'REF ${esperada.id}',
                        ].join(' · '),
                        style:
                            textos.apoio.copyWith(color: cores.textoApoio),
                      ),
                      Text(esperada.resumoGrade, style: textos.apoio),
                      if (esperada.estampas.isNotEmpty)
                        Text(
                          'Estampas: ${esperada.estampas.join(', ')}',
                          style: textos.apoio,
                        ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (esperada.nova)
                            const _EtiquetaStatus('Nova', tracejada: true),
                          if (esperada.aguardandoPrimeiraEntrada)
                            const _EtiquetaStatus('Aguardando 1ª entrada'),
                          if (esperada.aguardandoReposicao)
                            const _EtiquetaStatus('Aguardando reposição'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _Quantidade(
                      esperada: esperada,
                      contado: contado,
                      situacao: situacao),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniatura(s) de foto na lista de esperadas.
class _MiniaturasEsperada extends StatelessWidget {
  final List<ReferenciaMidiaSimples> fotos;
  final VoidCallback onTirarFoto;
  final void Function(int indice) onAmplifcar;

  const _MiniaturasEsperada({
    required this.fotos,
    required this.onTirarFoto,
    required this.onAmplifcar,
  });

  static const double _lado = 64.0;

  Color _corBorda(ReferenciaMidiaSimples foto) {
    if (foto.doFornecedor) return const Color(0xFF34495E);
    if (foto.daChegada) return const Color(0xFF416180);
    return const Color(0xFFCFD8DC);
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    if (fotos.isEmpty && !podeAdicionarFotoContagem) {
      return SizedBox(
        width: _lado,
        height: _lado,
        child: Icon(Icons.image_not_supported_outlined,
            color: cores.textoDesabilitado),
      );
    }
    if (fotos.isEmpty) {
      // atalho tracejado âmbar para tirar foto
      return GestureDetector(
        onTap: onTirarFoto,
        child: BordaTracejada(
          cor: const Color(0xFFFFA000),
          child: SizedBox(
            width: _lado,
            height: _lado,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: const Color(0xFFFFA000), size: 20),
                const SizedBox(height: 2),
                Text(
                  'FOTO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final foto = fotos.first;
    final temMais = fotos.length > 1;

    final miniatura = GestureDetector(
      onTap: () => onAmplifcar(0),
      child: Stack(
        children: [
          Container(
            width: _lado,
            height: _lado,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _corBorda(foto), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(
                foto.urlParaMiniatura,
                width: _lado,
                height: _lado,
                fit: BoxFit.cover,
                cacheWidth: (_lado * 3).round(),
                errorBuilder: (c, e, s) => Icon(
                  Icons.broken_image_outlined,
                  color: cores.textoApoio,
                ),
              ),
            ),
          ),
          // faixa de origem
          if (foto.doFornecedor || foto.daChegada)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _corBorda(foto).withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  foto.doFornecedor ? 'FORNEC.' : 'CHEGADA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // contador de fotos extras
          if (temMais)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${fotos.length - 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!podeAdicionarFotoContagem) return miniatura;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        miniatura,
        TextButton.icon(
          key: const Key('esperada_mais_foto'),
          onPressed: onTirarFoto,
          icon: const Icon(Icons.add_a_photo_outlined, size: 14),
          label: const Text('FOTO', style: TextStyle(fontSize: 10)),
          style: TextButton.styleFrom(
            minimumSize: const Size(_lado, 28),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
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
