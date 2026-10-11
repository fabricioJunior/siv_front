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

void main() {
  final salvar = _FakeSalvar();

  blocTest<ConfiguracaoFreteBloc, ConfiguracaoFreteState>(
    'salvar envia a lista marcada',
    build: () => ConfiguracaoFreteBloc(_FakeRecuperar(), _FakeListar(), salvar),
    act: (bloc) => bloc.add(ConfiguracaoFreteSalvar(['Correios', 'Jadlog'])),
    expect: () => [
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.salvando),
      isA<ConfiguracaoFreteState>()
          .having((s) => s.step, 'step', ConfiguracaoFreteStep.salvo),
    ],
    verify: (_) => expect(salvar.enviado, ['Correios', 'Jadlog']),
  );
}
