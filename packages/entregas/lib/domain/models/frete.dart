import 'package:core/equals.dart';

abstract class ConfiguracaoFrete implements Equatable {
  String? get provider;
  bool get ativo;

  /// Nomes permitidos. Vazio = todas.
  List<String> get transportadoras;
}
