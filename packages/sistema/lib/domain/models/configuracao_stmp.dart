import 'package:core/equals.dart';

abstract class ConfiguracaoSTMP implements Equatable {
  int get id;
  String get servidor;
  int get porta;
  String get usuario;
  String get senha;
  RedefinirSenhaTemplate get redefinirSenhaTemplate;

  factory ConfiguracaoSTMP.create({
    required int id,
    required String servidor,
    required int porta,
    required String usuario,
    required String senha,
    required RedefinirSenhaTemplate redefinirSenhaTemplate,
  }) = _ConfiguracaoSTMPImpl;

  @override
  List<Object?> get props => [
        id,
        servidor,
        porta,
        usuario,
        senha,
        redefinirSenhaTemplate,
      ];

  @override
  bool? get stringify => true;
}

class _ConfiguracaoSTMPImpl implements ConfiguracaoSTMP {
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
  final RedefinirSenhaTemplate redefinirSenhaTemplate;

  _ConfiguracaoSTMPImpl({
    required this.id,
    required this.servidor,
    required this.porta,
    required this.usuario,
    required this.senha,
    required this.redefinirSenhaTemplate,
  });

  _ConfiguracaoSTMPImpl copyWith({
    int? id,
    String? servidor,
    int? porta,
    String? usuario,
    String? senha,
    RedefinirSenhaTemplate? redefinirSenhaTemplate,
  }) {
    return _ConfiguracaoSTMPImpl(
      id: id ?? this.id,
      servidor: servidor ?? this.servidor,
      porta: porta ?? this.porta,
      usuario: usuario ?? this.usuario,
      senha: senha ?? this.senha,
      redefinirSenhaTemplate:
          redefinirSenhaTemplate ?? this.redefinirSenhaTemplate,
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
      ];

  @override
  bool? get stringify => true;
}

extension ConfiguracaoSTMPCopyWith on ConfiguracaoSTMP {
  ConfiguracaoSTMP copyWith({
    int? id,
    String? servidor,
    int? porta,
    String? usuario,
    String? senha,
    RedefinirSenhaTemplate? redefinirSenhaTemplate,
  }) {
    if (this is _ConfiguracaoSTMPImpl) {
      return (this as _ConfiguracaoSTMPImpl).copyWith(
        id: id,
        servidor: servidor,
        porta: porta,
        usuario: usuario,
        senha: senha,
        redefinirSenhaTemplate: redefinirSenhaTemplate,
      );
    }

    return ConfiguracaoSTMP.create(
      id: id ?? this.id,
      servidor: servidor ?? this.servidor,
      porta: porta ?? this.porta,
      usuario: usuario ?? this.usuario,
      senha: senha ?? this.senha,
      redefinirSenhaTemplate:
          redefinirSenhaTemplate ?? this.redefinirSenhaTemplate,
    );
  }
}

abstract class RedefinirSenhaTemplate implements Equatable {
  String get assunto;
  String get corpo;

  factory RedefinirSenhaTemplate.create({
    required String assunto,
    required String corpo,
  }) = _RedefinirSenhaTemplateImpl;

  @override
  List<Object?> get props => [assunto, corpo];

  @override
  bool? get stringify => true;
}

class _RedefinirSenhaTemplateImpl implements RedefinirSenhaTemplate {
  @override
  final String assunto;
  @override
  final String corpo;

  _RedefinirSenhaTemplateImpl({
    required this.assunto,
    required this.corpo,
  });

  _RedefinirSenhaTemplateImpl copyWith({
    String? assunto,
    String? corpo,
  }) {
    return _RedefinirSenhaTemplateImpl(
      assunto: assunto ?? this.assunto,
      corpo: corpo ?? this.corpo,
    );
  }

  @override
  List<Object?> get props => [assunto, corpo];

  @override
  bool? get stringify => true;
}

extension RedefinirSenhaTemplateCopyWith on RedefinirSenhaTemplate {
  RedefinirSenhaTemplate copyWith({
    String? assunto,
    String? corpo,
  }) {
    if (this is _RedefinirSenhaTemplateImpl) {
      return (this as _RedefinirSenhaTemplateImpl).copyWith(
        assunto: assunto,
        corpo: corpo,
      );
    }

    return RedefinirSenhaTemplate.create(
      assunto: assunto ?? this.assunto,
      corpo: corpo ?? this.corpo,
    );
  }
}
