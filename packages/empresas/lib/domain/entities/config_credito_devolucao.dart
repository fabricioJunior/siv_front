import 'package:core/equals.dart';

/// Validade padrão dos créditos novos (null = sem validade) e aviso na venda.
class ConfigCreditoDevolucao extends Equatable {
  final int? validadeDiasPadrao;
  final int avisoDiasAntes;

  const ConfigCreditoDevolucao({
    this.validadeDiasPadrao,
    this.avisoDiasAntes = 7,
  });

  @override
  List<Object?> get props => [validadeDiasPadrao, avisoDiasAntes];
}
