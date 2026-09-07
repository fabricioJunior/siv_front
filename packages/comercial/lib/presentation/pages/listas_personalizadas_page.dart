import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class ListasPersonalizadasPage extends StatefulWidget {
  const ListasPersonalizadasPage({super.key});

  @override
  State<ListasPersonalizadasPage> createState() => _ListasPersonalizadasPageState();
}

class _ListasPersonalizadasPageState extends State<ListasPersonalizadasPage> {
  late final ListasPersonalizadasBloc _bloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<ListasPersonalizadasBloc>()..add(ListasPersonalizadasIniciou());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(ListasPersonalizadasCarregarMaisSolicitado());
      }
    });
    SivPageTitulo.definir('Minhas listas');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    SivPageTitulo.limpar();
    super.dispose();
  }

  Future<void> _abrirNovaLista() async {
    await Navigator.pushNamed(context, '/lista_personalizada');
    if (mounted) _bloc.add(ListasPersonalizadasIniciou());
  }

  Future<void> _abrirLista(int id) async {
    await Navigator.pushNamed(context, '/lista_personalizada', arguments: {'id': id});
    if (mounted) _bloc.add(ListasPersonalizadasIniciou());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListasPersonalizadasBloc>.value(
      value: _bloc,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _abrirNovaLista,
          icon: const Icon(Icons.add),
          label: const Text('Nova lista'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SivDimensoes.paginaHorizontal,
            vertical: SivDimensoes.paginaVertical,
          ),
          child: BlocBuilder<ListasPersonalizadasBloc, ListasPersonalizadasState>(
            builder: (context, state) => _buildConteudo(context, state),
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, ListasPersonalizadasState state) {
    final textos = context.sivTextos;

    if (state.step == ListasPersonalizadasStep.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.step == ListasPersonalizadasStep.falha && state.itens.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.erro ?? 'Falha ao carregar as listas.', style: textos.corpo),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              onPressed: () => _bloc.add(ListasPersonalizadasIniciou()),
            ),
          ],
        ),
      );
    }
    if (state.itens.isEmpty) {
      return Center(
        child: Text('Nenhuma lista personalizada criada ainda.', style: textos.apoio),
      );
    }

    final exibirLoaderFinal = state.step == ListasPersonalizadasStep.carregandoMais;

    return ListView.separated(
      controller: _scrollController,
      itemCount: state.itens.length + (exibirLoaderFinal ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= state.itens.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2.5)),
          );
        }
        final lista = state.itens[index];
        return ListTile(
          title: Text(lista.titulo?.isNotEmpty == true ? lista.titulo! : lista.hash),
          subtitle: Text(
            '${lista.quantidadeItens} produto(s) · criada em ${_formatarData(lista.criadoEm)}',
          ),
          trailing: SivEtiqueta(
            situacao: _etiquetaSituacao(lista.situacao),
            texto: _labelSituacao(lista.situacao),
          ),
          onTap: () => _abrirLista(lista.id),
        );
      },
    );
  }

  SivEtiquetaSituacao _etiquetaSituacao(ListaPersonalizadaSituacao situacao) =>
      switch (situacao) {
        ListaPersonalizadaSituacao.ativa => SivEtiquetaSituacao.emAndamento,
        ListaPersonalizadaSituacao.cancelada => SivEtiquetaSituacao.cancelado,
        ListaPersonalizadaSituacao.expirada => SivEtiquetaSituacao.cancelado,
      };

  String _labelSituacao(ListaPersonalizadaSituacao situacao) => switch (situacao) {
        ListaPersonalizadaSituacao.ativa => 'Ativa',
        ListaPersonalizadaSituacao.cancelada => 'Cancelada',
        ListaPersonalizadaSituacao.expirada => 'Expirada',
      };

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}
