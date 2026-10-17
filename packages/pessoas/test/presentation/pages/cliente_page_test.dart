import 'package:core/cep.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/bloc/pontos_bloc/pontos_bloc.dart';
import 'package:pessoas/presentation/pages/cliente_page.dart';
import 'package:pessoas/presentation/widgets/cliente_abas.dart';
import 'package:pessoas/uses_cases.dart';

import '../../doubles/fakes.dart';

class _Permissoes implements IPermissoesController {
  final Set<String> ok;
  _Permissoes(this.ok);
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      ok.contains(idComponente);
  @override
  bool temAcesso({String? idComponente, int? grupoId}) =>
      ok.contains(idComponente);
}

class _RecPessoa extends Mock implements RecuperarPessoa {
  final bool generica;
  _RecPessoa({this.generica = false});
  @override
  Future<Pessoa?> call({required int idPessoa}) async =>
      fakePessoa(id: idPessoa, nome: 'Maria Souza', generica: generica);
}

class _RecPontos extends Mock implements RecuperarPontosDaPessoa {
  final List<Ponto> pontos;
  _RecPontos(this.pontos);
  @override
  Future<List<Ponto>> call({required int idPessoa}) async => pontos;
}

class _RecEnderecos extends Mock implements RecuperarEnderecosDaPessoa {
  final List<Endereco> enderecos;
  _RecEnderecos(this.enderecos);
  @override
  Future<List<Endereco>> call({required int idPessoa}) async => enderecos;
}

class _CriarPontos extends Mock implements CriarPontos {}

class _CancelarPonto extends Mock implements CancelarPonto {}

class _ResgatarPontos extends Mock implements ResgatarPontos {}

class _SalvarPessoa extends Mock implements SalvarPessoa {}

class _CriarPessoa extends Mock implements CriarPessoa {}

class _CriarFuncionario extends Mock implements CriarFuncionario {}

class _SalvarFuncionario extends Mock implements SalvarFuncionario {}

class _RecFuncionarios extends Mock implements RecuperarFuncionarios {}

class _CriarEndereco extends Mock implements CriarEndereco {}

class _SalvarEndereco extends Mock implements SalvarEndereco {}

class _ExcluirEndereco extends Mock implements ExcluirEndereco {}

class _PessoaPeloDoc extends Mock implements RecuperarPessoaPeloDocumento {}

Endereco _end(int id, {required bool principal}) => Endereco.create(
      id: id,
      principal: principal,
      tipoEndereco: TipoEndereco.residencial,
      cep: '01001000',
      logradouro: 'Rua $id',
      numero: '$id',
      complemento: '',
      bairro: 'Centro',
      municipio: 'São Paulo',
      uf: 'SP',
      pais: 'Brasil',
    );

const _todas = {'PESFM001', 'PESFM004', 'PESFC004'};

Future<void> _pump(
  WidgetTester t, {
  ClienteAba aba = ClienteAba.dados,
  double largura = 1280,
  Set<String> permissoes = _todas,
  List<Ponto> pontos = const [],
  List<Endereco> enderecos = const [],
  bool generica = false,
  bool comTransferir = true,
}) async {
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final antigo = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
  };
  addTearDown(() => FlutterError.onError = antigo);
  await sl.reset();
  addTearDown(sl.reset);
  sl.registerSingleton<IPermissoesController>(_Permissoes(permissoes));
  sl.registerFactory(() => PessoaBloc(
        _RecPessoa(generica: generica),
        _SalvarPessoa(),
        _CriarPessoa(),
        _CriarFuncionario(),
        _SalvarFuncionario(),
        _RecFuncionarios(),
        _CriarEndereco(),
        CepService(),
        _PessoaPeloDoc(),
      ));
  sl.registerFactory(() => PontosBloc(_RecPontos(pontos), _CriarPontos(),
      _RecPessoa(), _CancelarPonto(), _ResgatarPontos()));
  sl.registerFactory(() => EnderecosBloc(_RecEnderecos(enderecos),
      _CriarEndereco(), _SalvarEndereco(), _ExcluirEndereco()));
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: PessoaVisualizacaoPage(
      idPessoa: 1,
      aba: aba,
      aoTransferirCredito:
          comTransferir ? (_, __, ___) async => false : null,
      abaComprasBuilder: (_, __, ___) => const Text('CONTEUDO_COMPRAS'),
      abaCreditoBuilder: (_, __, ___) => const Text('CONTEUDO_CREDITO'),
    ),
  ));
  await t.pumpAndSettle();
}

