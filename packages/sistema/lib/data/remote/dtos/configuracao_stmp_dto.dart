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

  @override
  final PedidoConfirmadoTemplateDto? pedidoConfirmadoTemplate;

  @override
  final PedidoEmbaladoTemplateDto? pedidoEmbaladoTemplate;

  ConfiguracaoSTMPDto({
    required this.id,
    required this.servidor,
    required this.porta,
    required this.usuario,
    required this.senha,
    required this.redefinirSenhaTemplate,
    this.urlVerificacaoEmail,
    this.verificacaoEmailTemplate,
    this.pedidoConfirmadoTemplate,
    this.pedidoEmbaladoTemplate,
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
    PedidoConfirmadoTemplateDto? pedidoConfirmadoTemplate,
    PedidoEmbaladoTemplateDto? pedidoEmbaladoTemplate,
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
      pedidoConfirmadoTemplate:
          pedidoConfirmadoTemplate ?? this.pedidoConfirmadoTemplate,
      pedidoEmbaladoTemplate:
          pedidoEmbaladoTemplate ?? this.pedidoEmbaladoTemplate,
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
        pedidoConfirmadoTemplate,
        pedidoEmbaladoTemplate,
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

@JsonSerializable()
class PedidoConfirmadoTemplateDto implements PedidoConfirmadoTemplate {
  @override
  final String assunto;

  @override
  final String corpo;

  PedidoConfirmadoTemplateDto({
    required this.assunto,
    required this.corpo,
  });

  factory PedidoConfirmadoTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$PedidoConfirmadoTemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PedidoConfirmadoTemplateDtoToJson(this);

  PedidoConfirmadoTemplateDto copyWith({
    String? assunto,
    String? corpo,
  }) {
    return PedidoConfirmadoTemplateDto(
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
class PedidoEmbaladoTemplateDto implements PedidoEmbaladoTemplate {
  @override
  final String assunto;

  @override
  final String corpo;

  PedidoEmbaladoTemplateDto({
    required this.assunto,
    required this.corpo,
  });

  factory PedidoEmbaladoTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$PedidoEmbaladoTemplateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PedidoEmbaladoTemplateDtoToJson(this);

  PedidoEmbaladoTemplateDto copyWith({
    String? assunto,
    String? corpo,
  }) {
    return PedidoEmbaladoTemplateDto(
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
      pedidoConfirmadoTemplate: pedidoConfirmadoTemplate == null
          ? null
          : PedidoConfirmadoTemplateDto(
              assunto: pedidoConfirmadoTemplate!.assunto,
              corpo: pedidoConfirmadoTemplate!.corpo,
            ),
      pedidoEmbaladoTemplate: pedidoEmbaladoTemplate == null
          ? null
          : PedidoEmbaladoTemplateDto(
              assunto: pedidoEmbaladoTemplate!.assunto,
              corpo: pedidoEmbaladoTemplate!.corpo,
            ),
    );
  }
}
