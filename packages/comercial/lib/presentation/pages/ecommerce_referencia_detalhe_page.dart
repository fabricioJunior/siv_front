import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencia_detalhe_bloc/ecommerce_referencia_detalhe_bloc.dart';
import 'package:comercial/presentation/widgets/ecommerce_formatadores.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

const _alturaLinhaMatriz = 44.0;
const _larguraCelulaMatriz = 76.0;

/// Item da checklist de publicação: sempre reflete o veredito do backend
/// quando ele existe (`motivosBloqueio` / `publicavel`) -- a derivação local
/// só entra quando os dois vierem nulos, e nesse caso o interruptor nunca
/// trava por causa dela.
class _ItemChecklist {
  final String titulo;
  final bool ok;
  final String? pendenciaTexto;

  const _ItemChecklist({
    required this.titulo,
    required this.ok,
    this.pendenciaTexto,
  });
}

class _Checklist {
  final List<_ItemChecklist> itens;
  final bool bloqueiaSwitch;
  final bool estimativa;

  const _Checklist({
    required this.itens,
    required this.bloqueiaSwitch,
    required this.estimativa,
  });

  List<_ItemChecklist> get pendencias => itens.where((i) => !i.ok).toList();
}

class EcommerceReferenciaDetalhePage extends StatefulWidget {
  final int ecommerceId;
  final EcommerceReferencia referencia;
  final String? tituloCanal;

  const EcommerceReferenciaDetalhePage({
    super.key,
    required this.ecommerceId,
    required this.referencia,
    this.tituloCanal,
  });

  @override
  State<EcommerceReferenciaDetalhePage> createState() =>
      _EcommerceReferenciaDetalhePageState();
}

