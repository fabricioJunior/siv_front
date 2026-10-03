import 'package:empresas/data/remote_data_sourcers/dtos/integracao_meta_dto.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson mapeia campos e pendências', () {
    final c = IntegracaoMetaDto.fromJson({
      'empresaId': 1,
      'versaoGraphApi': 'v21.0',
      'ecommerceId': 0,
      'accessTokenConfigurado': true,
      'syncIntervaloMinutos': 60,
      'pendenciasCatalogo': ['catalogoId'],
    });
    expect(c.empresaId, 1);
    expect(c.versaoGraphApi, 'v21.0');
    expect(c.accessTokenConfigurado, true);
    expect(c.capiHabilitada, false);
    expect(c.syncIntervaloMinutos, 60);
    expect(c.pendenciasCatalogo, ['catalogoId']);
    expect(c.pendenciasConversoes, isEmpty);
  });

  test('testeFromJson aceita detalhe numérico e nome nulo', () {
    final t = IntegracaoMetaDto.testeFromJson({
      'catalogo': {'ok': true, 'mensagem': 'ok', 'nome': 'Loja', 'detalhe': 12},
      'pixel': {'ok': false, 'mensagem': 'erro', 'nome': null},
    });
    expect(t.catalogo.detalhe, '12');
    expect(t.catalogo.nome, 'Loja');
    expect(t.pixel.ok, false);
    expect(t.pixel.nome, isNull);
  });

  test('alteracoesToJson nunca envia token vazio e só campos informados', () {
    final json = IntegracaoMetaDto.alteracoesToJson(
      const IntegracaoMetaAlteracoes(
        accessToken: '',
        capiAccessToken: 'abc',
        removerAccessToken: true,
        pixelId: '',
        capiMaxTentativas: 3,
      ),
    );
    expect(json, {
      'capiAccessToken': 'abc',
      'removerAccessToken': true,
      'pixelId': '',
      'capiMaxTentativas': 3,
    });
  });
}
