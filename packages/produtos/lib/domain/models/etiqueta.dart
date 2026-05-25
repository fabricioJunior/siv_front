import 'package:core/equals.dart';

abstract class Etiqueta implements Equatable {
  int? get id;
  String get nome;
  double get altura;
  double get largura;
  EtiquetaDpi get dpi;
  List<EtiquetaElemento> get elementos;
  List<EtiquetaVia> get vias;

  int get quantidadeVias => vias.length;

  factory Etiqueta.create({
    int? id,
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  }) = _EtiquetaImpl;

  @override
  List<Object?> get props => [id, nome, altura, largura, dpi, elementos, vias];

  @override
  bool? get stringify => true;
}

abstract class EtiquetaElemento implements Equatable {
  String get nome;
  TipoElementoEtiqueta get tipoElemento;
  double get x;
  double get y;

  factory EtiquetaElemento.create({
    required String nome,
    required TipoElementoEtiqueta tipoElemento,
    required double x,
    required double y,
  }) = _EtiquetaElementoImpl;

  @override
  List<Object?> get props => [nome, tipoElemento, x, y];

  @override
  bool? get stringify => true;
}

abstract class EtiquetaVia implements Equatable {
  int get ordem;
  String get zpl;

  factory EtiquetaVia.create({
    required int ordem,
    required String zpl,
  }) = _EtiquetaViaImpl;

  @override
  List<Object?> get props => [ordem, zpl];

  @override
  bool? get stringify => true;
}

class _EtiquetaImpl implements Etiqueta {
  @override
  final int? id;

  @override
  final String nome;

  @override
  final double altura;

  @override
  final double largura;

  @override
  final EtiquetaDpi dpi;

  @override
  final List<EtiquetaElemento> elementos;

  @override
  final List<EtiquetaVia> vias;

  @override
  int get quantidadeVias => vias.length;

  _EtiquetaImpl({
    this.id,
    required this.nome,
    required this.altura,
    required this.largura,
    required this.dpi,
    required this.elementos,
    required this.vias,
  });

  _EtiquetaImpl copyWith({
    int? id,
    String? nome,
    double? altura,
    double? largura,
    EtiquetaDpi? dpi,
    List<EtiquetaElemento>? elementos,
    List<EtiquetaVia>? vias,
  }) {
    return _EtiquetaImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      altura: altura ?? this.altura,
      largura: largura ?? this.largura,
      dpi: dpi ?? this.dpi,
      elementos: elementos ?? this.elementos,
      vias: vias ?? this.vias,
    );
  }

  @override
  List<Object?> get props => [id, nome, altura, largura, dpi, elementos, vias];

  @override
  bool? get stringify => true;
}

class _EtiquetaElementoImpl implements EtiquetaElemento {
  @override
  final String nome;

  @override
  final TipoElementoEtiqueta tipoElemento;

  @override
  final double x;

  @override
  final double y;

  _EtiquetaElementoImpl({
    required this.nome,
    required this.tipoElemento,
    required this.x,
    required this.y,
  });

  _EtiquetaElementoImpl copyWith({
    String? nome,
    TipoElementoEtiqueta? tipoElemento,
    double? x,
    double? y,
  }) {
    return _EtiquetaElementoImpl(
      nome: nome ?? this.nome,
      tipoElemento: tipoElemento ?? this.tipoElemento,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  List<Object?> get props => [nome, tipoElemento, x, y];

  @override
  bool? get stringify => true;
}

class _EtiquetaViaImpl implements EtiquetaVia {
  @override
  final int ordem;

  @override
  final String zpl;

  _EtiquetaViaImpl({
    required this.ordem,
    required this.zpl,
  });

  _EtiquetaViaImpl copyWith({
    int? ordem,
    String? zpl,
  }) {
    return _EtiquetaViaImpl(
      ordem: ordem ?? this.ordem,
      zpl: zpl ?? this.zpl,
    );
  }

  @override
  List<Object?> get props => [ordem, zpl];

  @override
  bool? get stringify => true;
}

enum TipoElementoEtiqueta {
  texto,
  codigoDeBarras,
}

extension TipoElementoEtiquetaX on TipoElementoEtiqueta {
  String get valor {
    return switch (this) {
      TipoElementoEtiqueta.texto => 'texto',
      TipoElementoEtiqueta.codigoDeBarras => 'codigoDeBarras',
    };
  }

  static TipoElementoEtiqueta fromValue(dynamic value) {
    final normalizado = value?.toString().trim();
    if (normalizado == 'codigoDeBarras') {
      return TipoElementoEtiqueta.codigoDeBarras;
    }
    return TipoElementoEtiqueta.texto;
  }
}

enum EtiquetaDpi {
  d101,
  d152,
  d203,
  d300,
  d600,
}

extension EtiquetaDpiX on EtiquetaDpi {
  int get valor {
    return switch (this) {
      EtiquetaDpi.d101 => 101,
      EtiquetaDpi.d152 => 152,
      EtiquetaDpi.d203 => 203,
      EtiquetaDpi.d300 => 300,
      EtiquetaDpi.d600 => 600,
    };
  }

  static EtiquetaDpi fromValue(dynamic value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString().trim() ?? '');

    return switch (parsed) {
      101 => EtiquetaDpi.d101,
      152 => EtiquetaDpi.d152,
      203 => EtiquetaDpi.d203,
      300 => EtiquetaDpi.d300,
      600 => EtiquetaDpi.d600,
      _ => EtiquetaDpi.d203,
    };
  }
}

extension EtiquetaCopyWith on Etiqueta {
  Etiqueta copyWith({
    int? id,
    String? nome,
    double? altura,
    double? largura,
    EtiquetaDpi? dpi,
    List<EtiquetaElemento>? elementos,
    List<EtiquetaVia>? vias,
  }) {
    if (this is _EtiquetaImpl) {
      return (this as _EtiquetaImpl).copyWith(
        id: id,
        nome: nome,
        altura: altura,
        largura: largura,
        dpi: dpi,
        elementos: elementos,
        vias: vias,
      );
    }

    return Etiqueta.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      altura: altura ?? this.altura,
      largura: largura ?? this.largura,
      dpi: dpi ?? this.dpi,
      elementos: elementos ?? this.elementos,
      vias: vias ?? this.vias,
    );
  }
}

extension EtiquetaElementoCopyWith on EtiquetaElemento {
  EtiquetaElemento copyWith({
    String? nome,
    TipoElementoEtiqueta? tipoElemento,
    double? x,
    double? y,
  }) {
    if (this is _EtiquetaElementoImpl) {
      return (this as _EtiquetaElementoImpl).copyWith(
        nome: nome,
        tipoElemento: tipoElemento,
        x: x,
        y: y,
      );
    }

    return EtiquetaElemento.create(
      nome: nome ?? this.nome,
      tipoElemento: tipoElemento ?? this.tipoElemento,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

extension EtiquetaViaCopyWith on EtiquetaVia {
  EtiquetaVia copyWith({
    int? ordem,
    String? zpl,
  }) {
    if (this is _EtiquetaViaImpl) {
      return (this as _EtiquetaViaImpl).copyWith(
        ordem: ordem,
        zpl: zpl,
      );
    }

    return EtiquetaVia.create(
      ordem: ordem ?? this.ordem,
      zpl: zpl ?? this.zpl,
    );
  }
}
