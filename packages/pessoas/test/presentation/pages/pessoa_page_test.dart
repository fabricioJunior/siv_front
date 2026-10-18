import 'package:core/cep.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/pages/pessoa_page.dart';
import 'package:pessoas/uses_cases.dart';

import '../../doubles/fakes.dart';

class _Permissoes implements IPermissoesController {
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      true;
  @override
  bool temAcesso({String? idComponente, int? grupoId}) => true;
}

class _RecPessoa extends Mock implements RecuperarPessoa {
  final Pessoa pessoa;
  _RecPessoa(this.pessoa);
  @override
  Future<Pessoa?> call({required int idPessoa}) async => pessoa;
}

class _RecFuncionarios extends Mock implements RecuperarFuncionarios {
  @override
  Future<Iterable<Funcionario>> call({int? pessoaId}) async => [];
}

class _SalvarPessoa extends Mock implements SalvarPessoa {}

class _CriarPessoa extends Mock implements CriarPessoa {}

class _CriarFuncionario extends Mock implements CriarFuncionario {}

class _SalvarFuncionario extends Mock implements SalvarFuncionario {}

class _CriarEndereco extends Mock implements CriarEndereco {}

class _PessoaPeloDoc extends Mock implements RecuperarPessoaPeloDocumento {}

Future<void> _pump(
  WidgetTester t, {
  int? idPessoa,
  Pessoa? pessoa,
  double largura = 1280,
}) async {
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await sl.reset();
  addTearDown(sl.reset);
  sl.registerSingleton<IPermissoesController>(_Permissoes());
  sl.registerFactory(() => PessoaBloc(
        _RecPessoa(pessoa ?? fakePessoa()),
        _SalvarPessoa(),
        _CriarPessoa(),
        _CriarFuncionario(),
        _SalvarFuncionario(),
        _RecFuncionarios(),
        _CriarEndereco(),
        CepService(),
        _PessoaPeloDoc(),
      ));
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: PessoaPage(idPessoa: idPessoa),
  ));
  await t.pumpAndSettle();
}

void main() {
  group('modo cliente (padrão)', () {
    testWidgets('página única: sem Funcionário, sem Stepper', (t) async {
      await _pump(t);
      expect(find.text('Novo cliente'), findsOneWidget);
      expect(find.byType(Stepper), findsNothing);
      expect(find.text('Funcionário'), findsNothing);
      expect(find.text('Vínculo'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);
      expect(find.text('Fornecedor'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Salvar cliente'), findsOneWidget);
    });

    testWidgets('PF mostra Data de nascimento', (t) async {
      await _pump(t);
      expect(find.text('Data de nascimento'), findsOneWidget);
    });

    testWidgets('PJ troca para Razão social e esconde nascimento',
        (t) async {
      await _pump(t);
      await t.tap(find.text('Pessoa jurídica'));
      await t.pumpAndSettle();
      expect(find.text('Razão social'), findsOneWidget);
      expect(find.text('Data de nascimento'), findsNothing);
    });

    for (final largura in [600.0, 1280.0]) {
      testWidgets('Salvar cliente visível com teclado aberto ($largura px)',
          (t) async {
        await _pump(t, largura: largura);
        t.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(t.view.resetViewInsets);
        await t.pump();
        final r = t.getRect(find.text('Salvar cliente'));
        expect(r.bottom, lessThanOrEqualTo(900 - 300));
        expect(r.top, greaterThan(0));
      });
    }
  });

  testWidgets('pessoa com eFuncionario abre em modo completo', (t) async {
    await _pump(t,
        idPessoa: 1, pessoa: fakePessoa(eFuncionario: true, eCliente: false));
    expect(find.byType(Stepper), findsOneWidget);
    expect(find.text('Salvar cliente'), findsNothing);
  });

  testWidgets('cliente existente fica em modo cliente', (t) async {
    await _pump(t, idPessoa: 1);
    expect(find.text('Editar cadastro'), findsOneWidget);
    expect(find.byType(Stepper), findsNothing);
  });
}
