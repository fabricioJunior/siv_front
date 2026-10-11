import 'package:core/equals.dart';
import 'package:entregas/domain/models/frete.dart';

class ConfiguracaoFreteDto extends Equatable implements ConfiguracaoFrete {
  @override
  final String? provider;
  @override
  final bool ativo;
  @override
  final List<String> transportadoras;

  const ConfiguracaoFreteDto({
    this.provider,
    required this.ativo,
    this.transportadoras = const [],
  });

  factory ConfiguracaoFreteDto.fromJson(Map<String, dynamic> json) {
    final config = json['configuracao'] as Map<String, dynamic>?;
    return ConfiguracaoFreteDto(
      provider: json['provider'] as String?,
      ativo: (json['ativo'] as bool?) ?? false,
      transportadoras:
          ((config?['transportadoras'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  @override
  List<Object?> get props => [provider, ativo, transportadoras];
}
