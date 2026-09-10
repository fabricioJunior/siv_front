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
      _controladores.putIfAbsent(chave, EcommerceConfiguracaoFormularioController.new);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommercesBloc>.value(
      value: _bloc,
      child: BlocBuilder<EcommercesBloc, EcommercesState>(
        builder: (context, state) {
          _atualizarAcoes(context, state);
          final mobile =
              MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: mobile ? _buildConteudoMobile(context, state) : _buildConteudoDesktop(context, state),
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
    final selecionados =
        _criandoNovo ? const <Ecommerce>[] : state.ecommerces.where((e) => e.id == _selecionadoId).toList();
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
          icon: Icon(Icons.delete_outline, size: 18, color: context.sivColors.vinho),
          label: Text('Excluir canal', style: TextStyle(color: context.sivColors.vinho)),
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
                  ? () => _bloc.add(EcommercesRestaurarSolicitado(id: ecommerce.id!))
                  : null,
              onVerProdutos: ecommerce.id == null
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        '/ecommerce_referencias',
                        arguments: {'ecommerceId': ecommerce.id, 'titulo': ecommerce.titulo},
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
      onSalvou: () => _bloc.add(const EcommercesCarregarSolicitado()),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, Ecommerce ecommerce) async {
    await SivDialogo.mostrar(
      context,
      titulo: 'Excluir e-commerce',
      variante: SivDialogoVariante.destrutivo,
      corpo: const Text(
        'Excluir este e-commerce? Sites integrados a ele vão parar de '
        'funcionar corretamente. Essa ação pode ser desfeita depois.',
      ),
      textoAcao: 'Excluir',
      onConfirmar: (_) => _bloc.add(EcommercesExcluirSolicitado(id: ecommerce.id!)),
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

    return Opacity(
      opacity: ecommerce.apagado ? 0.55 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selecionado ? cores.selecaoFundo : cores.superficie,
            border: Border.all(color: selecionado ? cores.aco : cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: ecommerce.icone != null
                          ? Image.network(
                              ecommerce.icone!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _iniciais(cores, textos),
                            )
                          : _iniciais(cores, textos),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ecommerce.titulo, style: textos.secao),
                        if (ecommerce.subtitulo != null)
                          Text(ecommerce.subtitulo!, style: textos.apoio),
                        // TODO: contador de referências bloqueadas por canal não
                        // disponível em Ecommerce/EcommercesState hoje.
                        if (ecommerce.referenciasPublicadas != null ||
                            ecommerce.referenciasRascunho != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              [
                                if (ecommerce.referenciasPublicadas != null)
                                  '${ecommerce.referenciasPublicadas} publicadas',
                                if (ecommerce.referenciasRascunho != null)
                                  '${ecommerce.referenciasRascunho} rascunho',
                              ].join(' · '),
                              style: textos.apoio,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (ecommerce.apagado)
                    TextButton(onPressed: onRestaurar, child: const Text('Restaurar')),
                ],
              ),
              if (onVerProdutos != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onVerProdutos,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('Ver produtos no site'),
                  ),
                ),
              ],
            ],
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
