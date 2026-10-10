import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _seletor(String nome) => Text('seletor-$nome');

final _seletores = ListaSeletores(
  tabelaDePreco: (d) => _SeletorTabela(d),
  categoria: (_) => _seletor('categoria'),
  subCategoria: ({required categoriaIds, required data}) => _seletor('sub'),
  tamanho: (_) => _seletor('tamanho'),
  cor: (_) => _seletor('cor'),
  promocao: (_) => _seletor('promocao'),
);

class _SeletorTabela extends StatelessWidget {
  final SeletorData data;
  const _SeletorTabela(this.data);

  @override
  Widget build(BuildContext context) => TextButton(
        key: const Key('escolher-tabela'),
        onPressed: () =>
            data.onChanged?.call([SelectData(id: 9, nome: 'T', data: const {})]),
        child: const Text('tabela'),
      );
}

Future<List<ListaPersonalizadaInput>> _monta(WidgetTester t, {ListaPersonalizada? lista}) async {
  final salvos = <ListaPersonalizadaInput>[];
  await t.binding.setSurfaceSize(const Size(800, 2400));
  await t.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ListaPersonalizadaFormulario(
            lista: lista,
            seletores: _seletores,
            onEscolherIcone: () {},
            onSalvar: salvos.add,
          ),
        ),
      ),
    ),
  );
  return salvos;
}

void main() {
  testWidgets('provador exige tabela e expiração (como antes)', (t) async {
    await _monta(t);

    expect(find.byKey(const Key('lista-descricao')), findsNothing);
    expect(t.widget<FilledButton>(find.byKey(const Key('lista-salvar'))).onPressed, isNull);
  });

  testWidgets('catálogo: sem prazo e sem tabela salva com campos opcionais nulos', (t) async {
    final salvos = await _monta(t);

    await t.tap(find.text('Catálogo'));
    await t.pump();
    await t.enterText(find.byKey(const Key('lista-titulo')), 'Novidades');
    await t.enterText(find.byKey(const Key('lista-descricao')), 'Chegou agora');
    await t.pump();
    await t.tap(find.byKey(const Key('lista-salvar')));

    final i = salvos.single;
    expect(i.tipo, ListaTipo.catalogo);
    expect(i.modo, ListaModo.manual);
    expect(i.descricao, 'Chegou agora');
    expect(i.dataInicio, isNull);
    expect(i.dataExpiracao, isNull);
    expect(i.tabelaPrecoId, isNull);
    expect(i.filtro, isNull);
  });

  testWidgets('catálogo por filtro exige critério, mostra construtor e envia tabela escolhida', (t) async {
    final salvos = await _monta(t);
    await t.tap(find.text('Catálogo'));
    await t.pump();
    await t.enterText(find.byKey(const Key('lista-titulo')), 'Promo');
    await t.tap(find.text('Por filtro'));
    await t.pump();

    expect(find.text('seletor-categoria'), findsOneWidget);
    expect(find.text('seletor-sub'), findsOneWidget);
    expect(find.text('seletor-promocao'), findsOneWidget);
    expect(t.widget<FilledButton>(find.byKey(const Key('lista-salvar'))).onPressed, isNull);

    await t.tap(find.byKey(const Key('filtro-qualquer-promocao')));
    await t.pump();
    await t.tap(find.byKey(const Key('escolher-tabela')));
    await t.pump();
    await t.tap(find.byKey(const Key('lista-salvar')));

    final i = salvos.single;
    expect(i.modo, ListaModo.filtro);
    expect(i.filtro!.apenasEmPromocao, isTrue);
    expect(i.tabelaPrecoId, 9);
  });
}
