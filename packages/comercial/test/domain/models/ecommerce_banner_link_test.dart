import 'package:comercial/data/remote/dtos/ecommerce_banner_dto.dart';
import 'package:comercial/domain/models/ecommerce_banner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarEnderecoDoBanner', () {
    test('recusa vazio', () {
      expect(validarEnderecoDoBanner(null), isNotNull);
      expect(validarEnderecoDoBanner(''), isNotNull);
      expect(validarEnderecoDoBanner('   '), isNotNull);
    });

    test('aceita http, https e caminho interno', () {
      expect(validarEnderecoDoBanner('https://site.com/x'), isNull);
      expect(validarEnderecoDoBanner('http://site.com'), isNull);
      expect(validarEnderecoDoBanner('/promocoes'), isNull);
      expect(validarEnderecoDoBanner('  /promocoes  '), isNull);
    });

    test('recusa endereço sem esquema nem barra', () {
      expect(validarEnderecoDoBanner('site.com'), isNotNull);
      expect(validarEnderecoDoBanner('www.site.com/x'), isNotNull);
      expect(validarEnderecoDoBanner('ftp://site.com'), isNotNull);
    });
  });

  group('EcommerceBannerDto.fromJson', () {
    Map<String, dynamic> base() => {
          'id': 7,
          'ecommerceId': 3,
          'type': 'imagem',
          'dispositivo': 'mobile',
          'url': 'https://cdn/x.png',
          'ordem': 2,
          'ativo': true,
        };

    test('API antiga sem os campos novos = banner sem link', () {
      final banner = EcommerceBannerDto.fromJson(base());
      expect(banner.link, isNull);
      expect(banner.id, 7);
      expect(banner.dispositivo, EcommerceBannerDispositivo.mobile);
    });

    test('linkTipo null explícito = sem link', () {
      final banner = EcommerceBannerDto.fromJson({
        ...base(),
        'linkTipo': null,
        'linkUrl': null,
        'listaId': null,
      });
      expect(banner.link, isNull);
    });

    test('link de url', () {
      final banner = EcommerceBannerDto.fromJson({
        ...base(),
        'linkTipo': 'url',
        'linkUrl': '/promocoes',
      });
      expect(banner.link?.tipo, EcommerceBannerLinkTipo.url);
      expect(banner.link?.url, '/promocoes');
      expect(banner.link?.rotulo, '/promocoes');
    });

    test('link de lista com nome', () {
      final banner = EcommerceBannerDto.fromJson({
        ...base(),
        'linkTipo': 'lista',
        'listaId': '42',
        'listaNome': 'Novidades',
      });
      expect(banner.link?.tipo, EcommerceBannerLinkTipo.lista);
      expect(banner.link?.listaId, 42);
      expect(banner.link?.rotulo, 'Novidades');
    });

    test('link de lista sem nome cai no id', () {
      final banner = EcommerceBannerDto.fromJson({
        ...base(),
        'linkTipo': 'lista',
        'listaId': 42,
      });
      expect(banner.link?.rotulo, 'Lista #42');
    });

    test('infere o tipo quando linkTipo não vem', () {
      expect(
        EcommerceBannerDto.fromJson({...base(), 'linkUrl': 'https://a'})
            .link
            ?.tipo,
        EcommerceBannerLinkTipo.url,
      );
      expect(
        EcommerceBannerDto.fromJson({...base(), 'listaId': 9}).link?.listaId,
        9,
      );
    });

    test('linkTipo url sem endereço = sem link', () {
      final banner = EcommerceBannerDto.fromJson({
        ...base(),
        'linkTipo': 'url',
        'linkUrl': '',
      });
      expect(banner.link, isNull);
    });
  });

  group('EcommerceBannerDto.linkParaJson', () {
    test('sem link e sem limpar não manda nada (PUT parcial)', () {
      expect(EcommerceBannerDto.linkParaJson(null), isEmpty);
    });

    test('limparLink manda linkTipo null', () {
      expect(
        EcommerceBannerDto.linkParaJson(null, limparLink: true),
        {'linkTipo': null},
      );
    });

    test('ida e volta: url', () {
      const link = EcommerceBannerLink.endereco('https://site.com/x');
      final json = EcommerceBannerDto.linkParaJson(link);
      expect(json, {'linkTipo': 'url', 'linkUrl': 'https://site.com/x'});
      final volta = EcommerceBannerDto.linkDeJson(json);
      expect(volta?.tipo, EcommerceBannerLinkTipo.url);
      expect(volta?.url, link.url);
    });

    test('ida e volta: lista (listaNome não é enviado)', () {
      const link = EcommerceBannerLink.lista(listaId: 5, listaNome: 'Verão');
      final json = EcommerceBannerDto.linkParaJson(link);
      expect(json, {'linkTipo': 'lista', 'listaId': 5});
      final volta = EcommerceBannerDto.linkDeJson(json);
      expect(volta?.tipo, EcommerceBannerLinkTipo.lista);
      expect(volta?.listaId, 5);
      expect(volta?.listaNome, isNull);
    });
  });

  group('EcommerceBanner.copyWith', () {
    const banner = EcommerceBanner(
      id: 1,
      ecommerceId: 1,
      type: EcommerceBannerTipo.imagem,
      dispositivo: EcommerceBannerDispositivo.desktop,
      url: 'https://cdn/x.png',
      ordem: 1,
      ativo: true,
      link: EcommerceBannerLink.endereco('/x'),
    );

    test('mexer em ordem/ativo preserva o link', () {
      expect(banner.copyWith(ordem: 3).link?.url, '/x');
      expect(banner.copyWith(ativo: false).link?.url, '/x');
    });

    test('limparLink remove o link', () {
      expect(banner.copyWith(limparLink: true).link, isNull);
    });

    test('troca o link', () {
      final trocado =
          banner.copyWith(link: const EcommerceBannerLink.lista(listaId: 2));
      expect(trocado.link?.listaId, 2);
    });
  });
}
