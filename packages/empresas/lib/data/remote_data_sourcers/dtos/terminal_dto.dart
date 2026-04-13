import 'package:empresas/domain/entities/terminal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terminal_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class TerminalDto implements Terminal {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final int? id;

  @override
  final int empresaId;

  @override
  final String nome;

  @override
  final bool? inativo;

  const TerminalDto({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.inativo,
  });

  factory TerminalDto.fromJson(Map<String, dynamic> json) =>
      _$TerminalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TerminalDtoToJson(this);

  @override
  List<Object?> get props => [
    criadoEm,
    atualizadoEm,
    id,
    empresaId,
    nome,
    inativo,
  ];

  @override
  bool? get stringify => true;
}
