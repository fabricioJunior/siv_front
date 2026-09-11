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
  Future<void> atualizarBanner(int ecommerceId, int id, {int? ordem, bool? ativo}) async {
    chamadas.add('atualizar($id, ordem=$ordem, ativo=$ativo)');
  }

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
    expect(repo.chamadas, ['atualizar(2, ordem=1, ativo=null)', 'atualizar(1, ordem=2, ativo=null)']);

    await bloc.close();
  });
}
