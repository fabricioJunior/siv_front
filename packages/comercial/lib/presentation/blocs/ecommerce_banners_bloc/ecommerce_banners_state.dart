part of 'ecommerce_banners_bloc.dart';

enum EcommerceBannersStep { inicial, carregando, carregado, falha }

class EcommerceBannersState extends Equatable {
  final EcommerceBannersStep step;
  final int? ecommerceId;
  final List<EcommerceBanner> banners;
  final bool enviando;
  final double? progressoEnvio;
  final String? erro;

  const EcommerceBannersState({
    this.step = EcommerceBannersStep.inicial,
    this.ecommerceId,
    this.banners = const [],
    this.enviando = false,
    this.progressoEnvio,
    this.erro,
  });

  EcommerceBannersState copyWith({
    EcommerceBannersStep? step,
    int? ecommerceId,
    List<EcommerceBanner>? banners,
    bool? enviando,
    double? progressoEnvio,
    String? erro,
  }) {
    return EcommerceBannersState(
      step: step ?? this.step,
      ecommerceId: ecommerceId ?? this.ecommerceId,
      banners: banners ?? this.banners,
      enviando: enviando ?? this.enviando,
      progressoEnvio: progressoEnvio,
      erro: erro,
    );
  }

  @override
  List<Object?> get props =>
      [step, ecommerceId, banners, enviando, progressoEnvio, erro];
}
