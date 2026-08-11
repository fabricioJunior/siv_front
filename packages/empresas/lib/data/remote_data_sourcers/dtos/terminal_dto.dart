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

  @override
  final String tipo;

  const TerminalDto({
    required this.criadoEm,
    required this.atualizadoEm,
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.inativo,
    this.tipo = 'fisico',
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
    tipo,
  ];

  @override
  bool? get stringify => true;
}
