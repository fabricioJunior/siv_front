import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencia_detalhe_bloc/ecommerce_referencia_detalhe_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _formatarMoeda(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

/// Item da checklist de publicação: código de motivo (quando o backend
/// mandar `motivosBloqueio`) + texto + atalho.
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

class EcommerceReferenciaDetalhePage extends StatelessWidget {
  final int ecommerceId;
  final EcommerceReferencia referencia;

  const EcommerceReferenciaDetalhePage({
    super.key,
    required this.ecommerceId,
    required this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return BlocProvider<EcommerceReferenciaDetalheBloc>(
      create: (context) => sl<EcommerceReferenciaDetalheBloc>()
        ..add(
          EcommerceReferenciaDetalheIniciou(
            ecommerceId: ecommerceId,
            referenciaEcommerceId: referencia.id!,
            referenciaId: referencia.referenciaId,
            rascunho: referencia.rascunho,
          ),
        ),
      child: Scaffold(
        backgroundColor: cores.papel,
        appBar: AppBar(
          title: Text(
            referencia.referenciaNome ??
                'Referência #${referencia.referenciaId}',
          ),
        ),
        body: BlocConsumer<EcommerceReferenciaDetalheBloc,
            EcommerceReferenciaDetalheState>(
          listenWhen: (previous, current) =>
              current.step == EcommerceReferenciaDetalheStep.falha ||
              (previous.processandoLote && !current.processandoLote),
          listener: (context, state) {
            if (state.step == EcommerceReferenciaDetalheStep.falha &&
                state.erro != null) {
              SivAviso.mostrar(
                context,
                mensagem: state.erro!,
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
            final pendencias = checklist.where((item) => !item.ok).toList();

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
                  _buildChecklistCard(context, state, checklist, pendencias),
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
      ),
    );
  }

  List<_ItemChecklist> _montarChecklist(List<EcommerceReferenciaProduto> produtos) {
    final temPreco = referencia.valor != null;
    final temMidia = referencia.imagemUrl != null;
    final temGradeAtiva = produtos.any((p) => p.disponivel && p.saldo > 0);
    return [
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
    ];
  }

  Widget _buildCabecalho(BuildContext context) {
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
                      ? _formatarMoeda(referencia.valor!)
                      : 'Preço não cadastrado',
                  style: textos.titulo,
                ),
              ],
            ),
          ),
          PermissaoPorNome(
            idComponente: 'PRDFM003',
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                '/referencia',
                arguments: {'idReferencia': referencia.referenciaId},
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar referência'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(
    BuildContext context,
    EcommerceReferenciaDetalheState state,
    List<_ItemChecklist> checklist,
    List<_ItemChecklist> pendencias,
  ) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checklist de publicação', style: textos.rotulo),
          const SizedBox(height: 12),
          for (final item in checklist)
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
                      item.ok ? item.titulo : '${item.titulo} — ${item.pendenciaTexto}',
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
                  onChanged: pendencias.isEmpty
                      ? (publicar) => context
                          .read<EcommerceReferenciaDetalheBloc>()
                          .add(EcommercePublicacaoAlterou(rascunho: !publicar))
                      : null,
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
                  OutlinedButton(
                    onPressed: state.processandoLote
                        ? null
                        : () => context
                            .read<EcommerceReferenciaDetalheBloc>()
                            .add(const EcommerceRemoverSemEstoqueSolicitou()),
                    child: const Text('Despublicar todos'),
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
                title: Text('Produto #${produto.produtoId}', style: textos.corpo),
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

  Widget _buildMatriz(
    BuildContext context,
    List<EcommerceReferenciaProduto> produtos,
    List<String> cores,
    List<String> tamanhos,
  ) {
    final theme = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<EcommerceReferenciaDetalheBloc>();

    Widget cabecalhoCelula(String texto, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            texto.toUpperCase(),
            textAlign: TextAlign.center,
            style: textos.rotulo,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(76),
        border: TableBorder.all(color: theme.hairline),
        children: [
          TableRow(
            children: [
              const SizedBox(),
              for (final tamanho in tamanhos)
                cabecalhoCelula(
                  tamanho,
                  () => bloc.add(
                    EcommerceGradeGrupoAlterou(
                      tamanhoNome: tamanho,
                      disponivel: !_maioriaDisponivel(produtos, tamanhoNome: tamanho),
                    ),
                  ),
                ),
            ],
          ),
          for (final cor in cores)
            TableRow(
              children: [
                cabecalhoCelula(
                  cor,
                  () => bloc.add(
                    EcommerceGradeGrupoAlterou(
                      corNome: cor,
                      disponivel: !_maioriaDisponivel(produtos, corNome: cor),
                    ),
                  ),
                ),
                for (final tamanho in tamanhos)
                  _buildCelulaMatriz(context, produtos, cor, tamanho),
              ],
            ),
        ],
      ),
    );
  }

  bool _maioriaDisponivel(
    List<EcommerceReferenciaProduto> produtos, {
    String? corNome,
    String? tamanhoNome,
  }) {
    final grupo = produtos.where(
      (p) =>
          (corNome == null || p.corNome == corNome) &&
          (tamanhoNome == null || p.tamanhoNome == tamanhoNome),
    );
    if (grupo.isEmpty) return false;
    return grupo.where((p) => p.disponivel).length >= grupo.length / 2;
  }

  Widget _buildCelulaMatriz(
    BuildContext context,
    List<EcommerceReferenciaProduto> produtos,
    String cor,
    String tamanho,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final produto = produtos.where((p) => p.corNome == cor && p.tamanhoNome == tamanho);
    if (produto.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
        color: cores.superficieRecuada,
      );
    }
    final item = produto.first;
    final semSaldo = item.saldo <= 0;

    return InkWell(
      onTap: semSaldo
          ? null
          : () => context.read<EcommerceReferenciaDetalheBloc>().add(
                EcommerceProdutoDisponibilidadeAlterou(
                  produtoId: item.produtoId,
                  disponivel: !item.disponivel,
                ),
              ),
      child: Container(
        constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
        alignment: Alignment.center,
        color: semSaldo
            ? cores.superficieRecuada
            : item.disponivel
                ? cores.selecaoFundo
                : cores.superficieRecuada,
        child: Text(
          '${item.saldo}',
          style: textos.corpo.copyWith(
            color: semSaldo ? cores.textoDesabilitado : null,
          ),
        ),
      ),
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
