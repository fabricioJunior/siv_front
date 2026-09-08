import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';
import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/presentation.dart';
import 'package:empresas/use_cases.dart';
import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';
import 'package:precos/repositorios.dart';
import 'package:precos/use_cases.dart';

class _EcommerceRepositorioFake implements IEcommerceRepository {
  @override
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false}) async => [
        Ecommerce.create(id: 7, empresaId: 1, titulo: 'Loja teste'),
      ];

  @override
  Future<Ecommerce> recuperarEcommerce(int id) async =>
      Ecommerce.create(id: id, empresaId: 1, titulo: 'Loja teste');

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EcommerceBannersRepositorioFake implements IEcommerceBannersRepository {
  @override
  Future<List<EcommerceBanner>> recuperarBanners(int ecommerceId) async => const [];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _PermissoesControllerFake implements IPermissoesController {
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async => true;

  @override
  bool temAcesso({String? idComponente, int? grupoId}) => true;
}

class _EmpresasRepositorioFake implements IEmpresasRepository {
  @override
  Future<List<Empresa>> getEmpresas() async => const [];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _TerminaisRepositorioFake implements ITerminaisRepository {
  @override
  Future<List<Terminal>> recuperarTerminais({
    required int empresaId,
    String? nome,
    bool? inativo,
  }) async =>
      [];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FormasDePagamentoRepositorioFake implements IFormasDePagamentoRepository {
  @override
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({String? filtro}) async =>
      const [];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _TabelasDePrecoRepositorioFake implements ITabelasDePrecoRepository {
  @override
  Future<List<TabelaDePreco>> obterTabelasDePreco({String? nome, bool? inativa}) async => [
        TabelaDePreco.create(id: 1, nome: 'Padrão', padrao: true, inativa: false),
      ];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() {
    sl.reset();

    final ecommerceRepo = _EcommerceRepositorioFake();
    sl.registerFactory<EcommercesBloc>(
      () => EcommercesBloc(
        RecuperarEcommerces(repository: ecommerceRepo),
        ExcluirEcommerce(repository: ecommerceRepo),
        RestaurarEcommerce(repository: ecommerceRepo),
      ),
    );
    sl.registerFactory<EcommerceConfiguracaoBloc>(
      () => EcommerceConfiguracaoBloc(
        RecuperarEcommerce(repository: ecommerceRepo),
        SalvarEcommerce(repository: ecommerceRepo),
      ),
    );
    final bannersRepo = _EcommerceBannersRepositorioFake();
    sl.registerFactory<EcommerceBannersBloc>(
      () => EcommerceBannersBloc(
        RecuperarBannersEcommerce(repository: bannersRepo),
        CriarBannerEcommerce(repository: bannersRepo),
        AtualizarBannerEcommerce(repository: bannersRepo),
        ExcluirBannerEcommerce(repository: bannersRepo),
      ),
    );
    sl.registerLazySingleton<IPermissoesController>(_PermissoesControllerFake.new);

    final empresasRepo = _EmpresasRepositorioFake();
    sl.registerFactory<EmpresasBloc>(
      () => EmpresasBloc(RecuperarEmpresas(empresasRepository: empresasRepo)),
    );

    final terminaisRepo = _TerminaisRepositorioFake();
    sl.registerFactory<TerminaisBloc>(
      () => TerminaisBloc(
        RecuperarTerminais(repository: terminaisRepo),
        DesativarTerminal(repository: terminaisRepo),
      ),
    );

    final formasRepo = _FormasDePagamentoRepositorioFake();
    sl.registerFactory<FormasDePagamentoBloc>(
      () => FormasDePagamentoBloc(RecuperarFormasDePagamento(repository: formasRepo)),
    );

    final tabelasRepo = _TabelasDePrecoRepositorioFake();
    sl.registerFactory<TabelasDePrecoBloc>(
      () => TabelasDePrecoBloc(
        RecuperarTabelasDePreco(tabelasDePrecoRepository: tabelasRepo),
        DesativarTabelaDePreco(tabelasDePrecoRepository: tabelasRepo),
      ),
    );
  });

  testWidgets(
    'ao selecionar um canal na lista, o botão "Produtos no site" fica visível',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EcommercesPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Loja teste'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Produtos no site'), findsOneWidget);
    },
  );
}
