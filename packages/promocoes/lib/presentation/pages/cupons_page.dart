import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';

class CuponsPage extends StatelessWidget {
  final bloc = sl<CuponsBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  CuponsPage({super.key});

  Future<void> _abrirNovo(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed('/cupom/form');
    if (result == true && context.mounted) {
      context.read<CuponsBloc>().add(CuponsIniciou());
    }
  }

  Future<void> _abrirEdicao(BuildContext context, Cupom item) async {
    final result = await Navigator.of(context).pushNamed(
      '/cupom/form',
      arguments: {'idCupom': item.id},
    );
    if (result == true && context.mounted) {
      context.read<CuponsBloc>().add(CuponsIniciou());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CuponsBloc>(
      create: (context) => bloc..add(CuponsIniciou()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por código',
                      prefixIcon: Icon(Icons.search_outlined),
                    ),
                    onChanged: (value) => debouncer.run(
                      () => bloc.add(CuponsIniciou(busca: value)),
                    ),
                    onSubmitted: (value) =>
                        bloc.add(CuponsIniciou(busca: value)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              BlocBuilder<CuponsBloc, CuponsState>(
                builder: (context, state) {
                  final carregando = state is CuponsCarregarEmProgresso;
                  return FilledButton.icon(
                    onPressed: carregando ? null : () => _abrirNovo(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Novo cupom'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: SivDimensoes.gapCards),
          Expanded(
            child: BlocBuilder<CuponsBloc, CuponsState>(
              builder: (context, state) {
                if (state is CuponsCarregarEmProgresso) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state is CuponsCarregarFalha) {
                  return Center(
                    child: Text(
                      'Falha ao carregar cupons.',
                      style: context.sivTextos.corpo
                          .copyWith(color: context.sivColors.vinho),
                    ),
                  );
                }

                final itens = state.cupons;
                if (itens.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum cupom cadastrado.',
                      style: context.sivTextos.corpo,
                    ),
                  );
                }

                final mobile = MediaQuery.sizeOf(context).width <
                    SivDimensoes.breakpointMenuDrawer;

                if (mobile) {
                  return ListView.separated(
                    itemCount: itens.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 9),
                    itemBuilder: (context, index) => _CupomCardMobile(
                      item: itens[index],
                      onTap: () => _abrirEdicao(context, itens[index]),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: SivTabela(
                    colunas: const [
                      SivTabelaColuna(titulo: 'CÓDIGO', flex: 3),
                      SivTabelaColuna(titulo: 'DESCONTO', flex: 2),
                      SivTabelaColuna(titulo: 'VIGÊNCIA', flex: 2),
                      SivTabelaColuna(titulo: 'SITUAÇÃO', flex: 1),
                    ],
                    quantidadeLinhas: itens.length,
                    onLinhaTap: (indice) => _abrirEdicao(context, itens[indice]),
                    linhaBuilder: (context, indice) =>
                        _linhaTabela(context, itens[indice]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _linhaTabela(BuildContext context, Cupom item) {
    final textos = context.sivTextos;
    return [
      Text(
        item.codigo,
        style: textos.codigo.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      Text(_descricaoDesconto(item), style: textos.corpo.copyWith(fontSize: 13.5)),
      Text(_vigencia(item), style: textos.corpo.copyWith(fontSize: 13)),
      Align(alignment: Alignment.centerRight, child: _tagSituacao(context, item)),
    ];
  }

  static String _descricaoDesconto(Cupom item) {
    switch (item.tipoDesconto) {
      case TipoDesconto.percentual:
        return '${item.valorPercentual ?? 0}% de desconto';
      case TipoDesconto.valorFixo:
        return 'R\$ ${item.valorFixo ?? 0} de desconto';
      case TipoDesconto.precoFixo:
        return 'Preço fixo de R\$ ${item.precoFixo ?? 0}';
    }
  }

  // ponytail: sem campo de "vigência contínua" no domínio -- exibe sempre o
  // intervalo real de dataInicio/dataFim (mock mostrava "contínua"/"encerrado"
  // como texto, mas isso não existe como dado hoje).
  static String _vigencia(Cupom item) =>
      '${_formatarData(item.dataInicio)} – ${_formatarData(item.dataFim)}';

  static String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';

  static Widget _tagSituacao(BuildContext context, Cupom item) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final cor = item.ativa ? cores.acoProfundo : cores.textoApoio;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: item.ativa ? cores.selecaoFundo : cores.superficieRecuada,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        item.ativa ? 'Ativo' : 'Inativo',
        style: textos.apoio.copyWith(color: cor, fontSize: 11),
      ),
    );
  }
}

class _CupomCardMobile extends StatelessWidget {
  final Cupom item;
  final VoidCallback onTap;

  const _CupomCardMobile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Opacity(
      opacity: item.ativa ? 1 : 0.55,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  border: Border.all(color: cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.codigo,
                            style: textos.codigo.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        CuponsPage._tagSituacao(context, item),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${CuponsPage._descricaoDesconto(item)} · ${CuponsPage._vigencia(item)}',
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                  ],
                ),
              ),
              ...sivCantosBlueprint(cores.hairline),
            ],
          ),
        ),
      ),
    );
  }
}
