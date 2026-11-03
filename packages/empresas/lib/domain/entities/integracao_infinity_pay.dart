import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';

enum CampoInfinityPay {
  habilitada('INTEGRACAO_INFINITY_PAY_HABILITADA'),
  handle('INTEGRACAO_INFINITY_PAY_API_HANDLE'),
  urlWebhook('INTEGRACAO_INFINITY_PAY_URL_WEBHOOK'),
  urlRedirect('INTEGRACAO_INFINITY_PAY_URL_REDIRECT'),
  emailEstorno('EMAIL_FINANCEIRO_ESTORNO'),
  apiKey('INTEGRACAO_INFINITY_PAY_API_KEY'),
  parcelasSemJuros('INTEGRACAO_INFINITY_PAY_PARCELAS_SEM_JUROS'),
  pixHabilitado('INTEGRACAO_INFINITY_PAY_PIX_HABILITADO');

  final String chave;
  const CampoInfinityPay(this.chave);
}

class IntegracaoInfinityPay extends Equatable {
  final bool habilitada;
  final String handle;
  final String urlWebhook;
  final String urlRedirect;
  final String emailEstorno;

  /// Mascarada quando vem do servidor (ex. `inchk_••••ab12`).
  final String apiKey;
  final int? parcelasSemJuros;
  final bool pixHabilitado;

  // Somente leitura.
  final String urlSiteEmpresa;
  final bool mercadoPagoHabilitado;
  final bool openPixHabilitado;

  const IntegracaoInfinityPay({
    this.habilitada = false,
    this.handle = '',
    this.urlWebhook = '',
    this.urlRedirect = '',
    this.emailEstorno = '',
    this.apiKey = '',
    this.parcelasSemJuros,
    this.pixHabilitado = true,
    this.urlSiteEmpresa = '',
    this.mercadoPagoHabilitado = false,
    this.openPixHabilitado = false,
  });

  factory IntegracaoInfinityPay.fromParametros(List<EmpresaParametro> lista) {
    String texto(String chave) {
      for (final p in lista) {
        if (p.chave != chave) continue;
        return (p.valorTexto ?? (p.valorBooleano == true ? 'S' : 'N')).trim();
      }
      return '';
    }

    bool sim(String chave, {bool padrao = false}) {
      final v = texto(chave).toUpperCase();
      if (v.isEmpty) return padrao;
      return v == 'S' || v == 'TRUE' || v == '1';
    }

    return IntegracaoInfinityPay(
      habilitada: sim(CampoInfinityPay.habilitada.chave),
      handle: texto(CampoInfinityPay.handle.chave),
      urlWebhook: texto(CampoInfinityPay.urlWebhook.chave),
      urlRedirect: texto(CampoInfinityPay.urlRedirect.chave),
      emailEstorno: texto(CampoInfinityPay.emailEstorno.chave),
      apiKey: texto(CampoInfinityPay.apiKey.chave),
      parcelasSemJuros: int.tryParse(
        texto(CampoInfinityPay.parcelasSemJuros.chave),
      ),
      pixHabilitado: sim(CampoInfinityPay.pixHabilitado.chave, padrao: true),
      urlSiteEmpresa: texto('URL_SITE_EMPRESA'),
      mercadoPagoHabilitado: sim('INTEGRACAO_MERCADO_PAGO_HABILITADA'),
      openPixHabilitado: sim('INTEGRACAO_OPEN_PIX_HABILITADA'),
    );
  }

  /// chave do parâmetro -> valor a gravar.
  Map<String, String> toParametros() => {
    for (final c in CampoInfinityPay.values) c.chave: valorDe(c),
  };

  String valorDe(CampoInfinityPay c) => switch (c) {
    CampoInfinityPay.habilitada => habilitada ? 'S' : 'N',
    CampoInfinityPay.handle => handle,
    CampoInfinityPay.urlWebhook => urlWebhook,
    CampoInfinityPay.urlRedirect => urlRedirect,
    CampoInfinityPay.emailEstorno => emailEstorno,
    CampoInfinityPay.apiKey => apiKey,
    CampoInfinityPay.parcelasSemJuros => '${parcelasSemJuros ?? ''}',
    CampoInfinityPay.pixHabilitado => pixHabilitado ? 'S' : 'N',
  };

  /// Aplica [valor] (texto cru da UI) ao campo. Handle: sem `$` inicial e sem espaços.
  IntegracaoInfinityPay comValor(CampoInfinityPay c, String valor) {
    final n = int.tryParse(valor.trim());
    return switch (c) {
      CampoInfinityPay.habilitada => _copia(habilitada: valor == 'S'),
      CampoInfinityPay.handle => _copia(
        handle: valor
            .replaceAll(RegExp(r'\s'), '')
            .replaceFirst(RegExp(r'^\$+'), ''),
      ),
      CampoInfinityPay.urlWebhook => _copia(urlWebhook: valor.trim()),
      CampoInfinityPay.urlRedirect => _copia(urlRedirect: valor.trim()),
      CampoInfinityPay.emailEstorno => _copia(emailEstorno: valor.trim()),
      CampoInfinityPay.apiKey => _copia(apiKey: valor.trim()),
      CampoInfinityPay.parcelasSemJuros => _copia(parcelasSemJuros: () => n),
      CampoInfinityPay.pixHabilitado => _copia(pixHabilitado: valor == 'S'),
    };
  }

  IntegracaoInfinityPay _copia({
    bool? habilitada,
    String? handle,
    String? urlWebhook,
    String? urlRedirect,
    String? emailEstorno,
    String? apiKey,
    int? Function()? parcelasSemJuros,
    bool? pixHabilitado,
  }) => IntegracaoInfinityPay(
    habilitada: habilitada ?? this.habilitada,
    handle: handle ?? this.handle,
    urlWebhook: urlWebhook ?? this.urlWebhook,
    urlRedirect: urlRedirect ?? this.urlRedirect,
    emailEstorno: emailEstorno ?? this.emailEstorno,
    apiKey: apiKey ?? this.apiKey,
    parcelasSemJuros: parcelasSemJuros != null
        ? parcelasSemJuros()
        : this.parcelasSemJuros,
    pixHabilitado: pixHabilitado ?? this.pixHabilitado,
    urlSiteEmpresa: urlSiteEmpresa,
    mercadoPagoHabilitado: mercadoPagoHabilitado,
    openPixHabilitado: openPixHabilitado,
  );

  bool get handleValido => RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(handle);

  @override
  List<Object?> get props => [
    habilitada,
    handle,
    urlWebhook,
    urlRedirect,
    emailEstorno,
    apiKey,
    parcelasSemJuros,
    pixHabilitado,
    urlSiteEmpresa,
    mercadoPagoHabilitado,
    openPixHabilitado,
  ];
}
