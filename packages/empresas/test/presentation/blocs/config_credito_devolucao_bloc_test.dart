import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/models.dart';
import 'package:empresas/presentation/blocs/config_credito_devolucao_bloc/config_credito_devolucao_bloc.dart';
import 'package:empresas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRecuperarConfig implements RecuperarConfigCreditoDevolucao {
  Object? erro;
  int? empresaId;
  @override
  Future<ConfigCreditoDevolucao> call(int empresaId) async {
    this.empresaId = empresaId;
    if (erro != null) throw erro!;
    return const ConfigCreditoDevolucao(validadeDiasPadrao: 90);
  }
}

class FakeSalvarConfig implements SalvarConfigCreditoDevolucao {
  Object? erro;
  (int, ConfigCreditoDevolucao)? chamada;
  @override
  Future<ConfigCreditoDevolucao> call(
      int empresaId, ConfigCreditoDevolucao config) async {
    if (erro != null) throw erro!;
    chamada = (empresaId, config);
    return config;
  }
}

void main() {
  late FakeRecuperarConfig rec;
  late FakeSalvarConfig salvar;
  late ConfigCreditoDevolucaoBloc bloc;

  setUp(() {
    rec = FakeRecuperarConfig();
    salvar = FakeSalvarConfig();
    bloc = ConfigCreditoDevolucaoBloc(rec, salvar);
  });
  tearDown(() => bloc.close());

  test('carregar: pronto com a config da empresa', () async {
    bloc.add(ConfigCreditoDevolucaoCarregou(4));
    final s = await bloc.stream.first;
    expect(s.status, ConfigCreditoDevolucaoStatus.pronto);
    expect(s.config!.validadeDiasPadrao, 90);
    expect(rec.empresaId, 4);
  });

  test('carregar: erro de API mostra a mensagem da API', () async {
    rec.erro = HttpException('x', statusCode: 403, apiMessage: 'Sem acesso');
    bloc.add(ConfigCreditoDevolucaoCarregou(4));
    final s = await bloc.stream.first;
    expect(s.status, ConfigCreditoDevolucaoStatus.erro);
    expect(s.erro, 'Sem acesso');
  });

  test('salvar: salvando -> salvo, usa a empresa carregada', () async {
    bloc.add(ConfigCreditoDevolucaoCarregou(4));
    await bloc.stream.first;
    const nova =
        ConfigCreditoDevolucao(validadeDiasPadrao: null, avisoDiasAntes: 3);
    bloc.add(ConfigCreditoDevolucaoSalvou(nova));
    final estados = await bloc.stream.take(2).toList();
    expect(estados[0].status, ConfigCreditoDevolucaoStatus.salvando);
    expect(estados[1].status, ConfigCreditoDevolucaoStatus.salvo);
    expect(estados[1].config, nova);
    expect(salvar.chamada, (4, nova));
  });

  test('salvar: erro mantém a config anterior', () async {
    bloc.add(ConfigCreditoDevolucaoCarregou(4));
    await bloc.stream.first;
    salvar.erro = Exception('x');
    bloc.add(ConfigCreditoDevolucaoSalvou(const ConfigCreditoDevolucao()));
    final s = await bloc.stream
        .firstWhere((s) => s.status == ConfigCreditoDevolucaoStatus.erro);
    expect(s.config!.validadeDiasPadrao, 90);
    expect(s.erro, 'Falha ao salvar a configuração.');
  });
}
