import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pages/ecommerce_configuracao_formulario.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class EcommercesPage extends StatefulWidget {
  final int? ecommerceIdInicial;

  const EcommercesPage({super.key, this.ecommerceIdInicial});

  @override
  State<EcommercesPage> createState() => _EcommercesPageState();
}

class _EcommercesPageState extends State<EcommercesPage> {
  late final EcommercesBloc _bloc;
  int? _selecionadoId;
  bool _criandoNovo = false;
  final _controladores = <Object, EcommerceConfiguracaoFormularioController>{};

  @override
  void initState() {
    super.initState();
    _selecionadoId = widget.ecommerceIdInicial;
    _bloc = sl<EcommercesBloc>()..add(const EcommercesCarregarSolicitado());
    SivPageTitulo.definir('E-commerces');
  }

  @override
  void dispose() {
    _bloc.close();
    SivPageTitulo.limpar();
    SivPageAcoes.limpar();
    super.dispose();
  }

  EcommerceConfiguracaoFormularioController _controladorPara(Object chave) =>
      _controladores.putIfAbsent(
          chave, EcommerceConfiguracaoFormularioController.new);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommercesBloc>.value(
      value: _bloc,
      child: BlocBuilder<EcommercesBloc, EcommercesState>(
        builder: (context, state) {
          _atualizarAcoes(context, state);
          final mobile = MediaQuery.sizeOf(context).width <
              SivDimensoes.breakpointMenuDrawer;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: mobile
                ? _buildConteudoMobile(context, state)
                : _buildConteudoDesktop(context, state),
          );
        },
      ),
    );
  }

  Widget _buildConteudoDesktop(BuildContext context, EcommercesState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 340, child: _buildLista(context, state)),
        const SizedBox(width: SivDimensoes.gapCards),
        Expanded(child: _buildPainel(context, state)),
      ],
    );
  }

  Widget _buildConteudoMobile(BuildContext context, EcommercesState state) {
    if (!_criandoNovo && _selecionadoId == null) {
      return _buildLista(context, state);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: () => setState(() {
            _criandoNovo = false;
            _selecionadoId = null;
          }),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Voltar para os canais'),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildPainel(context, state)),
      ],
    );
  }

  void _atualizarAcoes(BuildContext context, EcommercesState state) {
    final selecionados = _criandoNovo
        ? const <Ecommerce>[]
        : state.ecommerces.where((e) => e.id == _selecionadoId).toList();
    final selecionado = selecionados.isEmpty ? null : selecionados.first;
    final chave = _criandoNovo ? 'novo' : (selecionado?.id ?? 'novo');

    SivPageAcoes.definir([
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: state.incluirApagados,
            onChanged: (value) => _bloc.add(
              EcommercesCarregarSolicitado(incluirApagados: value ?? false),
            ),
          ),
          Text('Mostrar excluídos', style: context.sivTextos.corpo),
        ],
      ),
      const SizedBox(width: 12),
      if (selecionado != null && !selecionado.apagado)
        OutlinedButton.icon(
          onPressed: () => _confirmarExclusao(context, selecionado),
          icon: Icon(Icons.delete_outline,
              size: 18, color: context.sivColors.vinho),
          label: Text('Excluir canal',
              style: TextStyle(color: context.sivColors.vinho)),
        ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () => setState(() {
          _criandoNovo = true;
          _selecionadoId = null;
        }),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Novo e-commerce'),
      ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: (_criandoNovo || selecionado != null)
            ? () => _controladorPara(chave).salvar()
            : null,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Salvar configuração'),
      ),
    ]);
  }

  Widget _buildLista(BuildContext context, EcommercesState state) {
    if (state.status == EcommercesStatus.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return ListView(
      children: [
        for (final ecommerce in state.ecommerces)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CardCanal(
              ecommerce: ecommerce,
              selecionado: !_criandoNovo && ecommerce.id == _selecionadoId,
              onTap: ecommerce.apagado
                  ? null
                  : () => setState(() {
                        _criandoNovo = false;
                        _selecionadoId = ecommerce.id;
                      }),
              onRestaurar: ecommerce.apagado
                  ? () => _bloc
                      .add(EcommercesRestaurarSolicitado(id: ecommerce.id!))
                  : null,
              onVerProdutos: ecommerce.id == null
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        '/ecommerce_referencias',
                        arguments: {
                          'ecommerceId': ecommerce.id,
                          'titulo': ecommerce.titulo
                        },
                      ),
            ),
          ),
      ],
    );
  }

  Widget _buildPainel(BuildContext context, EcommercesState state) {
    if (_criandoNovo) {
      return EcommerceConfiguracaoFormulario(
        key: const ValueKey('novo'),
        controller: _controladorPara('novo'),
        onSalvou: () {
          setState(() => _criandoNovo = false);
          _bloc.add(const EcommercesCarregarSolicitado());
        },
      );
    }

    final selecionado = state.ecommerces.where((e) => e.id == _selecionadoId);
    if (selecionado.isEmpty) {
      return Center(
        child: Text(
          'Selecione um canal à esquerda ou cadastre um novo.',
          style: context.sivTextos.corpo,
        ),
      );
    }

    final ecommerce = selecionado.first;
    return EcommerceConfiguracaoFormulario(
      key: ValueKey(ecommerce.id),
      controller: _controladorPara(ecommerce.id ?? 'novo'),
      ecommerceId: ecommerce.id,
      empresaId: ecommerce.empresaId,
      referenciasPublicadas: ecommerce.referenciasPublicadas,
      onSalvou: () => _bloc.add(const EcommercesCarregarSolicitado()),
    );
  }

  Future<void> _confirmarExclusao(
      BuildContext context, Ecommerce ecommerce) async {
    await SivDialogo.mostrar(
      context,
      titulo: 'Excluir e-commerce',
      variante: SivDialogoVariante.destrutivo,
      corpo: const Text(
        'Excluir este e-commerce? Sites integrados a ele vão parar de '
        'funcionar corretamente. Essa ação pode ser desfeita depois.',
      ),
      textoAcao: 'Excluir',
      onConfirmar: (_) =>
          _bloc.add(EcommercesExcluirSolicitado(id: ecommerce.id!)),
    );
  }
}

