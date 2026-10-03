import 'package:empresas/domain/entities/integracao_meta.dart';

class IntegracaoMetaDto {
  static IntegracaoMeta fromJson(Map<String, dynamic> json) {
    int i(String k, [int d = 0]) => (json[k] as num?)?.toInt() ?? d;
    String s(String k) => json[k] as String? ?? '';
    bool b(String k) => json[k] as bool? ?? false;
    List<String> l(String k) =>
        (json[k] as List?)?.map((e) => e.toString()).toList() ?? const [];

    return IntegracaoMeta(
      empresaId: i('empresaId'),
      versaoGraphApi: s('versaoGraphApi'),
      graphApiUrl: s('graphApiUrl'),
      businessId: s('businessId'),
      catalogoId: s('catalogoId'),
      pixelId: s('pixelId'),
      ecommerceId: i('ecommerceId'),
      urlSite: s('urlSite'),
      marcaPadrao: s('marcaPadrao'),
      moeda: s('moeda'),
      accessTokenConfigurado: b('accessTokenConfigurado'),
      capiAccessTokenProprioConfigurado: b('capiAccessTokenProprioConfigurado'),
      capiHabilitada: b('capiHabilitada'),
      capiCodigoTeste: s('capiCodigoTeste'),
      capiMaxTentativas: i('capiMaxTentativas'),
      syncAutoHabilitada: b('syncAutoHabilitada'),
      syncIntervaloMinutos: i('syncIntervaloMinutos'),
      syncTamanhoLote: i('syncTamanhoLote'),
      validarImagens: b('validarImagens'),
      timeoutMs: i('timeoutMs'),
      maxTentativasApi: i('maxTentativasApi'),
      pendenciasCatalogo: l('pendenciasCatalogo'),
      pendenciasConversoes: l('pendenciasConversoes'),
    );
  }

  static IntegracaoMetaTeste testeFromJson(Map<String, dynamic> json) {
    IntegracaoMetaTesteItem item(Object? raw) {
      final m = raw as Map<String, dynamic>? ?? const {};
      return IntegracaoMetaTesteItem(
        ok: m['ok'] as bool? ?? false,
        mensagem: m['mensagem'] as String? ?? '',
        nome: m['nome'] as String?,
        detalhe: m['detalhe']?.toString(),
      );
    }

    return IntegracaoMetaTeste(
      catalogo: item(json['catalogo']),
      pixel: item(json['pixel']),
    );
  }

  /// Token vazio nunca é enviado (servidor manteria o atual de qualquer forma).
  static Map<String, dynamic> alteracoesToJson(IntegracaoMetaAlteracoes a) {
    final token = a.accessToken;
    final capiToken = a.capiAccessToken;
    return {
      if (a.versaoGraphApi != null) 'versaoGraphApi': a.versaoGraphApi,
      if (a.graphApiUrl != null) 'graphApiUrl': a.graphApiUrl,
      if (token != null && token.isNotEmpty) 'accessToken': token,
      if (a.removerAccessToken) 'removerAccessToken': true,
      if (capiToken != null && capiToken.isNotEmpty)
        'capiAccessToken': capiToken,
      if (a.removerCapiAccessToken) 'removerCapiAccessToken': true,
      if (a.businessId != null) 'businessId': a.businessId,
      if (a.catalogoId != null) 'catalogoId': a.catalogoId,
      if (a.pixelId != null) 'pixelId': a.pixelId,
      if (a.ecommerceId != null) 'ecommerceId': a.ecommerceId,
      if (a.urlSite != null) 'urlSite': a.urlSite,
      if (a.marcaPadrao != null) 'marcaPadrao': a.marcaPadrao,
      if (a.moeda != null) 'moeda': a.moeda,
      if (a.capiHabilitada != null) 'capiHabilitada': a.capiHabilitada,
      if (a.capiCodigoTeste != null) 'capiCodigoTeste': a.capiCodigoTeste,
      if (a.capiMaxTentativas != null)
        'capiMaxTentativas': a.capiMaxTentativas,
      if (a.syncAutoHabilitada != null)
        'syncAutoHabilitada': a.syncAutoHabilitada,
      if (a.syncIntervaloMinutos != null)
        'syncIntervaloMinutos': a.syncIntervaloMinutos,
      if (a.syncTamanhoLote != null) 'syncTamanhoLote': a.syncTamanhoLote,
      if (a.validarImagens != null) 'validarImagens': a.validarImagens,
      if (a.timeoutMs != null) 'timeoutMs': a.timeoutMs,
      if (a.maxTentativasApi != null) 'maxTentativasApi': a.maxTentativasApi,
    };
  }
}
