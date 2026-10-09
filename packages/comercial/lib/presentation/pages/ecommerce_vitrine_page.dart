import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vitrine do site: "Menu do site" (listas e grupos) e "Home do site" (só
/// listas), cada uma com ordem por índice.
class EcommerceVitrinePage extends StatefulWidget {
  final int ecommerceId;

  const EcommerceVitrinePage({super.key, required this.ecommerceId});

  @override
  State<EcommerceVitrinePage> createState() => _EcommerceVitrinePageState();
}

class _EcommerceVitrinePageState extends State<EcommerceVitrinePage> {
  late final EcommerceVitrineBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<EcommerceVitrineBloc>()
      ..add(EcommerceVitrineIniciou(ecommerceId: widget.ecommerceId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceVitrineBloc>.value(
      value: _bloc,
      child: BlocConsumer<EcommerceVitrineBloc, EcommerceVitrineState>(
        listener: (context, state) {
          if (state.ultimoSalvo != null) {
            SivAviso.mostrar(
              context,
              mensagem: state.ultimoSalvo == VitrineLocal.menu
                  ? 'Menu do site salvo.'
                  : 'Home do site salva.',
            );
          } else if (state.erro?.isNotEmpty == true &&
              state.step != EcommerceVitrineStep.falha) {
            SivAviso.mostrar(context, mensagem: state.erro!, tipo: SivAvisoTipo.falha);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SivTituloPagina(titulo: 'Vitrine do site'),
                Expanded(child: _corpo(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(BuildContext context, EcommerceVitrineState state) {
    if (state.step == EcommerceVitrineStep.carregando ||
        state.step == EcommerceVitrineStep.inicial) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.step == EcommerceVitrineStep.falha) {
      return Center(
        child: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: Text(state.erro ?? 'Falha ao carregar.'),
          onPressed: () =>
              _bloc.add(EcommerceVitrineIniciou(ecommerceId: widget.ecommerceId)),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: ListView(
        children: [
          VitrineSecao(
            key: const Key('vitrine-menu'),
            local: VitrineLocal.menu,
            titulo: 'Menu do site',
            apoio: 'Listas e grupos que aparecem no menu lateral.',
            state: state,
          ),
          const SizedBox(height: SivDimensoes.gapCards),
          VitrineSecao(
            key: const Key('vitrine-home'),
            local: VitrineLocal.home,
            titulo: 'Home do site',
            apoio: 'Listas em destaque na home (só listas, não grupos).',
            state: state,
          ),
        ],
      ),
    );
  }
}

class VitrineSecao extends StatelessWidget {
  final VitrineLocal local;
  final String titulo;
  final String apoio;
  final EcommerceVitrineState state;

  const VitrineSecao({
    super.key,
    required this.local,
    required this.titulo,
    required this.apoio,
    required this.state,
  });

  Future<void> _adicionar(BuildContext context) async {
    final bloc = context.read<EcommerceVitrineBloc>();
    final atuais = state.vitrine.doLocal(local);
    bool jaTem(VitrineItemTipo t, int id) =>
        atuais.any((i) => i.tipo == t && i.itemId == id);
    final listas = state.listas.where((l) => !jaTem(VitrineItemTipo.lista, l.id));
    final grupos = local == VitrineLocal.menu
        ? state.grupos.where((g) => !jaTem(VitrineItemTipo.grupo, g.id))
        : const <ListaGrupo>[];

    final escolhido = await showModalBottomSheet<(VitrineItemTipo, int)>(
      context: context,
      builder: (ctx) => ListView(
        children: [
          if (listas.isEmpty && grupos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nada disponível para adicionar.'),
            ),
          for (final l in listas)
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: Text(l.titulo?.isNotEmpty == true ? l.titulo! : l.hash),
              subtitle: const Text('Lista'),
              onTap: () => Navigator.pop(ctx, (VitrineItemTipo.lista, l.id)),
            ),
          for (final g in grupos)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(g.nome),
              subtitle: const Text('Grupo'),
              onTap: () => Navigator.pop(ctx, (VitrineItemTipo.grupo, g.id)),
            ),
        ],
      ),
    );
    if (escolhido != null) {
      bloc.add(
        EcommerceVitrineItemAdicionou(
          local: local,
          tipo: escolhido.$1,
          itemId: escolhido.$2,
        ),
      );
    }
  }

  Future<void> _definirIndice(
    BuildContext context,
    EcommerceVitrineItem item,
    int total,
  ) async {
    final bloc = context.read<EcommerceVitrineBloc>();
    final controller = TextEditingController(text: '${item.ordem + 1}');
    await SivDialogo.mostrar(
      context,
      titulo: 'Posição de "${item.nome}"',
      corpo: TextField(
        key: const Key('vitrine-indice'),
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: 'Posição (1 a $total)'),
      ),
      textoAcao: 'Mover',
      onConfirmar: (_) {
        final n = int.tryParse(controller.text.trim());
        if (n == null) return;
        bloc.add(
          EcommerceVitrineItemMoveu(
            local: local,
            tipo: item.tipo,
            itemId: item.itemId,
            indice: n - 1,
          ),
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final bloc = context.read<EcommerceVitrineBloc>();
    final itens = state.vitrine.doLocal(local);
    final salvando = state.salvando == local;

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(titulo, style: textos.rotulo)),
              TextButton.icon(
                key: Key('vitrine-adicionar-${local.name}'),
                style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => _adicionar(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          Text(apoio, style: textos.apoio),
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Nada configurado ainda.', style: textos.apoio),
            ),
          for (final item in itens)
            ListTile(
              key: ValueKey('${local.name}-${item.tipo.name}-${item.itemId}'),
              contentPadding: EdgeInsets.zero,
              leading: InkWell(
                onTap: () => _definirIndice(context, item, itens.length),
                child: CircleAvatar(
                  child: Text('${item.ordem + 1}', key: const Key('vitrine-posicao')),
                ),
              ),
              title: Text(item.nome),
              subtitle: Text(
                [
                  item.tipo == VitrineItemTipo.grupo ? 'Grupo' : 'Lista',
                  if (item.situacao != null && item.situacao != 'ativa') item.situacao!,
                ].join(' · '),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Subir',
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    onPressed: item.ordem == 0
                        ? null
                        : () => bloc.add(
                              EcommerceVitrineItemMoveu(
                                local: local,
                                tipo: item.tipo,
                                itemId: item.itemId,
                                indice: item.ordem - 1,
                              ),
                            ),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  IconButton(
                    tooltip: 'Descer',
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    onPressed: item.ordem == itens.length - 1
                        ? null
                        : () => bloc.add(
                              EcommerceVitrineItemMoveu(
                                local: local,
                                tipo: item.tipo,
                                itemId: item.itemId,
                                indice: item.ordem + 1,
                              ),
                            ),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  IconButton(
                    tooltip: 'Remover',
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    onPressed: () => bloc.add(
                      EcommerceVitrineItemRemoveu(
                        local: local,
                        tipo: item.tipo,
                        itemId: item.itemId,
                      ),
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: Key('vitrine-salvar-${local.name}'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: salvando
                ? null
                : () => bloc.add(EcommerceVitrineSalvou(local: local)),
            icon: salvando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text('Salvar $titulo'),
          ),
        ],
      ),
    );
  }
}
