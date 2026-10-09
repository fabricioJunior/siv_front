part of 'ecommerce_vitrine_bloc.dart';

enum EcommerceVitrineStep { inicial, carregando, pronto, falha }

class EcommerceVitrineState extends Equatable {
  final EcommerceVitrineStep step;
  final int? ecommerceId;
  final EcommerceVitrine vitrine;
  final List<ListaPersonalizadaResumo> listas;
  final List<ListaGrupo> grupos;
  final VitrineLocal? salvando;
  final VitrineLocal? ultimoSalvo;
  final String? erro;

  const EcommerceVitrineState({
    this.step = EcommerceVitrineStep.inicial,
    this.ecommerceId,
    this.vitrine = const EcommerceVitrine(),
    this.listas = const [],
    this.grupos = const [],
    this.salvando,
    this.ultimoSalvo,
    this.erro,
  });

  EcommerceVitrineState copyWith({
    EcommerceVitrineStep? step,
    int? ecommerceId,
    EcommerceVitrine? vitrine,
    List<ListaPersonalizadaResumo>? listas,
    List<ListaGrupo>? grupos,
    VitrineLocal? salvando,
    bool limparSalvando = false,
    VitrineLocal? ultimoSalvo,
    String? erro,
  }) =>
      EcommerceVitrineState(
        step: step ?? this.step,
        ecommerceId: ecommerceId ?? this.ecommerceId,
        vitrine: vitrine ?? this.vitrine,
        listas: listas ?? this.listas,
        grupos: grupos ?? this.grupos,
        salvando: limparSalvando ? null : (salvando ?? this.salvando),
        ultimoSalvo: ultimoSalvo,
        erro: erro,
      );

  @override
  List<Object?> get props =>
      [step, ecommerceId, vitrine, listas, grupos, salvando, ultimoSalvo, erro];
}
