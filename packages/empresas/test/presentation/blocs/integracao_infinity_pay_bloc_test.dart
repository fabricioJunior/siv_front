import 'package:empresas/domain/entities/integracao_infinity_pay.dart';
import 'package:empresas/presentation/blocs/integracao_infinity_pay_bloc/integracao_infinity_pay_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../doubles/infinity_pay_fakes.dart';

Future<(IntegracaoInfinityPayBloc, ServidorParametros)> _bloc({
  Map<String, String> over = const {},
  Set<String> falham = const {},
  String urlBase = 'https://api.loja.com',
}) async {
  final srv = ServidorParametros({
    ...parametrosBase(),
    ...over,
  }, falham: falham);
  final b = IntegracaoInfinityPayBloc(
    FakeRecuperarParametros(srv),
    FakeAtualizarParametros(srv),
    urlBase,
  );
  b.add(IntegracaoInfinityPayIniciou(1));
  await b.stream.firstWhere((s) => s.etapa == EtapaInfinityPay.pronto);
  return (b, srv);
}

Future<void> _alterar(
  IntegracaoInfinityPayBloc b,
  CampoInfinityPay c,
  String v,
) async {
  b.add(IntegracaoInfinityPayAlterou(c, v));
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('normaliza handle', () async {
    final (b, _) = await _bloc();
    await _alterar(b, CampoInfinityPay.handle, r'$valedoceara');
    expect(b.state.editando.handle, 'valedoceara');
    await _alterar(b, CampoInfinityPay.handle, ' vale doceara ');
    expect(b.state.editando.handle, 'valedoceara');
  });

  test('ligar sem handle bloqueia salvar', () async {
    final (b, srv) = await _bloc();
    await _alterar(b, CampoInfinityPay.habilitada, 'S');
    expect(
      b.state.erros[CampoInfinityPay.handle],
      'Obrigatório para ligar a integração.',
    );
    expect(b.state.podeSalvar, isFalse);
    b.add(IntegracaoInfinityPaySalvou());
    await Future<void>.delayed(Duration.zero);
    expect(srv.chamadas, isEmpty);
    await _alterar(b, CampoInfinityPay.handle, 'vale');
    expect(b.state.podeSalvar, isTrue);
    expect(b.state.status, StatusInfinityPay.ativa);
  });

  test('URL sem https gera erro', () async {
    final (b, _) = await _bloc();
    await _alterar(b, CampoInfinityPay.urlWebhook, 'http://x.com');
    expect(
      b.state.erros[CampoInfinityPay.urlWebhook],
      'Use um endereço completo começando com https://',
    );
    await _alterar(b, CampoInfinityPay.urlWebhook, 'https://x.com/a');
    expect(b.state.erros[CampoInfinityPay.urlWebhook], isNull);
  });

  test('reserva e parcelas fora da faixa', () async {
    final (b, _) = await _bloc();
    await _alterar(b, CampoInfinityPay.reservaMinutos, '121');
    expect(
      b.state.erros[CampoInfinityPay.reservaMinutos],
      'Entre 1 e 120 minutos.',
    );
    await _alterar(b, CampoInfinityPay.reservaMinutos, '');
    expect(b.state.erros[CampoInfinityPay.reservaMinutos], isNotNull);
    await _alterar(b, CampoInfinityPay.parcelasSemJuros, '13');
    expect(b.state.erros[CampoInfinityPay.parcelasSemJuros], 'Entre 0 e 12.');
    await _alterar(b, CampoInfinityPay.parcelasSemJuros, '');
    expect(b.state.erros[CampoInfinityPay.parcelasSemJuros], isNull);
  });

  test('webhook padrão usa urlBase sem duplicar /v1 nem barras', () async {
    expect(
      IntegracaoInfinityPayBloc.montarWebhookPadrao('https://api.x.com', 7),
      'https://api.x.com/v1/pagamentos-avulsos/webhook/infinitypay?empresaId=7',
    );
    expect(
      IntegracaoInfinityPayBloc.montarWebhookPadrao('https://api.x.com/v1/', 7),
      'https://api.x.com/v1/pagamentos-avulsos/webhook/infinitypay?empresaId=7',
    );
    final (b, _) = await _bloc(urlBase: 'https://api.x.com/');
    b.add(IntegracaoInfinityPayUsouWebhookPadrao());
    await Future<void>.delayed(Duration.zero);
    expect(
      b.state.editando.urlWebhook,
      'https://api.x.com/v1/pagamentos-avulsos/webhook/infinitypay?empresaId=1',
    );
  });

  test('usar site da empresa copia URL_SITE_EMPRESA', () async {
    final (b, _) = await _bloc();
    b.add(IntegracaoInfinityPayUsouSiteEmpresa());
    await Future<void>.delayed(Duration.zero);
    expect(b.state.editando.urlRedirect, 'https://loja.com.br');
  });

  test('sujos conta só o que mudou e descartar restaura', () async {
    final (b, _) = await _bloc();
    expect(b.state.sujos, isEmpty);
    await _alterar(b, CampoInfinityPay.emailEstorno, 'a@b.com');
    await _alterar(b, CampoInfinityPay.reservaMinutos, '9');
    expect(b.state.sujos, {
      CampoInfinityPay.emailEstorno,
      CampoInfinityPay.reservaMinutos,
    });
    await _alterar(b, CampoInfinityPay.reservaMinutos, '5');
    expect(b.state.sujos, {CampoInfinityPay.emailEstorno});
    b.add(IntegracaoInfinityPayDescartou());
    await Future<void>.delayed(Duration.zero);
    expect(b.state.editando, b.state.salvo);
    expect(b.state.sujos, isEmpty);
  });

  test('salva um PUT por parâmetro alterado', () async {
    final (b, srv) = await _bloc();
    await _alterar(b, CampoInfinityPay.habilitada, 'S');
    await _alterar(b, CampoInfinityPay.handle, 'vale');
    b.add(IntegracaoInfinityPaySalvou());
    await b.stream.firstWhere((s) => s.salvou);
    expect(srv.chamadas.length, 2);
    expect(srv.valores['INTEGRACAO_INFINITY_PAY_API_HANDLE'], 'vale');
    expect(srv.valores['INTEGRACAO_INFINITY_PAY_HABILITADA'], 'S');
    expect(b.state.sujos, isEmpty);
  });

  test('falha parcial: mantém sucessos e marca campos que falharam', () async {
    final (b, srv) = await _bloc(falham: {'EMAIL_FINANCEIRO_ESTORNO'});
    await _alterar(b, CampoInfinityPay.handle, 'vale');
    await _alterar(b, CampoInfinityPay.emailEstorno, 'a@b.com');
    b.add(IntegracaoInfinityPaySalvou());
    await b.stream.firstWhere(
      (s) => s.etapa == EtapaInfinityPay.pronto && s.errosServidor.isNotEmpty,
    );
    expect(srv.valores['INTEGRACAO_INFINITY_PAY_API_HANDLE'], 'vale');
    expect(b.state.salvo.handle, 'vale');
    expect(b.state.salvou, isFalse);
    expect(b.state.errosServidor.keys, [CampoInfinityPay.emailEstorno]);
    expect(b.state.erros[CampoInfinityPay.emailEstorno], contains('Recusado'));
    expect(b.state.editando.emailEstorno, 'a@b.com');
    expect(b.state.sujos, {CampoInfinityPay.emailEstorno});
    // editar o campo limpa a mensagem do servidor
    await _alterar(b, CampoInfinityPay.emailEstorno, 'c@d.com');
    expect(b.state.errosServidor, isEmpty);
  });

  group('API Key', () {
    const mascarada = 'inchk_••••ab12';

    test('mascarada carregada não é dirty nem enviada', () async {
      final (b, srv) = await _bloc(
        over: {'INTEGRACAO_INFINITY_PAY_API_KEY': mascarada},
      );
      expect(b.state.editando.apiKey, mascarada);
      expect(b.state.sujos, isEmpty);
      expect(b.state.apiKeyPresente, isTrue);
      await _alterar(b, CampoInfinityPay.emailEstorno, 'a@b.com');
      b.add(IntegracaoInfinityPaySalvou());
      await b.stream.firstWhere((s) => s.salvou);
      expect(srv.chamadas, [
        ['EMAIL_FINANCEIRO_ESTORNO'],
      ]);
      expect(srv.valores['INTEGRACAO_INFINITY_PAY_API_KEY'], mascarada);
    });

    test('digitada entra nos alterados; sem prefixo inchk_ é erro', () async {
      final (b, _) = await _bloc();
      expect(b.state.apiKeyPresente, isFalse);
      await _alterar(b, CampoInfinityPay.apiKey, 'abc');
      expect(b.state.erros[CampoInfinityPay.apiKey], isNotNull);
      await _alterar(b, CampoInfinityPay.apiKey, 'inchk_123');
      expect(b.state.erros[CampoInfinityPay.apiKey], isNull);
      expect(b.state.sujos, {CampoInfinityPay.apiKey});
    });

    test('limpar explicitamente envia vazio', () async {
      final (b, srv) = await _bloc(
        over: {'INTEGRACAO_INFINITY_PAY_API_KEY': mascarada},
      );
      await _alterar(b, CampoInfinityPay.apiKey, '');
      expect(b.state.sujos, {CampoInfinityPay.apiKey});
      b.add(IntegracaoInfinityPaySalvou());
      await b.stream.firstWhere((s) => s.salvou);
      expect(srv.valores['INTEGRACAO_INFINITY_PAY_API_KEY'], '');
    });
  });
}
