part of 'ecommerce_banners_bloc.dart';

abstract class EcommerceBannersEvent extends Equatable {
  const EcommerceBannersEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceBannersIniciou extends EcommerceBannersEvent {
  final int ecommerceId;

  const EcommerceBannersIniciou({required this.ecommerceId});

  @override
  List<Object?> get props => [ecommerceId];
}

class EcommerceBannerAdicionou extends EcommerceBannersEvent {
  final Uint8List bytes;
  final String nomeArquivo;
  final EcommerceBannerDispositivo dispositivo;

  const EcommerceBannerAdicionou({
    required this.bytes,
    required this.nomeArquivo,
    required this.dispositivo,
  });

  @override
  List<Object?> get props => [nomeArquivo, bytes.length, dispositivo];
}

class EcommerceBannerAtivoAlterou extends EcommerceBannersEvent {
  final int id;
  final bool ativo;

  const EcommerceBannerAtivoAlterou({required this.id, required this.ativo});

  @override
  List<Object?> get props => [id, ativo];
}

class EcommerceBannerExcluiu extends EcommerceBannersEvent {
  final int id;

  const EcommerceBannerExcluiu({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Troca o `ordem` deste banner com o vizinho (acima ou abaixo) -- reorder
/// simples de posição única, um PUT por banner que de fato mudou de lugar.
class EcommerceBannerMoveu extends EcommerceBannersEvent {
  final int id;
  final bool paraCima;

  const EcommerceBannerMoveu({required this.id, required this.paraCima});

  @override
  List<Object?> get props => [id, paraCima];
}
