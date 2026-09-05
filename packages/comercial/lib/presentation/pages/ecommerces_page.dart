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

  @override
  void initState() {
    super.initState();
    _selecionadoId = widget.ecommerceIdInicial;
    _bloc = sl<EcommercesBloc>()..add(const EcommercesCarregarSolicitado());
    SivPageTitulo.definir('E-commerces');
    SivPageAcoes.definir([
      OutlinedButton.icon(
        onPressed: () => setState(() {
          _criandoNovo = true;
          _selecionadoId = null;
        }),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Novo e-commerce'),
      ),
    ]);
  }

  @override
  void dispose() {
    _bloc.close();
    SivPageTitulo.limpar();
    SivPageAcoes.limpar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return BlocProvider<EcommercesBloc>.value(
      value: _bloc,
      child: BlocBuilder<EcommercesBloc, EcommercesState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 340,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Mostrar excluídos', style: context.sivTextos.corpo),
                        value: state.incluirApagados,
                        onChanged: (value) => _bloc.add(
                          EcommercesCarregarSolicitado(incluirApagados: value ?? false),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: _buildLista(context, state)),
                    ],
                  ),
                ),
                const SizedBox(width: SivDimensoes.gapCards),
                Expanded(child: _buildPainel(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLista(BuildContext context, EcommercesState state) {
    if (state.status == EcommercesStatus.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final textos = context.sivTextos;
    final cores = context.sivColors;

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
            ),
          ),
        InkWell(
          onTap: () => setState(() {
            _criandoNovo = true;
            _selecionadoId = null;
          }),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: cores.hairline),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: cores.textoApoio),
                const SizedBox(width: 8),
                Text('Cadastrar e-commerce', style: textos.corpo),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!ecommerce.apagado)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmarExclusao(context, ecommerce),
              icon: Icon(Icons.delete_outline, size: 18, color: context.sivColors.vinho),
              label: Text(
                'Excluir canal',
                style: TextStyle(color: context.sivColors.vinho),
              ),
            ),
          ),
        Expanded(
          child: EcommerceConfiguracaoFormulario(
            key: ValueKey(ecommerce.id),
            ecommerceId: ecommerce.id,
            empresaId: ecommerce.empresaId,
            onSalvou: () => _bloc.add(const EcommercesCarregarSolicitado()),
          ),
        ),
      ],
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

  const _CardCanal({
    required this.ecommerce,
    required this.selecionado,
    required this.onTap,
    required this.onRestaurar,
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
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cores.acoEscuro,
                child: Text(
                  ecommerce.titulo.isNotEmpty ? ecommerce.titulo[0].toUpperCase() : '?',
                  style: TextStyle(color: cores.textoSobreEscuroTitulo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ecommerce.titulo, style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                    if (ecommerce.subtitulo != null)
                      Text(ecommerce.subtitulo!, style: textos.apoio),
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
                TextButton(onPressed: onRestaurar, child: const Text('Restaurar'))
              else if (selecionado)
                Icon(Icons.check_circle, color: cores.aco, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
