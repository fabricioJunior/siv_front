import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

class ListaPersonalizadaPage extends StatefulWidget {
  final int? listaId;

  const ListaPersonalizadaPage({super.key, this.listaId});

  @override
  State<ListaPersonalizadaPage> createState() => _ListaPersonalizadaPageState();
}

class _ListaPersonalizadaPageState extends State<ListaPersonalizadaPage> {
  late final ListaPersonalizadaBloc _bloc;
  final _tituloController = TextEditingController();
  int? _tabelaPrecoId;
  DateTime? _dataExpiracao;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ListaPersonalizadaBloc>();
    if (widget.listaId != null) {
      _bloc.add(ListaPersonalizadaAbriu(id: widget.listaId!));
    }
    SivPageTitulo.definir('Lista personalizada');
  }

  @override
  void dispose() {
    _bloc.close();
    _tituloController.dispose();
    SivPageTitulo.limpar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaPersonalizadaBloc>.value(
      value: _bloc,
      child: BlocConsumer<ListaPersonalizadaBloc, ListaPersonalizadaState>(
        listener: (context, state) {
          if (state.erro != null && state.erro!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: state.lista == null
                  ? (widget.listaId != null
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : _buildFormulario(context, state))
                  : _buildGestao(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormulario(BuildContext context, ListaPersonalizadaState state) {
    final textos = context.sivTextos;

    return SingleChildScrollView(
      child: SivCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nova lista personalizada', style: textos.rotulo),
            const SizedBox(height: 4),
            Text(
              'Monte uma lista de produtos e compartilhe o link com o cliente.',
              style: textos.apoio,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tituloController,
              maxLength: 255,
              decoration: const InputDecoration(labelText: 'Título da lista (opcional)'),
            ),
            const SizedBox(height: 16),
            TabelasDePrecoSeletor(
              onTabelaDePrecoChanged: (selecionadas) => setState(() {
                _tabelaPrecoId = selecionadas.isEmpty ? null : selecionadas.first.id;
              }),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final selecionado = await showDatePicker(
                  context: context,
                  initialDate: _dataExpiracao ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selecionado != null) {
                  setState(() => _dataExpiracao = selecionado);
                }
              },
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                _dataExpiracao == null
                    ? 'Data de expiração'
                    : 'Expira em: ${_formatarData(_dataExpiracao!)}',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: state.step == ListaPersonalizadaStep.salvando ||
                      _tabelaPrecoId == null ||
                      _dataExpiracao == null
                  ? null
                  : () => _bloc.add(
                        ListaPersonalizadaCriou(
                          tabelaPrecoId: _tabelaPrecoId!,
                          dataExpiracao: _dataExpiracao!,
                          titulo: _tituloController.text.trim().isEmpty
                              ? null
                              : _tituloController.text.trim(),
                        ),
                      ),
              icon: state.step == ListaPersonalizadaStep.salvando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Criar lista'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestao(BuildContext context, ListaPersonalizadaState state) {
    final lista = state.lista!;
    final textos = context.sivTextos;
    final link = state.link;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lista.titulo?.isNotEmpty == true ? lista.titulo! : 'Sem título',
                      style: textos.rotulo,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar título',
                    onPressed: state.atualizandoTitulo
                        ? null
                        : () => _editarTitulo(context, lista),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Link para o cliente', style: textos.rotulo),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: link == null
                        ? Text('Carregando link...', style: textos.apoio)
                        : SelectableText(link, style: textos.corpo),
                  ),
                  IconButton(
                    tooltip: 'Copiar link',
                    onPressed: link == null ? null : () => _copiarLink(context, link),
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Expira em: ${_formatarData(lista.dataExpiracao)}',
                style: textos.apoio,
              ),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        Row(
          children: [
            Text('Referências na lista (${lista.itens.length})', style: textos.rotulo),
            const Spacer(),
            FilledButton.icon(
              onPressed: state.atualizandoItens ? null : () => _adicionarReferencias(lista),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar referências'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: lista.itens.isEmpty
              ? Center(
                  child: Text('Nenhuma referência adicionada ainda.', style: textos.apoio),
                )
              : ListView.separated(
                  itemCount: lista.itens.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = lista.itens[index];
                    return ListTile(
                      leading: item.imagemUrl == null
                          ? const CircleAvatar(child: Icon(Icons.image_outlined))
                          : CircleAvatar(backgroundImage: NetworkImage(item.imagemUrl!)),
                      title: Text(item.nome),
                      subtitle: Text('R\$ ${item.valor.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        tooltip: 'Remover',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: state.atualizandoItens
                            ? null
                            : () => _bloc.add(
                                  ListaPersonalizadaReferenciasRemoveu(
                                    referenciaIds: [item.referenciaId],
                                  ),
                                ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  bool get _telaDesktop =>
      MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;

  Future<void> _adicionarReferencias(ListaPersonalizada lista) async {
    final idsAtuais = lista.itens.map((item) => item.referenciaId).toList();
    var selecionados = List<int>.from(idsAtuais);

    void aplicar() {
      final novos = selecionados.where((id) => !idsAtuais.contains(id)).toList();
      final removidos = idsAtuais.where((id) => !selecionados.contains(id)).toList();
      _bloc.add(
        ListaPersonalizadaItensAjustou(paraAdicionar: novos, paraRemover: removidos),
      );
    }

    final conteudo = ReferenciaSeletor(
      modo: ReferenciaSeletorModo.multipla,
      permitirCadastro: false,
      idReferenciasSelecionadasIniciais: idsAtuais,
      onReferenciaChanged: (referencias) {
        selecionados = referencias.map((r) => r.id).whereType<int>().toList();
      },
    );

    if (_telaDesktop) {
      await SivDialogo.mostrar(
        context,
        titulo: 'Adicionar referências',
        corpo: SizedBox(height: 420, child: conteudo),
        textoAcao: 'Salvar',
        onConfirmar: (_) => aplicar(),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              conteudo,
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  aplicar();
                },
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editarTitulo(BuildContext context, ListaPersonalizada lista) async {
    final controller = TextEditingController(text: lista.titulo ?? '');
    await SivDialogo.mostrar(
      context,
      titulo: 'Editar título',
      corpo: TextField(
        controller: controller,
        maxLength: 255,
        decoration: const InputDecoration(labelText: 'Título da lista'),
      ),
      textoAcao: 'Salvar',
      onConfirmar: (_) {
        final novoTitulo = controller.text.trim();
        _bloc.add(
          ListaPersonalizadaTituloAtualizou(titulo: novoTitulo.isEmpty ? null : novoTitulo),
        );
      },
    );
  }

  void _copiarLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiado.')),
    );
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}