class _CardCanal extends StatelessWidget {
  final Ecommerce ecommerce;
  final bool selecionado;
  final VoidCallback? onTap;
  final VoidCallback? onRestaurar;
  final VoidCallback? onVerProdutos;

  const _CardCanal({
    required this.ecommerce,
    required this.selecionado,
    required this.onTap,
    required this.onRestaurar,
    this.onVerProdutos,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    // Sem token de "acento de canto" no tema; aproxima com aco em opacidade
    // reduzida (mesma cor já usada pra bordas de destaque no design system).
    final corCanto = cores.aco.withValues(alpha: 0.4);

    return Opacity(
      opacity: ecommerce.apagado ? 0.55 : 1,
      // InkWell precisa de um Material ancestor pra pintar o ripple --
      // widgets prontos do Material (Button, Checkbox etc) já carregam o
      // deles embutido, mas InkWell cru não. Mesmo bug já corrigido em
      // ecommerce_referencias_page.dart (_segmentoSituacao).
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selecionado ? cores.selecaoFundo : cores.superficie,
                  border: Border.all(
                      color: selecionado ? cores.aco : cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(SivDimensoes.raio),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: ecommerce.icone != null
                                ? Image.network(
                                    ecommerce.icone!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _iniciais(cores, textos),
                                  )
                                : _iniciais(cores, textos),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  ecommerce.titulo,
                                  style: textos.secao.copyWith(fontSize: 17),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _tagStatus(cores, textos),
                            ],
                          ),
                        ),
                        if (ecommerce.apagado)
                          TextButton(
                              onPressed: onRestaurar,
                              child: const Text('Restaurar')),
                      ],
                    ),
                    if (ecommerce.subtitulo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          ecommerce.subtitulo!,
                          style: textos.apoio.copyWith(fontSize: 11.5),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          _metrica(cores, textos, 'Publicadas',
                              ecommerce.referenciasPublicadas),
                          const SizedBox(width: 16),
                          _metrica(cores, textos, 'Rascunho',
                              ecommerce.referenciasRascunho),
                          const SizedBox(width: 16),
                          // TODO: contador de referências bloqueadas por canal não
                          // disponível em Ecommerce/EcommercesState hoje.
                          _metrica(cores, textos, 'Bloqueadas', null,
                              corValor: cores.vinho),
                        ],
                      ),
                    ),
                    if (onVerProdutos != null) ...[
                      const SizedBox(height: 11),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onVerProdutos,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: textos.apoio.copyWith(
                              fontSize: 13.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                          child: const Text('VER PRODUTOS NO SITE'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _cantoBlueprint(corCanto, top: true, left: true),
              _cantoBlueprint(corCanto, top: true, left: false),
              _cantoBlueprint(corCanto, top: false, left: true),
              _cantoBlueprint(corCanto, top: false, left: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagStatus(SivColors cores, SivTextStyles textos) {
    final cor = ecommerce.apagado ? cores.vinho : cores.acoProfundo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: cor),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        ecommerce.apagado ? 'APAGADO' : 'ATIVO',
        style: textos.rotulo.copyWith(fontSize: 10.5, color: cor),
      ),
    );
  }

  Widget _metrica(
    SivColors cores,
    SivTextStyles textos,
    String rotulo,
    int? valor, {
    Color? corValor,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: '$rotulo ', style: textos.apoio.copyWith(fontSize: 12.5)),
          TextSpan(
            text: valor?.toString() ?? '—',
            style: textos.secao.copyWith(fontSize: 16, color: corValor),
          ),
        ],
      ),
    );
  }

  Widget _cantoBlueprint(Color cor, {required bool top, required bool left}) {
    const tamanho = 8.0;
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: cor) : BorderSide.none,
            bottom: !top ? BorderSide(color: cor) : BorderSide.none,
            left: left ? BorderSide(color: cor) : BorderSide.none,
            right: !left ? BorderSide(color: cor) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _iniciais(SivColors cores, SivTextStyles textos) {
    return Container(
      color: cores.acoEscuro,
      alignment: Alignment.center,
      child: Text(
        ecommerce.titulo.isNotEmpty ? ecommerce.titulo[0].toUpperCase() : '?',
        style: textos.corpo.copyWith(color: cores.textoSobreEscuroTitulo),
      ),
    );
  }
}
