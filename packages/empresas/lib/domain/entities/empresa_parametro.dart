import 'package:core/equals.dart';

abstract class EmpresaParametro implements Equatable {
  int get id;
  int get empresaId;
  String get chave;
  String get descricao;
  TipoEmpresaParametro get tipo;
  String? get valorTexto;
  bool? get valorBooleano;
  bool get descontinuado;

  bool get ehCheckbox => tipo == TipoEmpresaParametro.checkbox;

  factory EmpresaParametro.create({
    required int id,
    required int empresaId,
    required String chave,
    required String descricao,
    required TipoEmpresaParametro tipo,
    String? valorTexto,
    bool? valorBooleano,
    required bool descontinuado,
  }) = _EmpresaParametroImpl;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        chave,
        descricao,
        tipo,
        valorTexto,
        valorBooleano,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}

class _EmpresaParametroImpl implements EmpresaParametro {
  @override
  final int id;

  @override
  final int empresaId;

  @override
  final String chave;

  @override
  final String descricao;

  @override
  final TipoEmpresaParametro tipo;

  @override
  final String? valorTexto;

  @override
  final bool? valorBooleano;

  _EmpresaParametroImpl({
    required this.id,
    required this.empresaId,
    required this.chave,
    required this.descricao,
    required this.tipo,
    required this.descontinuado,
    this.valorTexto,
    this.valorBooleano,
  });

  _EmpresaParametroImpl copyWith({
    int? id,
    int? empresaId,
    String? chave,
    String? descricao,
    TipoEmpresaParametro? tipo,
    String? valorTexto,
    bool? valorBooleano,
    bool? descontinuado,
  }) {
    return _EmpresaParametroImpl(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      chave: chave ?? this.chave,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      valorTexto: valorTexto ?? this.valorTexto,
      valorBooleano: valorBooleano ?? this.valorBooleano,
      descontinuado: descontinuado ?? this.descontinuado,
    );
  }

  @override
  bool get ehCheckbox => tipo == TipoEmpresaParametro.checkbox;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        chave,
        descricao,
        tipo,
        valorTexto,
        valorBooleano,
        descontinuado,
      ];

  @override
  bool? get stringify => true;

  @override
  final bool descontinuado;
}

extension EmpresaParametroCopyWith on EmpresaParametro {
  EmpresaParametro copyWith({
    int? id,
    int? empresaId,
    String? chave,
    String? descricao,
    TipoEmpresaParametro? tipo,
    String? valorTexto,
    bool? valorBooleano,
    bool? descontinuado,
  }) {
    if (this is _EmpresaParametroImpl) {
      return (this as _EmpresaParametroImpl).copyWith(
        id: id,
        empresaId: empresaId,
        chave: chave,
        descricao: descricao,
        tipo: tipo,
        valorTexto: valorTexto,
        valorBooleano: valorBooleano,
        descontinuado: descontinuado,
      );
    }

    return EmpresaParametro.create(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      chave: chave ?? this.chave,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      valorTexto: valorTexto ?? this.valorTexto,
      valorBooleano: valorBooleano ?? this.valorBooleano,
      descontinuado: descontinuado ?? this.descontinuado,
    );
  }
}

enum TipoEmpresaParametro { checkbox, texto }
