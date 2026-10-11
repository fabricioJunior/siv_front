import 'package:core/equals.dart';

abstract class ConfiguracaoFrete implements Equatable {
  String? get provider;
  bool get ativo;
  String? get clientId;

  /// true = homologação (sandbox).
  bool get sandbox;

  /// Já existe accessToken (OAuth concluído).
  bool get autorizado;

  /// Nomes permitidos. Vazio = todas.
  List<String> get transportadoras;
}