Finder _botao(String rotulo) => find.ancestor(
    of: find.text(rotulo), matching: find.bySubtype<ButtonStyleButton>());

void main() {
  test('ClienteAba.de: nome do enum; desconhecido/nulo = dados', () {
    expect(ClienteAba.de('credito'), ClienteAba.credito);
    expect(ClienteAba.de('pontos'), ClienteAba.pontos);
    expect(ClienteAba.de('x'), ClienteAba.dados);
    expect(ClienteAba.de(null), ClienteAba.dados);
  });

  for (final largura in [800.0, 1280.0]) {
    group('deep link ($largura px)', () {
      testWidgets('dados', (t) async {
        await _pump(t, aba: ClienteAba.dados, largura: largura);
        expect(find.text('IDENTIFICAÇÃO'), findsOneWidget);
      });
      testWidgets('enderecos', (t) async {
        await _pump(t, aba: ClienteAba.enderecos, largura: largura);
        expect(find.text('Nenhum endereço cadastrado.'), findsOneWidget);
      });
      testWidgets('compras', (t) async {
        await _pump(t, aba: ClienteAba.compras, largura: largura);
        expect(find.text('CONTEUDO_COMPRAS'), findsOneWidget);
      });
      testWidgets('pontos', (t) async {
        await _pump(t, aba: ClienteAba.pontos, largura: largura);
        expect(find.text('Nenhum ponto lançado até o momento.'),
            findsOneWidget);
      });
      testWidgets('credito', (t) async {
        await _pump(t, aba: ClienteAba.credito, largura: largura);
        expect(find.text('CONTEUDO_CREDITO'), findsOneWidget);
      });
    });
  }

  group('ações do cabeçalho por aba (1280px)', () {
    testWidgets('dados: Editar cadastro (PESFM001)', (t) async {
      await _pump(t);
      expect(_botao('Editar cadastro'), findsOneWidget);
      expect(_botao('Novo endereço'), findsNothing);
    });
    testWidgets('dados sem PESFM001: sem botão', (t) async {
      await _pump(t, permissoes: {});
      expect(_botao('Editar cadastro'), findsNothing);
    });
    testWidgets('endereços: Novo endereço', (t) async {
      await _pump(t, aba: ClienteAba.enderecos);
      expect(_botao('Novo endereço'), findsOneWidget);
      expect(_botao('Editar cadastro'), findsNothing);
    });
    testWidgets('pontos: Resgatar e Lançar', (t) async {
      await _pump(t, aba: ClienteAba.pontos);
      expect(_botao('Resgatar pontos'), findsOneWidget);
      expect(_botao('Lançar pontos'), findsOneWidget);
    });
    testWidgets('compras: nenhuma ação', (t) async {
      await _pump(t, aba: ClienteAba.compras);
      expect(find.bySubtype<FilledButton>(), findsNothing);
      expect(find.bySubtype<OutlinedButton>(), findsNothing);
    });
    testWidgets('crédito: Transferir com PESFM004+PESFC004', (t) async {
      await _pump(t, aba: ClienteAba.credito);
      expect(_botao('Transferir do não cadastrado'), findsOneWidget);
    });
    testWidgets('crédito: sem PESFC004 não transfere', (t) async {
      await _pump(t,
          aba: ClienteAba.credito, permissoes: {'PESFM001', 'PESFM004'});
      expect(_botao('Transferir do não cadastrado'), findsNothing);
    });
    testWidgets('crédito: pessoa genérica não transfere', (t) async {
      await _pump(t, aba: ClienteAba.credito, generica: true);
      expect(_botao('Transferir do não cadastrado'), findsNothing);
    });
    testWidgets('trocar de aba troca as ações', (t) async {
      await _pump(t);
      await t.tap(find.text('Pontos').first);
      await t.pumpAndSettle();
      expect(_botao('Editar cadastro'), findsNothing);
      expect(_botao('Lançar pontos'), findsOneWidget);
    });
  });

  group('mobile (800px)', () {
    testWidgets('chips das abas têm 44px de altura', (t) async {
      await _pump(t, largura: 800);
      for (final a in ClienteAba.values) {
        final chip = find.ancestor(
          of: find.text(a.rotulo),
          matching: find.byType(Container),
        );
        final h = t
            .widgetList<Container>(chip)
            .where((c) => c.constraints?.maxHeight == 44)
            .length;
        expect(h, greaterThan(0), reason: 'chip ${a.rotulo}');
      }
      final chip = find.ancestor(
          of: find.text('Dados'), matching: find.byType(Container));
      expect(
        chip.evaluate().any((e) => (e.renderObject as RenderBox).size.height == 44),
        isTrue,
      );
    });

    testWidgets('cabeçalho só tem o lápis; ação principal vai ao rodapé',
        (t) async {
      await _pump(t, largura: 800, aba: ClienteAba.pontos);
      expect(find.byTooltip('Editar cadastro'), findsOneWidget);
      // Resgatar/Lançar existem uma vez só (no rodapé), não no cabeçalho.
      expect(_botao('Lançar pontos'), findsOneWidget);
      expect(_botao('Resgatar pontos'), findsOneWidget);
      final topo = t.getTopLeft(_botao('Lançar pontos')).dy;
      expect(topo, greaterThan(700));
    });

    testWidgets('desktop não tem rodapé; ações no cabeçalho', (t) async {
      await _pump(t, aba: ClienteAba.pontos);
      expect(t.getTopLeft(_botao('Lançar pontos')).dy, lessThan(100));
    });

    testWidgets('rodapé fixo continua visível com teclado aberto',
        (t) async {
      await _pump(t, largura: 800, aba: ClienteAba.pontos);
      t.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(t.view.resetViewInsets);
      await t.pump();
      final b = t.getRect(_botao('Lançar pontos'));
      expect(b.bottom, lessThanOrEqualTo(900 - 300));
    });
  });

  group('Pontos', () {
    testWidgets('cancelado continua na lista, riscado e sem menu',
        (t) async {
      await _pump(t, aba: ClienteAba.pontos, pontos: [
        fakePonto(id: 1, valor: 10, descricao: 'Lanc valido'),
        fakePonto(id: 2, valor: 5, descricao: 'Anulado', cancelado: true),
      ]);
      expect(find.text('Anulado'), findsOneWidget);
      expect(find.text('Cancelado'), findsOneWidget);
      expect(t.widget<Text>(find.text('Anulado')).style?.decoration,
          TextDecoration.lineThrough);
      expect(t.widget<Text>(find.text('Lanc valido')).style?.decoration,
          isNot(TextDecoration.lineThrough));
      // menu só na linha ativa
      expect(find.byTooltip('Ações'), findsOneWidget);
      // saldo ignora o cancelado
      expect(find.text('10 pts'), findsOneWidget);
    });
  });

  group('Endereços', () {
    Future<void> abrirMenu(WidgetTester t, int indice) async {
      await t.tap(find.byTooltip('Ações').at(indice));
      await t.pumpAndSettle();
    }

    testWidgets('principal não pode ser removido; secundário pode',
        (t) async {
      await _pump(t, aba: ClienteAba.enderecos, enderecos: [
        _end(1, principal: true),
        _end(2, principal: false),
      ]);
      expect(find.text('Principal'), findsOneWidget);

      await abrirMenu(t, 0);
      PopupMenuItem<String> item(String k) => t
          .widgetList<PopupMenuItem<String>>(find.byType(PopupMenuItem<String>))
          .firstWhere((i) => (i.child as Text).data == k);
      expect(item('Remover').enabled, isFalse);
      expect(item('Tornar principal').enabled, isFalse);
      expect(item('Editar').enabled, isTrue);
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();

      await abrirMenu(t, 1);
      expect(item('Remover').enabled, isTrue);
      expect(item('Tornar principal').enabled, isTrue);
    });
  });
}
