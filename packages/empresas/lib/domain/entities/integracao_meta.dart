import 'package:core/equals.dart';

class IntegracaoMeta extends Equatable {
  final int empresaId;
  final String versaoGraphApi;
  final String graphApiUrl;
  final String businessId;
  final String catalogoId;
  final String pixelId;
  final int ecommerceId;
  final String urlSite;
  final String marcaPadrao;
  final String moeda;
  final bool accessTokenConfigurado;
  final bool capiAccessTokenProprioConfigurado;
  final bool capiHabilitada;
  final String capiCodigoTeste;
  final int capiMaxTentativas;
  final bool syncAutoHabilitada;
  final int syncIntervaloMinutos;
  final int syncTamanhoLote;
  final bool validarImagens;
  final int timeoutMs;
  final int maxTentativasApi;
  final List<String> pendenciasCatalogo;
  final List<String> pendenciasConversoes;

  const IntegracaoMeta({
    required this.empresaId,
    required this.versaoGraphApi,
    required this.graphApiUrl,
    required this.businessId,
    required this.catalogoId,
    required this.pixelId,
    required this.ecommerceId,
    required this.urlSite,
    required this.marcaPadrao,
    required this.moeda,
    required this.accessTokenConfigurado,
    required this.capiAccessTokenProprioConfigurado,
    required this.capiHabilitada,
    required this.capiCodigoTeste,
    required this.capiMaxTentativas,
    required this.syncAutoHabilitada,
    required this.syncIntervaloMinutos,
    required this.syncTamanhoLote,
    required this.validarImagens,
    required this.timeoutMs,
    required this.maxTentativasApi,
    required this.pendenciasCatalogo,
    required this.pendenciasConversoes,
  });

  @override
  List<Object?> get props => [
        empresaId,
        versaoGraphApi,
        graphApiUrl,
        businessId,
        catalogoId,
        pixelId,
        ecommerceId,
        urlSite,
        marcaPadrao,
        moeda,
        accessTokenConfigurado,
        capiAccessTokenProprioConfigurado,
        capiHabilitada,
        capiCodigoTeste,
        capiMaxTentativas,
        syncAutoHabilitada,
        syncIntervaloMinutos,
        syncTamanhoLote,
        validarImagens,
        timeoutMs,
        maxTentativasApi,
        pendenciasCatalogo,
        pendenciasConversoes,
      ];
}

/// Campos nulos não são enviados. Token nulo/vazio mantém o atual no servidor.
class IntegracaoMetaAlteracoes {
  final String? versaoGraphApi;
  final String? graphApiUrl;
  final String? accessToken;
  final bool removerAccessToken;
  final String? capiAccessToken;
  final bool removerCapiAccessToken;
  final String? businessId;
  final String? catalogoId;
  final String? pixelId;
  final int? ecommerceId;
  final String? urlSite;
  final String? marcaPadrao;
  final String? moeda;
  final bool? capiHabilitada;
  final String? capiCodigoTeste;
  final int? capiMaxTentativas;
  final bool? syncAutoHabilitada;
  final int? syncIntervaloMinutos;
  final int? syncTamanhoLote;
  final bool? validarImagens;
  final int? timeoutMs;
  final int? maxTentativasApi;

  const IntegracaoMetaAlteracoes({
    this.versaoGraphApi,
    this.graphApiUrl,
    this.accessToken,
    this.removerAccessToken = false,
    this.capiAccessToken,
    this.removerCapiAccessToken = false,
    this.businessId,
    this.catalogoId,
    this.pixelId,
    this.ecommerceId,
    this.urlSite,
    this.marcaPadrao,
    this.moeda,
    this.capiHabilitada,
    this.capiCodigoTeste,
    this.capiMaxTentativas,
    this.syncAutoHabilitada,
    this.syncIntervaloMinutos,
    this.syncTamanhoLote,
    this.validarImagens,
    this.timeoutMs,
    this.maxTentativasApi,
  });
}

class IntegracaoMetaTesteItem extends Equatable {
  final bool ok;
  final String mensagem;
  final String? nome;
  final String? detalhe;

  const IntegracaoMetaTesteItem({
    required this.ok,
    required this.mensagem,
    this.nome,
    this.detalhe,
  });

  @override
  List<Object?> get props => [ok, mensagem, nome, detalhe];
}

class IntegracaoMetaTeste extends Equatable {
  final IntegracaoMetaTesteItem catalogo;
  final IntegracaoMetaTesteItem pixel;

  const IntegracaoMetaTeste({required this.catalogo, required this.pixel});

  @override
  List<Object?> get props => [catalogo, pixel];
}
