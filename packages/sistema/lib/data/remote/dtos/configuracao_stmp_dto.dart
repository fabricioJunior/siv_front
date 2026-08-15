import 'package:json_annotation/json_annotation.dart';
import 'package:sistema/domain/models/configuracao_stmp.dart';

part 'configuracao_stmp_dto.g.dart';

@JsonSerializable()
class ConfiguracaoSTMPDto implements ConfiguracaoSTMP {
  @override
  final int id;

  @override
  final String servidor;

  @override
  final int porta;

  @override
  final String usuario;

  @override
  final String senha;

  @override
  final RedefinirSenhaTemplateDto redefinirSenhaTemplate;

  @override
  final String? urlVerificacaoEmail;

  @override
  final VerificacaoEmailTemplateDto? verificacaoEmailTemplate;

  ConfiguracaoSTMPDto({
    required this.id,
    required this.servidor,
    required this.porta,
    required this.usuario,
    required this.senha,
    required this.redefinirSenhaTemplate,
    this.urlVerificacaoEmail,
    this.verificacaoEmailTemplate,
  });

  factory ConfiguracaoSTMPDto.fromJson(Map<String, dynamic> json) =>
      _$ConfiguracaoSTMPDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfiguracaoSTMPDtoToJson(this);

  ConfiguracaoSTMPDto copyWith({
    int? id,
    String? servidor,
    int? porta,
    String? usuario,
    String? senha,
    RedefinirSenhaTemplateDto? redefinirSenhaTemplate,
    String? urlVerificacaoEmail,
    VerificacaoEmailTemplateDto? verificacaoEmailTemplate,
  }) {
    return ConfiguracaoSTMPDto(
      id: id ?? this.id,
      servidor: servidor ?? this.servidor,
      porta: porta ?? this.porta,
      usuario: usuario ?? this.usuario,
      senha: senha ?? this.senha,
      redefinirSenhaTemplate:
          redefinirSenhaTemplate ?? this.redefinirSenhaTemplate,
      urlVerificacaoEmail: urlVerificacaoEmail ?? this.urlVerificacaoEmail,
      verificacaoEmailTemplate:
          verificacaoEmailTemplate ?? this.verificacaoEmailTemplate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        servidor,
        porta,
        usuario,
        senha,
        redefinirSenhaTemplate,
        urlVerificacaoEmail,
        verificacaoEmailTemplate,
      ];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class RedefinirSenhaTemplateDto implements RedefinirSenhaTemplate {
  @override
  final String assunto;

  @override
  final String corpo;

  RedefinirSenhaTemplateDto({
    required this.assunto,
    required this.corpo,
  });

  factory RedefinirSenhaTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$RedefinirSenhaTemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RedefinirSenhaTemplateDtoToJson(this);

  RedefinirSenhaTemplateDto copyWith({
    String? assunto,
    String? corpo,
  }) {
    return RedefinirSenhaTemplateDto(
      assunto: assunto ?? this.assunto,
      corpo: corpo ?? this.corpo,
    );
  }

  @override
  List<Object?> get props => [assunto, corpo];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class VerificacaoEmailTemplateDto implements VerificacaoEmailTemplate {
  @override
  final String assunto;

  @override
  final String corpo;

  VerificacaoEmailTemplateDto({
    required this.assunto,
    required this.corpo,
  });

  factory VerificacaoEmailTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$VerificacaoEmailTemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerificacaoEmailTemplateDtoToJson(this);

  VerificacaoEmailTemplateDto copyWith({
    String? assunto,
    String? corpo,
  }) {
    return VerificacaoEmailTemplateDto(
      assunto: assunto ?? this.assunto,
      corpo: corpo ?? this.corpo,
    );
  }

  @override
  List<Object?> get props => [assunto, corpo];

  @override
  bool? get stringify => true;
}

extension ConfiguracaoSTMPToDto on ConfiguracaoSTMP {
  ConfiguracaoSTMPDto toDto() {
    return ConfiguracaoSTMPDto(
      id: id,
      servidor: servidor,
      porta: porta,
      usuario: usuario,
      senha: senha,
      redefinirSenhaTemplate: RedefinirSenhaTemplateDto(
        assunto: redefinirSenhaTemplate.assunto,
        corpo: redefinirSenhaTemplate.corpo,
      ),
      urlVerificacaoEmail: urlVerificacaoEmail,
      verificacaoEmailTemplate: verificacaoEmailTemplate == null
          ? null
          : VerificacaoEmailTemplateDto(
              assunto: verificacaoEmailTemplate!.assunto,
              corpo: verificacaoEmailTemplate!.corpo,
            ),
    );
  }
}
