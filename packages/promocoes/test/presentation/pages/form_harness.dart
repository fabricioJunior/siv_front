import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/presentation/widgets/form_promocional_layout.dart';
import 'package:promocoes/use_cases.dart';

class RepoCupomFake implements ICuponsRepository {
  Cupom? salvo;
  @override
  Future<List<Cupom>> recuperarCupons({String? codigo, bool? ativa, bool? vigente}) async => const [];
  @override
  Future<Cupom?> recuperarCupom(int id) async => null;
  @override
  Future<Cupom> criarCupom(Cupom c) async => salvo = c;
  @override
  Future<Cupom> atualizarCupom(Cupom c) async => salvo = c;
}

class RepoPromocaoFake implements IPromocoesRepository {
  Promocao? salva;
  @override
  Future<List<Promocao>> recuperarPromocoes({String? nome, bool? ativa, bool? vigente}) async => const [];
  @override
  Future<Promocao?> recuperarPromocao(int id) async => null;
  @override
  Future<Promocao> criarPromocao(Promocao p) async => salva = p;
  @override
  Future<Promocao> atualizarPromocao(Promocao p) async => salva = p;
}

class RepoFormasFake implements IFormasDePagamentoRepository {
  @override
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({String? filtro}) async => const [];
  @override
  Future<FormaDePagamento?> recuperarFormaDePagamento(int id) async => null;
  @override
  Future<FormaDePagamento> criarFormaDePagamento(FormaDePagamento f) => throw UnimplementedError();
  @override
  Future<FormaDePagamento> atualizarFormaDePagamento(FormaDePagamento f) => throw UnimplementedError();
}

const mobile = Size(400, 800); // 800 < breakpoint 820 tambem seria mobile
const desktop = Size(1280, 900);

void tela(WidgetTester t, Size s) {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

/// Registra blocs reais (repos fake) em [sl]; devolve os fakes e os blocs.
({RepoCupomFake cupom, RepoPromocaoFake promocao, CupomBloc cupomBloc, PromocaoBloc promocaoBloc}) registrar() {
  final rc = RepoCupomFake(), rp = RepoPromocaoFake();
  final cb = CupomBloc(
    RecuperarCupom(repository: rc),
    CriarCupom(repository: rc),
    AtualizarCupom(repository: rc),
  );
  final pb = PromocaoBloc(
    RecuperarPromocao(repository: rp),
    CriarPromocao(repository: rp),
    AtualizarPromocao(repository: rp),
    RecuperarFormasDePagamento(repository: RepoFormasFake()),
  );
  sl.registerFactory<CupomBloc>(() => cb);
  sl.registerFactory<PromocaoBloc>(() => pb);
  sl.registerFactory<FormasDePagamentoBloc>(
    () => FormasDePagamentoBloc(RecuperarFormasDePagamento(repository: RepoFormasFake())),
  );
  addTearDown(() async => await sl.reset());
  return (cupom: rc, promocao: rp, cupomBloc: cb, promocaoBloc: pb);
}

/// App com botao "abrir" que usa FormPromocionalLayout.abrir; [resultado]
/// recebe o valor devolvido ao fechar.
Widget app({
  required String rota,
  required WidgetBuilder pagina,
  required List<bool?> resultado,
  bool fab = false,
}) =>
    MaterialApp(
      theme: SivTheme.tema,
      onGenerateRoute: (s) => s.name == rota
          ? MaterialPageRoute<bool>(builder: pagina, settings: s)
          : MaterialPageRoute<void>(
              builder: (c) => Scaffold(
                body: Center(
                  child: Builder(
                    builder: (c) => TextButton(
                      onPressed: () async => resultado.add(
                        await FormPromocionalLayout.abrir(c, rota: rota, arguments: const {}, pagina: pagina),
                      ),
                      child: const Text('abrir'),
                    ),
                  ),
                ),
              ),
            ),
    );

Future<void> abrir(WidgetTester t) async {
  await t.tap(find.text('abrir'));
  await t.pumpAndSettle();
}
