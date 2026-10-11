import 'package:core/bloc_test.dart';
import 'package:entregas/domain/models/frete.dart';
import 'package:entregas/presentation.dart';
import 'package:entregas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRecuperar extends Fake implements RecuperarConfiguracaoFrete {
  @override
  Future<ConfiguracaoFrete> call() => throw UnimplementedError();
}

class _FakeListar extends Fake implements ListarTransportadorasFrete {}

class _FakeSalvar extends Fake implements SalvarTransportadorasFrete {
  List<String>? enviado;

  @override
  Future<void> call({
    required bool ativo,
    required List<String> transportadoras,
  }) async =>
      enviado = transportadoras;
}

class _FakeIntegracao extends Fake implements SalvarIntegracaoFrete {
  static String? secret = 'x';
  static String? clientId;

  @override
  Future<void> call({
    required bool ativo,
    required bool sandbox,
    required String clientId,
    String? clientSecret,
  }) async {
    secret = clientSecret;
    _FakeIntegracao.clientId = clientId;
  }
}

class _FakeUrl extends Fake implements ObterUrlAutorizacaoFrete {
  @override
  Future<String> call() async => 'https://me/auth';
}

void main() {
  final salvar = _FakeSalvar();

  blocTest<ConfiguracaoFreteBloc, ConfiguracaoFreteState>(
    'salvar envia a lista marcada',
    build: () => ConfiguracaoFreteBloc(_FakeRecuperar(), _FakeListar(), salvar,
        _FakeIntegracao(), _FakeUrl()),
    act: (bloc) => bloc.add(ConfiguracaoFreteSalvar(['Correios', 'Jadlog'])),
    expect: () => [
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.salvando),
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.salvo),
    ],
    verify: (_) => expect(salvar.enviado, ['Correios', 'Jadlog']),
  );

  blocTest<ConfiguracaoFreteBloc, ConfiguracaoFreteState>(
    'salvar integração envia secret nulo quando vazio',
    build: () => ConfiguracaoFreteBloc(
        _FakeRecuperar(), _FakeListar(), salvar, _FakeIntegracao(), _FakeUrl()),
    act: (bloc) => bloc.add(ConfiguracaoFreteSalvarIntegracao(
        ativo: true, sandbox: true, clientId: ' abc ', clientSecret: ' ')),
    verify: (_) {
      expect(_FakeIntegracao.secret, isNull);
      expect(_FakeIntegracao.clientId, 'abc');
    },
    errors: () => [isA<UnimplementedError>()],
  );

  blocTest<ConfiguracaoFreteBloc, ConfiguracaoFreteState>(
    'autorizar obtém url',
    build: () => ConfiguracaoFreteBloc(
        _FakeRecuperar(), _FakeListar(), salvar, _FakeIntegracao(), _FakeUrl()),
    act: (bloc) => bloc.add(ConfiguracaoFreteAutorizar()),
    expect: () => [
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.autorizando),
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.urlPronta)
          .having((s) => s.urlAutorizacao, 'url', 'https://me/auth'),
    ],
  );
}
