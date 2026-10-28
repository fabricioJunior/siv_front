import 'package:core/bloc.dart';
import 'package:core/seletores/i_seletor.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/referencia_cadastro_bloc/referencia_cadastro_bloc.dart';
import 'package:produtos/presentantion/pages/referencia_cadastro_page.dart';
import 'package:produtos/presentantion/widgets/referencia_espera_secao.dart';
import 'package:produtos/presentantion/widgets/referencia_mobile.dart';

class _BlocFalso implements ReferenciaCadastroBloc {
  @override
  Stream<ReferenciaCadastroState> get stream => const Stream.empty();

  @override
  ReferenciaCadastroState get state => const ReferenciaCadastroState();

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void _mobile(WidgetTester t) {
  t.view.physicalSize = const Size(360, 780);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Widget _app(Widget child) => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  testWidgets('mobile 360px: resumo mostra fornecedor, código, status e quantidade esperada', (t) async {
    _mobile(t);
    var editou = false;
    await t.pumpWidget(_app(ReferenciaResumoMobileCard(
      referencia: Referencia.create(
        id: 1,
        nome: 'Body Áurora Rendado Manga Longa Vinho Especial Edição',
        idExterno: 'DL-2231',
        fornecedorNome: 'Duloren Indústria de Confecções Ltda',
        quantidadeEsperada: 24,
        status: const ReferenciaStatusEntrada(nova: true, aguardandoPrimeiraEntrada: true),
      ),
      onEditar: () => editou = true,
    )));

    expect(t.takeException(), isNull);
    expect(find.byKey(const Key('resumo_fornecimento')), findsOneWidget);
    expect(find.text('Nova'), findsOneWidget);
    expect(find.text('Aguardando 1ª entrada'), findsOneWidget);
    expect(find.text('24 peças esperadas'), findsOneWidget);
    // "Editar" com área de toque de 44px
    expect(t.getSize(find.byKey(const Key('resumo_editar'))).height, greaterThanOrEqualTo(44));
    await t.tap(find.byKey(const Key('resumo_editar')));
    expect(editou, isTrue);
  });

  testWidgets('mobile: referência sem status nem fornecedor não ganha linhas extras', (t) async {
    _mobile(t);
    await t.pumpWidget(_app(ReferenciaResumoMobileCard(
      referencia: Referencia.create(id: 1, nome: 'Velha'),
      onEditar: () {},
    )));
    expect(find.byKey(const Key('resumo_fornecimento')), findsNothing);
    expect(find.text('Nova'), findsNothing);
  });

  testWidgets('mobile 360px: seção de fornecimento sem overflow, interruptor e data com 44px+', (t) async {
    _mobile(t);
    final qtd = TextEditingController(text: '24');
    final codigo = TextEditingController(text: 'DL-2231');
    addTearDown(qtd.dispose);
    addTearDown(codigo.dispose);
    await t.pumpWidget(_app(ReferenciaEsperaSecao(
      fornecedorSeletor: (d) => const Text('seletor de fornecedor'),
      fornecedor: SelectData(id: 7, nome: 'Duloren', data: const {}),
      onFornecedor: (_) {},
      codigoNoFornecedor: codigo,
      status: const ReferenciaStatusEntrada(aguardandoReposicao: true),
      aguardandoReposicao: true,
      onAguardandoReposicao: (_) {},
      previsaoChegada: DateTime(2026, 12, 1),
      onPrevisaoChegada: (_) {},
      quantidadeEsperada: qtd,
    )));

    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(SwitchListTile)).height, greaterThanOrEqualTo(44));
    expect(t.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(44));
    expect(find.text('01/12/2026'), findsOneWidget);
  });

  testWidgets('mobile: interruptor de reposição desabilitado antes da 1ª entrada, com a explicação', (t) async {
    _mobile(t);
    final qtd = TextEditingController();
    final codigo = TextEditingController();
    addTearDown(qtd.dispose);
    addTearDown(codigo.dispose);
    await t.pumpWidget(_app(ReferenciaEsperaSecao(
      fornecedorSeletor: null,
      fornecedor: null,
      onFornecedor: (_) {},
      codigoNoFornecedor: codigo,
      status: const ReferenciaStatusEntrada(nova: true, aguardandoPrimeiraEntrada: true),
      aguardandoReposicao: false,
      onAguardandoReposicao: (_) {},
      previsaoChegada: null,
      onPrevisaoChegada: (_) {},
      quantidadeEsperada: qtd,
    )));

    expect(find.text('Disponível depois da 1ª entrada.'), findsOneWidget);
    expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged, isNull);
  });

  testWidgets('mobile 360px: "Escolher agora / Definir na chegada" cabe e tem 48px de altura', (t) async {
    _mobile(t);
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: BlocProvider<ReferenciaCadastroBloc>.value(
          value: _BlocFalso(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: VariacoesEscolhaCadastro(
              state: const ReferenciaCadastroState(definirNaChegada: true),
            ),
          ),
        ),
      ),
    ));

    expect(t.takeException(), isNull);
    expect(find.text('Escolher agora'), findsOneWidget);
    expect(find.text('Definir na chegada'), findsOneWidget);
    expect(t.getSize(find.byType(SegmentedButton<bool>)).height, greaterThanOrEqualTo(48));
    expect(find.text('Escolher foto'), findsOneWidget);
  });
}