class _EcommerceReferenciaDetalhePageState
    extends State<EcommerceReferenciaDetalhePage> {
  late final EcommerceReferenciaDetalheBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<EcommerceReferenciaDetalheBloc>()
      ..add(
        EcommerceReferenciaDetalheIniciou(
          ecommerceId: widget.ecommerceId,
          referenciaEcommerceId: widget.referencia.id!,
          referenciaId: widget.referencia.referenciaId,
          rascunho: widget.referencia.rascunho,
        ),
      );
    _atualizarTitulo();
    SivPageAcoes.definir([_botaoEditar(context)]);
  }

  @override
  void dispose() {
    _bloc.close();
    SivPageTitulo.limpar();
    SivPageAcoes.limpar();
    super.dispose();
  }

  void _atualizarTitulo() {
    final canal = widget.tituloCanal;
    final nomeReferencia = widget.referencia.referenciaNome ??
        'Referência #${widget.referencia.referenciaId}';
    SivPageTitulo.definir(
      canal == null
          ? 'E-commerces / $nomeReferencia'
          : 'E-commerces / $canal / $nomeReferencia',
    );
  }

  Widget _botaoEditar(BuildContext context) {
    return PermissaoPorNome(
      idComponente: 'PRDFM003',
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(
          '/referencia',
          arguments: {'idReferencia': widget.referencia.referenciaId},
        ),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Editar referência'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceReferenciaDetalheBloc>.value(
      value: _bloc,
      child: BlocConsumer<EcommerceReferenciaDetalheBloc,
          EcommerceReferenciaDetalheState>(
        listenWhen: (previous, current) =>
            current.step == EcommerceReferenciaDetalheStep.falha ||
            (previous.processandoLote && !current.processandoLote),
        listener: (context, state) {
          // Falha primeiro, sem depender de erro != null -- senão uma falha
          // sem mensagem cai no "deu certo" (bug 1.4 do handoff).
          if (state.step == EcommerceReferenciaDetalheStep.falha) {
            SivAviso.mostrar(
              context,
              mensagem: state.erro ?? 'Falha ao atualizar.',
              tipo: SivAvisoTipo.falha,
            );
          } else if (!state.processandoLote) {
            SivAviso.mostrar(context, mensagem: 'Produtos atualizados.');
          }
        },
        builder: (context, state) {
          if (state.step == EcommerceReferenciaDetalheStep.carregando ||
              state.step == EcommerceReferenciaDetalheStep.inicial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final checklist = _montarChecklist(state.produtos);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCabecalho(context),
                const SizedBox(height: SivDimensoes.gapCards),
                _buildChecklistCard(context, state, checklist),
                const SizedBox(height: SivDimensoes.gapCards),
                if (state.processandoLote)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                _buildMatrizCard(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  _Checklist _montarChecklist(List<EcommerceReferenciaProduto> produtos) {
    final referencia = widget.referencia;
    final motivos = referencia.motivosBloqueio;

    // 1) O backend mandou os motivos exatos -- a checklist é só o espelho
    // deles, com o mapa compartilhado de textos.
    if (motivos != null && motivos.isNotEmpty) {
      return _Checklist(
        itens: motivos
            .map(
              (m) => _ItemChecklist(
                titulo: textoMotivoBloqueioEcommerce[m] ?? m,
                ok: false,
              ),
            )
            .toList(),
        bloqueiaSwitch: true,
        estimativa: false,
      );
    }

    // 2) O backend recusou mas não detalhou o motivo -- pendência genérica,
    // sem adivinhar qual.
    if (referencia.publicavel == false) {
      return const _Checklist(
        itens: [
          _ItemChecklist(
            titulo: 'Pendência de publicação',
            ok: false,
            pendenciaTexto: 'O backend recusou esta referência sem detalhar o motivo.',
          ),
        ],
        bloqueiaSwitch: true,
        estimativa: false,
      );
    }

    // 3) O backend confirmou que está tudo certo.
    if (referencia.publicavel == true) {
      return const _Checklist(itens: [], bloqueiaSwitch: false, estimativa: false);
    }

    // 4) Backend antigo, sem publicavel/motivosBloqueio -- estimativa local,
    // nunca trava o interruptor.
    final temPreco = referencia.valor != null;
    final temMidia = referencia.imagemUrl != null;
    final temGradeAtiva = produtos.any((p) => p.disponivel && p.saldo > 0);
    return _Checklist(
      itens: [
        _ItemChecklist(
          titulo: 'Preço na tabela do canal',
          ok: temPreco,
          pendenciaTexto: temPreco ? null : 'Cadastre o preço na referência',
        ),
        _ItemChecklist(
          titulo: 'Mídia cadastrada',
          ok: temMidia,
          pendenciaTexto: temMidia ? null : 'Sem imagem cadastrada',
        ),
        _ItemChecklist(
          titulo: 'Grade com item disponível',
          ok: temGradeAtiva,
          pendenciaTexto:
              temGradeAtiva ? null : 'Nenhum item da grade está disponível',
        ),
      ],
      bloqueiaSwitch: false,
      estimativa: true,
    );
  }

  Widget _buildCabecalho(BuildContext context) {
    final referencia = widget.referencia;
    final textos = context.sivTextos;
    return SivCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            child: SizedBox(
              width: 72,
              height: 72,
              child: referencia.imagemUrl != null
                  ? Image.network(
                      referencia.imagemUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImagem(context),
                    )
                  : _placeholderImagem(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referencia.referenciaNome ??
                      'Referência #${referencia.referenciaId}',
                  style: textos.secao,
                ),
                const SizedBox(height: 2),
                Text('REF ${referencia.referenciaId}', style: textos.apoio),
                const SizedBox(height: 8),
                Text(
                  referencia.valor != null
                      ? formatarMoedaEcommerce(referencia.valor!)
                      : 'Preço não cadastrado',
                  style: textos.titulo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(
    BuildContext context,
    EcommerceReferenciaDetalheState state,
    _Checklist checklist,
  ) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final pendencias = checklist.pendencias;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checklist de publicação', style: textos.rotulo),
          if (checklist.estimativa) ...[
            const SizedBox(height: 4),
            Text(
              'Verificação local — o site pode recusar.',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
          const SizedBox(height: 12),
          if (checklist.itens.isEmpty)
            Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: cores.aco),
                const SizedBox(width: 8),
                Text('Pronta para publicar', style: textos.corpo),
              ],
            ),
          for (final item in checklist.itens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    item.ok ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: item.ok ? cores.aco : cores.atencao,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.ok
                          ? item.titulo
                          : (item.pendenciaTexto == null
                              ? item.titulo
                              : '${item.titulo} — ${item.pendenciaTexto}'),
                      style: textos.corpo.copyWith(
                        color: item.ok ? null : cores.atencao,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cores.hairline)),
            ),
            child: Row(
              children: [
                Switch(
                  value: !state.rascunho,
                  onChanged: checklist.bloqueiaSwitch
                      ? null
                      : (publicar) => context
                          .read<EcommerceReferenciaDetalheBloc>()
                          .add(EcommercePublicacaoAlterou(rascunho: !publicar)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pendencias.isEmpty
                        ? 'Publicar no site'
                        : 'Publicar no site — resolva ${pendencias.length == 1 ? 'a pendência acima' : '${pendencias.length} pendências acima'}',
                    style: textos.corpo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrizCard(BuildContext context, EcommerceReferenciaDetalheState state) {
    final textos = context.sivTextos;
    final comGrade =
        state.produtos.where((p) => p.corNome != null && p.tamanhoNome != null).toList();
    final semGrade =
        state.produtos.where((p) => p.corNome == null || p.tamanhoNome == null).toList();

    final coresGrade = <String>[];
    final tamanhosGrade = <String>[];
    for (final produto in comGrade) {
      if (!coresGrade.contains(produto.corNome)) coresGrade.add(produto.corNome!);
      if (!tamanhosGrade.contains(produto.tamanhoNome)) {
        tamanhosGrade.add(produto.tamanhoNome!);
      }
    }

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grade', style: context.sivTextos.rotulo),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: state.processandoLote
                        ? null
                        : () => context
                            .read<EcommerceReferenciaDetalheBloc>()
                            .add(const EcommercePublicarDisponiveisSolicitou()),
                    child: const Text('Publicar disponíveis'),
                  ),
                  const SizedBox(width: 8),
                  // Rótulo alinhado ao evento: remove disponibilidade só dos
                  // itens sem saldo, não "despublica" a referência inteira.
                  OutlinedButton(
                    onPressed: state.processandoLote
                        ? null
                        : () => context
                            .read<EcommerceReferenciaDetalheBloc>()
                            .add(const EcommerceRemoverSemEstoqueSolicitou()),
                    child: const Text('Remover sem estoque'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (comGrade.isEmpty)
            Text('Sem grade com cor e tamanho cadastrados.', style: textos.apoio)
          else
            _buildMatriz(context, comGrade, coresGrade, tamanhosGrade),
          if (semGrade.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Sem grade', style: textos.rotulo),
            const SizedBox(height: 8),
            for (final produto in semGrade)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  produto.corNome ?? produto.tamanhoNome ?? 'Produto #${produto.produtoId}',
                  style: textos.corpo,
                ),
                subtitle: Text('Estoque: ${produto.saldo}', style: textos.apoio),
                value: produto.disponivel,
                onChanged: produto.saldo <= 0 || state.processandoLote
                    ? null
                    : (disponivel) => context
                        .read<EcommerceReferenciaDetalheBloc>()
                        .add(
                          EcommerceProdutoDisponibilidadeAlterou(
                            produtoId: produto.produtoId,
                            disponivel: disponivel,
                          ),
                        ),
              ),
          ],
        ],
      ),
    );
  }

  int _totalDisponivel(
    List<EcommerceReferenciaProduto> produtos, {
    String? corNome,
    String? tamanhoNome,
  }) {
    return produtos
        .where(
          (p) =>
              (corNome == null || p.corNome == corNome) &&
              (tamanhoNome == null || p.tamanhoNome == tamanhoNome) &&
              p.disponivel,
        )
        .length;
  }

  Widget _buildMatriz(
    BuildContext context,
    List<EcommerceReferenciaProduto> produtos,
    List<String> cores,
    List<String> tamanhos,
  ) {
    final theme = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<EcommerceReferenciaDetalheBloc>();

    Widget cabecalhoCelula(String texto, int total, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          height: _alturaLinhaMatriz,
          width: _larguraCelulaMatriz,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: theme.hairline),
              bottom: BorderSide(color: theme.hairline),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                texto.toUpperCase(),
                textAlign: TextAlign.center,
                style: textos.rotulo,
                overflow: TextOverflow.ellipsis,
              ),
              Text('$total disp.', style: textos.apoio.copyWith(fontSize: 10)),
            ],
          ),
        ),
      );
    }

    // Primeira coluna (rótulos de cor) fixa -- não rola junto com a matriz.
    final colunaFixa = Column(
      children: [
        Container(
          height: _alturaLinhaMatriz,
          width: 90,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: theme.hairline),
              bottom: BorderSide(color: theme.hairline),
            ),
          ),
        ),
        for (final cor in cores)
          Container(
            height: _alturaLinhaMatriz,
            width: 90,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: theme.hairline),
                bottom: BorderSide(color: theme.hairline),
              ),
            ),
            child: InkWell(
              onTap: () => bloc.add(
                EcommerceGradeGrupoAlterou(
                  corNome: cor,
                  disponivel: _totalDisponivel(produtos, corNome: cor) !=
                      produtos.where((p) => p.corNome == cor).length,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cor.toUpperCase(), style: textos.rotulo, overflow: TextOverflow.ellipsis),
                  Text(
                    '${_totalDisponivel(produtos, corNome: cor)} disp.',
                    style: textos.apoio.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    final tabelaRolavel = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              for (final tamanho in tamanhos)
                cabecalhoCelula(
                  tamanho,
                  _totalDisponivel(produtos, tamanhoNome: tamanho),
                  () => bloc.add(
                    EcommerceGradeGrupoAlterou(
                      tamanhoNome: tamanho,
                      disponivel: _totalDisponivel(produtos, tamanhoNome: tamanho) !=
                          produtos.where((p) => p.tamanhoNome == tamanho).length,
                    ),
                  ),
                ),
            ],
          ),
          for (final cor in cores)
            Row(
              children: [
                for (final tamanho in tamanhos)
                  _buildCelulaMatriz(context, produtos, cor, tamanho),
              ],
            ),
        ],
      ),
    );

    // Material transparente -- os InkWell dos cabeçalhos/células não têm
    // ancestral Material dentro do SivCard.
    return Material(
      type: MaterialType.transparency,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [colunaFixa, Expanded(child: tabelaRolavel)],
        ),
      ),
    );
  }

  Widget _buildCelulaMatriz(
    BuildContext context,
    List<EcommerceReferenciaProduto> produtos,
    String cor,
    String tamanho,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final encontrados =
        produtos.where((p) => p.corNome == cor && p.tamanhoNome == tamanho).toList();

    // Não existe cruzamento cor × tamanho na grade -- vazio, sem borda
    // interna, não confundir com "sem saldo" ou "indisponível".
    if (encontrados.isEmpty) {
      return const SizedBox(height: _alturaLinhaMatriz, width: _larguraCelulaMatriz);
    }

    final item = encontrados.first;
    final semSaldo = item.saldo <= 0;
    final indisponivel = !semSaldo && !item.disponivel;

    final celula = Container(
      height: _alturaLinhaMatriz,
      width: _larguraCelulaMatriz,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: semSaldo ? null : (indisponivel ? cores.superficieRecuada : cores.selecaoFundo),
        border: Border(
          right: BorderSide(color: cores.hairline),
          bottom: BorderSide(color: cores.hairline),
        ),
      ),
      child: Text(
        '${item.saldo}',
        style: textos.secao.copyWith(
          fontSize: 17,
          color: (semSaldo || indisponivel) ? cores.textoDesabilitado : null,
        ),
      ),
    );

    return InkWell(
      onTap: semSaldo
          ? null
          : () => context.read<EcommerceReferenciaDetalheBloc>().add(
                EcommerceProdutoDisponibilidadeAlterou(
                  produtoId: item.produtoId,
                  disponivel: !item.disponivel,
                ),
              ),
      // Sem saldo é hachurado e não clicável -- é o que distingue "zerado"
      // de "desligado manualmente" (ambos usavam a mesma cor antes).
      child: semSaldo
          ? CustomPaint(painter: _HachuraPainter(cores.hairline), child: celula)
          : celula,
    );
  }

  Widget _placeholderImagem(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      color: cores.superficieRecuada,
      child: Icon(Icons.image_not_supported_outlined, color: cores.textoApoio),
    );
  }
}

/// Padrão diagonal simples pra marcar "sem saldo" na matriz, sem depender
/// de asset nem de pacote novo.
class _HachuraPainter extends CustomPainter {
  final Color cor;

  const _HachuraPainter(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..strokeWidth = 1;
    const passo = 8.0;
    for (var x = -size.height; x < size.width; x += passo) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HachuraPainter oldDelegate) => oldDelegate.cor != cor;
}
