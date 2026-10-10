import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/presentation/widgets/lista_filtro_construtor.dart';
import 'package:comercial/presentation/widgets/lista_seletores.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String formatarDataLista(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

/// Formulário de criação/edição de lista. Provador mantém os campos de
/// sempre (tabela e validade obrigatórias); catálogo tem descrição, ícone,
/// período e tabela opcionais e modo manual/filtro.
class ListaPersonalizadaFormulario extends StatefulWidget {
  final ListaPersonalizada? lista;
  final ListaSeletores seletores;
  final bool salvando;
  final String textoSalvar;
  final String? iconeNovoNome;
  final VoidCallback onEscolherIcone;
  final ValueChanged<ListaPersonalizadaInput> onSalvar;

  const ListaPersonalizadaFormulario({
    super.key,
    this.lista,
    required this.seletores,
    required this.onSalvar,
    required this.onEscolherIcone,
    this.iconeNovoNome,
    this.salvando = false,
    this.textoSalvar = 'Criar lista',
  });

  @override
  State<ListaPersonalizadaFormulario> createState() =>
      _ListaPersonalizadaFormularioState();
}

class _ListaPersonalizadaFormularioState
    extends State<ListaPersonalizadaFormulario> {
  late final _titulo = TextEditingController(text: widget.lista?.titulo ?? '');
  late final _descricao =
      TextEditingController(text: widget.lista?.descricao ?? '');
  late ListaTipo _tipo = widget.lista?.tipo ?? ListaTipo.provador;
  late ListaModo _modo = widget.lista?.modo ?? ListaModo.manual;
  late int? _tabelaPrecoId = widget.lista?.tabelaPrecoId;
  late DateTime? _inicio = widget.lista?.dataInicio;
  late DateTime? _fim = widget.lista?.dataExpiracao;
  late bool _semPrazo = widget.lista != null
      ? widget.lista!.dataInicio == null && widget.lista!.dataExpiracao == null
      : true;
  late ListaFiltro _filtro = widget.lista?.filtro ?? const ListaFiltro();

  bool get _catalogo => _tipo == ListaTipo.catalogo;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  String? get _erro {
    if (_catalogo) {
      if (_titulo.text.trim().isEmpty) return 'Informe o título.';
      if (!_semPrazo && _inicio != null && _fim != null && _fim!.isBefore(_inicio!)) {
        return 'O fim não pode ser antes do início.';
      }
      if (_modo == ListaModo.filtro && _filtro.vazio) {
        return 'Defina ao menos um critério no filtro.';
      }
      return null;
    }
    if (_tabelaPrecoId == null) return 'Escolha a tabela de preço.';
    if (_fim == null) return 'Informe a data de expiração.';
    return null;
  }

  void _salvar() {
    final catalogo = _catalogo;
    widget.onSalvar(
      ListaPersonalizadaInput(
        titulo: _titulo.text,
        descricao: catalogo ? _descricao.text : null,
        tipo: _tipo,
        modo: catalogo ? _modo : ListaModo.manual,
        dataInicio: catalogo && !_semPrazo ? _inicio : null,
        dataExpiracao: catalogo && _semPrazo ? null : _fim,
        tabelaPrecoId: _tabelaPrecoId,
        filtro: catalogo && _modo == ListaModo.filtro ? _filtro : null,
      ),
    );
  }

  Future<DateTime?> _escolherData(DateTime? atual, DateTime padrao) =>
      showDatePicker(
        context: context,
        initialDate: atual ?? padrao,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      );

  Widget _botaoData(String rotulo, DateTime? valor, ValueChanged<DateTime?> set,
      DateTime padrao) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
      onPressed: () async {
        final d = await _escolherData(valor, padrao);
        if (d != null) setState(() => set(d));
      },
      icon: const Icon(Icons.event_outlined, size: 18),
      label: Text(valor == null ? rotulo : '$rotulo: ${formatarDataLista(valor)}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final editando = widget.lista != null;
    final erro = _erro;
    final iconeAtual = widget.lista?.icone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ListaTipo>(
          key: const Key('lista-tipo'),
          segments: const [
            ButtonSegment(
              value: ListaTipo.provador,
              label: Text('Provador'),
              icon: Icon(Icons.checkroom_outlined),
            ),
            ButtonSegment(
              value: ListaTipo.catalogo,
              label: Text('Catálogo'),
              icon: Icon(Icons.storefront_outlined),
            ),
          ],
          selected: {_tipo},
          onSelectionChanged: editando
              ? null
              : (v) => setState(() => _tipo = v.first),
        ),
        const SizedBox(height: 4),
        Text(
          _catalogo
              ? 'Catálogo: vitrine do e-commerce (menu e home do site).'
              : 'Provador: lista compartilhada por link com o cliente.',
          style: textos.apoio,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('lista-titulo'),
          controller: _titulo,
          maxLength: 255,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: _catalogo ? 'Título da lista' : 'Título da lista (opcional)',
          ),
        ),
        if (_catalogo) ...[
          const SizedBox(height: 8),
          TextField(
            key: const Key('lista-descricao'),
            controller: _descricao,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (iconeAtual != null && widget.iconeNovoNome == null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(backgroundImage: NetworkImage(iconeAtual)),
                ),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('lista-icone'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: widget.onEscolherIcone,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(
                    widget.iconeNovoNome ??
                        (iconeAtual == null ? 'Escolher ícone' : 'Trocar ícone'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        widget.seletores.tabelaDePreco(
          SeletorData(
            itemsSelecionadosInicial: _tabelaPrecoId == null
                ? null
                : [SelectData(id: _tabelaPrecoId!, nome: '', data: const {})],
            onChanged: (sel) =>
                setState(() => _tabelaPrecoId = sel.isEmpty ? null : sel.first.id),
          ),
        ),
        if (_catalogo)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _tabelaPrecoId == null
                  ? 'Sem tabela: usa a tabela de preço do e-commerce.'
                  : 'Preços desta lista vêm da tabela escolhida.',
              style: textos.apoio,
            ),
          ),
        const SizedBox(height: 16),
        if (_catalogo)
          SwitchListTile(
            key: const Key('lista-sem-prazo'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Sem prazo'),
            subtitle: const Text('Lista sempre ativa'),
            value: _semPrazo,
            onChanged: (v) => setState(() => _semPrazo = v),
          ),
        if (_catalogo && !_semPrazo) ...[
          _botaoData('Início (opcional)', _inicio, (d) => _inicio = d, DateTime.now()),
          const SizedBox(height: 8),
          _botaoData(
            'Fim (opcional)',
            _fim,
            (d) => _fim = d,
            DateTime.now().add(const Duration(days: 30)),
          ),
        ],
        if (!_catalogo)
          _botaoData(
            'Expira em',
            _fim,
            (d) => _fim = d,
            DateTime.now().add(const Duration(days: 7)),
          ),
        if (_catalogo) ...[
          const SizedBox(height: 16),
          SegmentedButton<ListaModo>(
            key: const Key('lista-modo'),
            segments: const [
              ButtonSegment(
                value: ListaModo.manual,
                label: Text('Itens avulsos'),
                icon: Icon(Icons.checklist_outlined),
              ),
              ButtonSegment(
                value: ListaModo.filtro,
                label: Text('Por filtro'),
                icon: Icon(Icons.filter_alt_outlined),
              ),
            ],
            selected: {_modo},
            onSelectionChanged: (v) => setState(() => _modo = v.first),
          ),
          if (_modo == ListaModo.filtro) ...[
            const SizedBox(height: 16),
            ListaFiltroConstrutor(
              inicial: _filtro,
              seletores: widget.seletores,
              onChanged: (f) => setState(() => _filtro = f),
            ),
          ],
        ],
        const SizedBox(height: 20),
        if (erro != null) ...[
          Text(erro, key: const Key('lista-erro'), style: textos.apoio),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          key: const Key('lista-salvar'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: widget.salvando || erro != null ? null : _salvar,
          icon: widget.salvando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(widget.textoSalvar),
        ),
      ],
    );
  }
}
