import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/presentation/widgets/lista_seletores.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<SelectData> _iniciais(List<int> ids) =>
    ids.map((id) => SelectData(id: id, nome: '', data: const {})).toList();

/// Monta o [ListaFiltro] da lista dinâmica (categorias, subcategorias,
/// tamanhos, cores, estoque e promoções).
class ListaFiltroConstrutor extends StatefulWidget {
  final ListaFiltro inicial;
  final ValueChanged<ListaFiltro> onChanged;
  final ListaSeletores seletores;

  const ListaFiltroConstrutor({
    super.key,
    required this.inicial,
    required this.onChanged,
    required this.seletores,
  });

  @override
  State<ListaFiltroConstrutor> createState() => _ListaFiltroConstrutorState();
}

class _ListaFiltroConstrutorState extends State<ListaFiltroConstrutor> {
  late List<int> _categorias = widget.inicial.categoriaIds;
  late List<int> _subCategorias = widget.inicial.subCategoriaIds;
  late List<int> _tamanhos = widget.inicial.tamanhoIds;
  late List<int> _cores = widget.inicial.corIds;
  late List<int> _promocoes = widget.inicial.promocaoIds;
  late bool _apenasEmPromocao = widget.inicial.apenasEmPromocao;
  late EstoqueOperador? _operador = widget.inicial.estoque?.operador;
  late final _quantidade = TextEditingController(
    text: widget.inicial.estoque?.quantidade.toString() ?? '',
  );

  @override
  void dispose() {
    _quantidade.dispose();
    super.dispose();
  }

  void _emitir() {
    final quantidade = int.tryParse(_quantidade.text.trim());
    widget.onChanged(
      ListaFiltro(
        categoriaIds: _categorias,
        subCategoriaIds: _subCategorias,
        tamanhoIds: _tamanhos,
        corIds: _cores,
        estoque: _operador != null && quantidade != null
            ? ListaFiltroEstoque(operador: _operador!, quantidade: quantidade)
            : null,
        promocaoIds: _apenasEmPromocao ? const [] : _promocoes,
        apenasEmPromocao: _apenasEmPromocao,
      ),
    );
  }

  SeletorData _dados(List<int> iniciais, void Function(List<int>) set) =>
      SeletorData(
        itemsSelecionadosInicial: _iniciais(iniciais),
        onChanged: (sel) {
          set(sel.map((s) => s.id).toList());
          _emitir();
        },
      );

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final s = widget.seletores;
    const gap = SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Filtro da lista', style: textos.rotulo),
        Text(
          'Campos juntos se combinam (E); dentro de cada campo vale qualquer um (OU).',
          style: textos.apoio,
        ),
        gap,
        s.categoria(_dados(_categorias, (v) => _categorias = v)),
        gap,
        s.subCategoria(
          categoriaIds: _categorias,
          data: _dados(_subCategorias, (v) => _subCategorias = v),
        ),
        gap,
        s.tamanho(_dados(_tamanhos, (v) => _tamanhos = v)),
        gap,
        s.cor(_dados(_cores, (v) => _cores = v)),
        gap,
        Text('Estoque na empresa do e-commerce', style: textos.rotulo),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<EstoqueOperador?>(
                key: const Key('filtro-estoque-operador'),
                initialValue: _operador,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Qualquer')),
                  DropdownMenuItem(
                    value: EstoqueOperador.igual,
                    child: Text('Igual a'),
                  ),
                  DropdownMenuItem(
                    value: EstoqueOperador.ate,
                    child: Text('Até'),
                  ),
                  DropdownMenuItem(
                    value: EstoqueOperador.aPartir,
                    child: Text('A partir de'),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _operador = v);
                  _emitir();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                key: const Key('filtro-estoque-quantidade'),
                controller: _quantidade,
                enabled: _operador != null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Nº'),
                onChanged: (_) => _emitir(),
              ),
            ),
          ],
        ),
        gap,
        SwitchListTile(
          key: const Key('filtro-qualquer-promocao'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Qualquer promoção vigente'),
          value: _apenasEmPromocao,
          onChanged: (v) {
            setState(() => _apenasEmPromocao = v);
            _emitir();
          },
        ),
        if (!_apenasEmPromocao)
          s.promocao(_dados(_promocoes, (v) => _promocoes = v)),
      ],
    );
  }
}
