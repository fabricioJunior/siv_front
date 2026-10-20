import 'dart:typed_data';

import 'package:comercial/data.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements IEcommerceBannersRepository {
  List<EcommerceBanner> banners;
  final List<String> chamadas = [];

  _RepositorioFake(this.banners);

  @override
  Future<List<EcommerceBanner>> recuperarBanners(int ecommerceId) async => banners;

  @override
  Future<EcommerceBanner> criarBanner(
    int ecommerceId, {
    required Uint8List bytes,
    required String nomeArquivo,
    required EcommerceBannerDispositivo dispositivo,
    void Function(int enviado, int total)? onProgresso,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> atualizarBanner(
    int ecommerceId,
    int id, {
    int? ordem,
    bool? ativo,
    EcommerceBannerLink? link,
    bool limparLink = false,
  }) async {
    chamadas.add(
      'atualizar($id, ordem=$ordem, ativo=$ativo, '
      'link=${link?.rotulo}, limparLink=$limparLink)',
    );
    if (falhar) throw Exception('falhou');
  }

  bool falhar = false;

  @override
  Future<void> excluirBanner(int ecommerceId, int id) => throw UnimplementedError();
}

void main() {
  test('EcommerceBannerMoveu troca ordem com o vizinho de cima', () async {
    final repo = _RepositorioFake([
      EcommerceBanner(
        id: 1,
        ecommerceId: 9,
        type: EcommerceBannerTipo.imagem,
        dispositivo: EcommerceBannerDispositivo.desktop,
        url: 'a',
        ordem: 1,
        ativo: true,
      ),
      EcommerceBanner(
        id: 2,
        ecommerceId: 9,
        type: EcommerceBannerTipo.imagem,
        dispositivo: EcommerceBannerDispositivo.desktop,
        url: 'b',
        ordem: 2,
        ativo: true,
      ),
    ]);
    final bloc = EcommerceBannersBloc(
      RecuperarBannersEcommerce(repository: repo),
      CriarBannerEcommerce(repository: repo),
      AtualizarBannerEcommerce(repository: repo),
      ExcluirBannerEcommerce(repository: repo),
    );

    bloc.add(const EcommerceBannersIniciou(ecommerceId: 9));
    await bloc.stream.firstWhere((s) => s.step == EcommerceBannersStep.carregado);

    bloc.add(const EcommerceBannerMoveu(id: 2, paraCima: true));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.banners.map((b) => b.id).toList(), [2, 1]);
    expect(bloc.state.banners.firstWhere((b) => b.id == 2).ordem, 1);
    expect(bloc.state.banners.firstWhere((b) => b.id == 1).ordem, 2);
    expect(repo.chamadas, [
      'atualizar(2, ordem=1, ativo=null, link=null, limparLink=false)',
      'atualizar(1, ordem=2, ativo=null, link=null, limparLink=false)',
    ]);

    await bloc.close();
  });

  group('EcommerceBannerLinkAlterou', () {
    _RepositorioFake repoComUmBanner() => _RepositorioFake([
          const EcommerceBanner(
            id: 1,
            ecommerceId: 9,
            type: EcommerceBannerTipo.imagem,
            dispositivo: EcommerceBannerDispositivo.desktop,
            url: 'a',
            ordem: 1,
            ativo: true,
            link: EcommerceBannerLink.endereco('/antigo'),
          ),
        ]);

    Future<EcommerceBannersBloc> blocCarregado(_RepositorioFake repo) async {
      final bloc = EcommerceBannersBloc(
        RecuperarBannersEcommerce(repository: repo),
        CriarBannerEcommerce(repository: repo),
        AtualizarBannerEcommerce(repository: repo),
        ExcluirBannerEcommerce(repository: repo),
      );
      bloc.add(const EcommerceBannersIniciou(ecommerceId: 9));
      await bloc.stream.firstWhere((s) => s.step == EcommerceBannersStep.carregado);
      return bloc;
    }

    test('salva link de lista e atualiza o banner local', () async {
      final repo = repoComUmBanner();
      final bloc = await blocCarregado(repo);

      bloc.add(
        const EcommerceBannerLinkAlterou(
          id: 1,
          link: EcommerceBannerLink.lista(listaId: 7, listaNome: 'Verão'),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.banners.first.link?.listaId, 7);
      expect(repo.chamadas, [
        'atualizar(1, ordem=null, ativo=null, link=Verão, limparLink=false)',
      ]);

      await bloc.close();
    });

    test('link null limpa o destino', () async {
      final repo = repoComUmBanner();
      final bloc = await blocCarregado(repo);

      bloc.add(const EcommerceBannerLinkAlterou(id: 1));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.banners.first.link, isNull);
      expect(repo.chamadas, [
        'atualizar(1, ordem=null, ativo=null, link=null, limparLink=true)',
      ]);

      await bloc.close();
    });

    test('falha no PUT volta o link anterior e avisa', () async {
      final repo = repoComUmBanner();
      final bloc = await blocCarregado(repo);
      repo.falhar = true;

      bloc.add(
        const EcommerceBannerLinkAlterou(
          id: 1,
          link: EcommerceBannerLink.endereco('/novo'),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.banners.first.link?.url, '/antigo');
      expect(bloc.state.erro, isNotNull);

      await bloc.close();
    });
  });
}
